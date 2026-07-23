# AI_TODO.md

## 확인 필요

- [ ] 새 PC에서 `check_environment.bat` 결과 확인
- [ ] 새 PC에서 `install_dependencies.bat all` 검증
- [ ] 새 PC에서 `build_client.bat` 검증
- [ ] 새 PC에서 `build_viewer.bat` 검증
- [ ] 서버 PC 방화벽 8000 허용 여부 확인
- [ ] 원격 PC에서 `http://<서버IP>:8000/health` 접근 확인

## 기능 점검

- [ ] 뷰어 좌측 카메라 리스트 선택/선택 해제 검증
- [ ] 이벤트 로그 전체/선택 카메라 필터 검증
- [ ] 이벤트 썸네일 표시 검증
- [ ] 이벤트 클릭 시 해당 타일 클립 재생 검증
- [ ] 위험구역 이벤트 클립에서 ROI 오버레이 검증
- [ ] ROI 드래그 후 편집 종료 시 저장 검증
- [ ] ROI 저장이 위험구역 룰 토글을 자동 ON 하지 않는지 검증
- [ ] DB Clear가 이벤트 DB/클립/썸네일을 정리하는지 검증

## 설계 TODO

- [ ] `source_key`와 사용자 표시명 분리 설계
- [ ] `camera_slot_id`/`display_name` 영구 저장 설계
- [ ] PC 교체 시 새 클라이언트를 기존 카메라 슬롯에 재매핑하는 UI 설계
- [ ] 클라이언트 headless 실행 전환 검토
