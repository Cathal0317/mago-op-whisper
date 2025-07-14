# mago-op-whisper

![MAGO](https://img.shields.io/badge/MAGO-2025-green)
![OP](https://img.shields.io/badge/OP-2025-red)
![Python](https://img.shields.io/badge/python-3.10-blue)
![License](https://img.shields.io/badge/license-Apache%202.0-green)

오렌지 플래릿 교육 프로그램 코드 w/ [Whisper](https://github.com/openai/whisper.git)

![study-group](assets/orange-mago.png)

## 폴더 구조

```vim
.
├── egs
│   └── whisper
└── saturn2
    ├── backend
    ├── helper
    ├── media
    └── utils
```

- **egs**: 예제 코드
  - **whisper**: 오렌지 플래릿 교육 프로그램 코드 w/ Whisper
- **saturn2**: 코드 베이스
  - **backend**: FAST API 사용을 위한 코드 베이스
  - **helper**: 코드 베이스 사용을 위한 헬퍼 함수
  - **media**: 미디어 파일 관리 (미디어 변환)
  - **utils**: 유틸리티 함수

## 설치

SATURN의 코딩 정책을 따라 각 서비스의 코드는 `egs/<service_name>` 폴더에 있습니다.

따라서, 여기서 지원하는 서비스는 `whisper`를 사용하여 서비스를 구현하기 때문에 `egs/whisper`에 서비스 위한 코드가 있습니다.

### 가상 환경 설정

- Python 코드는 가상 환경에서 작업을 하는게 좋습니다.
- 가상 환경 설치를 빠르게 하기 위해 다음을 실행해 주세요.

```bash
cd egs/whisper
./scripts/install.sh
```

- 설치를 직접 하고 싶다면 [설치 코드](egs/whisper/scripts/install.sh)를 참고 하여 실행을 하면 됩니다.

## 실행

테스트 오디오를 사용하여 다음과 같이 실행을 해 볼 수 있습니다.

### 빠른 실행

```bash
cd egs/whisper
./scripts/run.sh test/test.wav
```

### Python 실행

```bash
cd egs/whisper
python local/transcribe.py \
  --model-name turbo \
  --nocuda \
  --lang ko \
  --out-dir exp/whisper \
  --task transcribe \
  test/test.flac
```

## 배포

Docker 이미지를 빌드하고 Container를 실행합니다.

[Docker 사용법](docs/docker.md)

### Build

```bash
docker compose build
```

### Run

```bash
docker compose up -d
```

### Test URL

실행 환경에 따라 변경해서 사용해 주세요. 아래 주소는 local 환경에서 실행한 경우 입니다.

- [Service URL](http://localhost:9005/whisper/docs)

## GitHub Actions
👉 [GitHub Actions](docs/github_actions.md)

<<<<<<< HEAD
👉 [GitHub Actions](docs/github_actions.md) 
=======
hello
>>>>>>> c69dff375f51d0e55690a1e90a6e4918dda7bb59
