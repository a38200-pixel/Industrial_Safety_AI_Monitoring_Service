# TCP로 클라이언트 프레임을 받고, HTTP로 뷰어에게 화면을 제공하는 서버 파일입니다.
# aiohttp의 app.add_routes 부분에서 URL과 GET 방식이 연결됩니다.

import asyncio
import cv2
import numpy as np
import struct
from aiohttp import web
import logging


logging.basicConfig(level=logging.INFO)

# 최신 프레임을 클라이언트 식별자별로 저장합니다.
# 뷰어가 /stream/{client}로 요청하면 여기 저장된 JPEG bytes를 읽어 갑니다.
latest_frames = {}


async def handle_client(reader, writer):
    # asyncio.start_server에 연결되는 TCP 처리 함수입니다.
    # HTTP가 아니라 socket으로 JPEG 프레임 크기와 실제 프레임 bytes를 직접 받습니다.
    peername = writer.get_extra_info('peername')
    client_id = f"{peername[0]}:{peername[1]}"
    logging.info(f"새로운 클라이언트 연결됨: {client_id}")

    payload_size = struct.calcsize('Q')
    last_frame_data = None

    try:
        while True:
            # 먼저 8바이트짜리 길이 정보를 받고, 그 길이만큼 프레임 데이터를 다시 읽습니다.
            packed_msg_size = await reader.readexactly(payload_size)
            msg_size = struct.unpack('Q', packed_msg_size)[0]
            frame_data = await reader.readexactly(msg_size)
            last_frame_data = frame_data

            # 클라이언트가 보낸 JPEG bytes를 OpenCV 이미지로 복원합니다.
            frame_np = np.frombuffer(frame_data, dtype=np.uint8)
            frame = cv2.imdecode(frame_np, cv2.IMREAD_COLOR)

            if frame is not None:
                # 뷰어에게 다시 보내기 쉽도록 JPEG bytes 형태로 저장합니다.
                ok, jpeg = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 80])
                if ok:
                    latest_frames[client_id] = jpeg.tobytes()
                else:
                    logging.warning(f"JPEG 인코딩 실패: {client_id}")
            else:
                logging.warning(f"프레임 디코딩 실패: {client_id}")

    except asyncio.IncompleteReadError:
        logging.info(f"클라이언트 데이터 종료: {client_id}")
    except Exception as e:
        logging.exception(f"에러 발생 ({client_id}): {e}")
    finally:
        if last_frame_data is not None:
            latest_frames[client_id] = last_frame_data  # 마지막 프레임 저장
        logging.info(f"클라이언트 연결 종료: {client_id}")
        writer.close()
        await writer.wait_closed()


async def mjpeg_stream(request):
    # web.get('/stream/{client}', mjpeg_stream)로 등록된 HTTP GET 처리 함수입니다.
    # 브라우저나 PyQt 뷰어가 특정 client_id의 MJPEG 스트림을 요청할 때 실행됩니다.
    client_id = request.match_info.get('client')
    # support ?single=1 to return single JPEG
    if request.query.get('single') == '1':
        # ?single=1 옵션이 있으면 스트림이 아니라 현재 프레임 한 장만 JPEG로 돌려줍니다.
        img = latest_frames.get(client_id)
        if not img:
            return web.Response(text='Client not connected', status=404)
        return web.Response(body=img, content_type='image/jpeg')

    if client_id not in latest_frames:
        return web.Response(text='Client not connected', status=404)

    resp = web.StreamResponse(status=200, reason='OK', headers={
        'Content-Type': 'multipart/x-mixed-replace; boundary=frame',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
    })
    await resp.prepare(request)

    try:
        last_frame = None
        frame_count = 0
        while True:
            img = latest_frames.get(client_id)
            if img and img != last_frame:
                await resp.write(b'--frame\r\n')
                await resp.write(b'Content-Type: image/jpeg\r\n')
                await resp.write(f'Content-Length: {len(img)}\r\n\r\n'.encode())
                await resp.write(img)
                await resp.write(b'\r\n')
                last_frame = img
                frame_count += 1
            await asyncio.sleep(0.02)  # ~50ms for faster refresh
    except asyncio.CancelledError:
        pass
    return resp


async def clients_list(request):
    # web.get('/clients', clients_list)로 등록된 HTTP GET 처리 함수입니다.
    # 현재 프레임을 보낸 적 있는 클라이언트 목록을 JSON으로 돌려줍니다.
    return web.json_response(list(latest_frames.keys()))


async def index(request):
    # web.get('/', index)로 등록된 기본 페이지입니다.
    # 브라우저에서 서버 주소만 열면 간단한 HTML 뷰어를 내려줍니다.
    html = '''
    <html>
    <head><title>Viewer</title></head>
    <body>
      <h1>Client Streams</h1>
      <div id="containers"></div>
      <script>
        async function refresh(){
          const res = await fetch('/clients');
          const clients = await res.json();
          const cont = document.getElementById('containers');
          cont.innerHTML = '';
          for(let i=0;i<Math.min(4, clients.length); i++){
            const id = clients[i];
            const img = document.createElement('img');
            img.src = `/stream/${encodeURIComponent(id)}`;
            img.style = 'width:45%; margin:5px; border:1px solid #ccc;';
            cont.appendChild(img);
          }
        }
        setInterval(refresh, 2000);
        refresh();
      </script>
    </body>
    </html>
    '''
    return web.Response(text=html, content_type='text/html')


async def start_http_server(host='0.0.0.0', port=8080):
    app = web.Application()
    app.add_routes([
        # FastAPI의 @router.get과 비슷하게, HTTP GET 경로와 처리 함수를 직접 연결합니다.
        web.get('/', index),
        web.get('/clients', clients_list),
        web.get('/stream/{client}', mjpeg_stream),
        web.get('/frame/{client}', mjpeg_stream),
    ])

    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, host, port)
    await site.start()
    logging.info(f'HTTP viewer server started at http://{host}:{port}')


async def main():
    # 8888 포트는 카메라 클라이언트가 TCP socket으로 프레임을 보내는 포트입니다.
    tcp_server = await asyncio.start_server(handle_client, '0.0.0.0', 8888)
    addr = tcp_server.sockets[0].getsockname()
    logging.info(f'TCP server started: {addr}')

    # Start HTTP server for viewer
    # 8080 포트는 브라우저나 viewer.py가 HTTP GET으로 화면 데이터를 가져가는 포트입니다.
    await start_http_server('0.0.0.0', 8080)

    async with tcp_server:
        await tcp_server.serve_forever()


if __name__ == '__main__':
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logging.info('서버 종료 요청 수신')