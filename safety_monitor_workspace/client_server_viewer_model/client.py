# 카메라 프레임을 읽어서 TCP socket으로 server.py에 보내는 클라이언트 파일입니다.
# 이 예제에서는 HTTP가 아니라 직접 TCP 연결로 프레임 bytes를 전송합니다.

import cv2
import socket
import cv2
import socket
import struct
import time
import os

try:
    from ultralytics import YOLO
except Exception:
    YOLO = None


def load_model(path='YOLO26n.pt'):
    # YOLO 모델 파일을 로드합니다. 모델이 없으면 탐지 없이 프레임만 전송합니다.
    if YOLO is None:
        print('Warning: ultralytics 패키지가 설치되어 있지 않습니다.')
        return None

    if not os.path.exists(path):
        print(f'Model file not found: {path}. 모델 파일을 작업 디렉터리에 위치시켜주세요.')
        return None

    try:
        model = YOLO(path)
        print('모델 로드 완료:', path)
        return model
    except Exception as e:
        print('모델 로드 실패:', e)
        return None


def helmet_detected(model, results):
    # YOLO 결과 안에 helmet/hardhat 계열 클래스가 있는지 확인합니다.
    # results: ultralytics Results 객체(또는 list 형태의 결과)
    try:
        res = results[0] if isinstance(results, (list, tuple)) else results
        names = getattr(model, 'names', {}) or {}

        # boxes가 존재하고 클래스 이름에 'helmet' 또는 'hardhat' 포함 여부 확인
        boxes = getattr(res, 'boxes', None)
        if boxes is None:
            return False

        # boxes는 iterable한 객체입니다. 각 박스의 cls, conf 등이 존재함
        for box in boxes:
            cls_attr = getattr(box, 'cls', None)
            if cls_attr is None:
                continue
            # ultralytics v8: box.cls는 Tensor 형태, index 접근
            try:
                cls_idx = int(cls_attr[0])
            except Exception:
                try:
                    cls_idx = int(cls_attr)
                except Exception:
                    cls_idx = None
            if cls_idx is None:
                continue
            name = names.get(cls_idx, '')
            if 'helmet' in name.lower() or 'hardhat' in name.lower() or '안전모' in name:
                return True

        # 클래스명이 불확실하면, 단순히 박스가 하나라도 있으면 탐지로 간주
        return len(boxes) > 0
    except Exception:
        return False


def run_client():
    # server.py의 asyncio.start_server 포트인 8888로 TCP 연결을 시도합니다.
    server_ip = '127.0.0.1'
    server_port = 8888

    # HTTP 요청이 아니라 socket.connect 후 sendall로 직접 데이터를 보내는 방식입니다.
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    try:
        client_socket.connect((server_ip, server_port))
        print('서버에 성공적으로 연결되었습니다.')
    except Exception as e:
        print(f'서버 연결 실패: {e}')
        return

    # 0번 카메라를 열어 프레임을 계속 읽습니다.
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print('카메라를 열 수 없습니다.')
        client_socket.close()
        return

    model = load_model('YOLO26n.pt')
    if model is None:
        print('모델을 로드할 수 없어 안전모 탐지를 수행하지 않습니다. 모델 파일과 패키지 설치를 확인하세요.')

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                print('프레임을 읽을 수 없습니다.')
                break

            annotated = frame
            send_frame = True  # Send all frames for stability

            if model is not None:
                try:
                    results = model(frame)
                    if helmet_detected(model, results):
                        try:
                            annotated = results[0].plot()
                        except Exception:
                            annotated = frame
                except Exception as e:
                    print('탐지 중 오류:', e)

            if send_frame:
                result, encoded_frame = cv2.imencode('.jpg', annotated, [int(cv2.IMWRITE_JPEG_QUALITY), 80])
                if not result:
                    print('프레임 인코딩 실패')
                else:
                    data = encoded_frame.tobytes()
                    # 서버가 먼저 길이를 읽을 수 있도록 8바이트 길이 헤더를 붙입니다.
                    header = struct.pack('Q', len(data))
                    try:
                        # 길이 헤더와 JPEG bytes를 한 번에 서버로 보냅니다.
                        client_socket.sendall(header + data)
                        print('탐지된 프레임 전송됨 (크기:', len(data), ')')
                    except BrokenPipeError:
                        print('서버 연결이 끊어졌습니다.')
                        break

            cv2.imshow('Local Camera (press q to quit)', annotated)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                print('사용자 요청으로 종료합니다.')
                break

            # time.sleep(0.01)

    except Exception as e:
        print(f'통신 에러: {e}')
    finally:
        cap.release()
        cv2.destroyAllWindows()
        try:
            client_socket.shutdown(socket.SHUT_RDWR)
        except OSError:
            pass
        client_socket.close()
        print('클라이언트 종료')


if __name__ == '__main__':
    run_client()