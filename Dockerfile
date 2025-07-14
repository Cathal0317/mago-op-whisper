# ==================================================================
# Stage 1: Builder - Install Python packages into a venv
# ------------------------------------------------------------------
    FROM python:3.13-slim AS builder

    ENV VENV_PATH=/venv
    ENV PATH="$VENV_PATH/bin:$PATH"

    # 시스템 패키지 설치 (빌드용 의존성 포함)
    RUN apt-get update \
     && apt-get install -y --no-install-recommends \
          build-essential \
          git \
          curl \
          ffmpeg \
     && rm -rf /var/lib/apt/lists/*

    # 가상환경 생성 및 pip 업그레이드
    RUN python -m venv $VENV_PATH \
     && pip install --upgrade pip setuptools wheel

    # PyTorch (CPU) + torchaudio 설치
    RUN pip install --no-cache-dir \
          torch \
          torchaudio \
          --extra-index-url https://download.pytorch.org/whl/cpu

    # OpenAI whisper 설치 (GitHub 최신 버전)
    RUN pip install --no-cache-dir \
          git+https://github.com/openai/whisper.git

    # 프로젝트 의존성 설치
    # (호스트의 requirements.txt 위치에 맞춰 경로를 조정하세요)
    COPY egs/whisper/requirements.txt /deepsaturn/requirements.txt
    RUN pip install --no-cache-dir -r /deepsaturn/requirements.txt

# ==================================================================
# Stage 2: Runtime image
# ------------------------------------------------------------------
    FROM python:3.13-slim AS runtime

    ENV VENV_PATH=/venv
    ENV PATH="$VENV_PATH/bin:$PATH" \
        LC_ALL=C.UTF-8 \
        PYTHONUNBUFFERED=1 \
        PYTHONPATH="/deepsaturn:/deepsaturn/egs/whisper"

    # 최소 런타임 의존성만 설치 (ffmpeg 등)
    RUN apt-get update \
     && apt-get install -y --no-install-recommends \
          ffmpeg \
     && rm -rf /var/lib/apt/lists/*

    # 빌더에서 만든 가상환경 복사
    COPY --from=builder /venv /venv

    # 애플리케이션 코드 복사
    COPY saturn2 /deepsaturn/saturn2
    COPY egs      /deepsaturn/egs

    WORKDIR /deepsaturn/egs/whisper

    # 기본 실행 명령어 (필요에 따라 변경)
    CMD ["bash"]





    # # ---------- 0. 베이스 ----------
#    FROM ubuntu:22.04

#    # ---------- 1. 빌드 인자 ----------
#    ARG USERNAME=devuser        # ← USER 대신 USERNAME 사용
#    ARG HOST_UID=501
#    ARG HOST_GID=20
#    ARG NODE_MAJOR=22
#    ARG TZ=Asia/Seoul
   
#    ENV DEBIAN_FRONTEND=noninteractive \
#       TZ=${TZ}
   

#    # ---------- 2. 필요한 패키지 ----------
#    RUN apt-get update && \
#       apt-get install -y --no-install-recommends \
#          build-essential git curl vim sudo tzdata \
#          python3 python3-pip python3-venv python-is-python3 \
#          ffmpeg \
#          docker-cli \
#          && rm -rf /var/lib/apt/lists/*

#    # ---------- 2-B. docker compose plugin ----------
#    RUN apt-get update && apt-get install -y curl gnupg && \
#       curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
#          | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg && \
#       echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] \
#          https://download.docker.com/linux/ubuntu jammy stable" \
#          | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
#       apt-get update && apt-get install -y docker-compose-plugin && \
#       rm -rf /var/lib/apt/lists/*
   
#    # ---------- 3. 사용자 생성 ----------
#    RUN if ! getent group ${HOST_GID}; then \
#          groupadd -g ${HOST_GID} hostgroup ; \
#       fi && \
#       useradd -u ${HOST_UID} -g ${HOST_GID} -m ${USERNAME} && \
#       echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
   
#    # ---------- 4. 작업 디렉터리 ----------
#    USER ${USERNAME}
#    WORKDIR /home/${USERNAME}/workspace
   
#    CMD ["bash"]

# ---------- 0. 베이스 ----------
   FROM ubuntu:22.04

   # ---------- 1. 빌드 인자 ----------
   ARG USERNAME=cyh          # 컨테이너 안 사용자
   ARG HOST_UID=501              # 호스트 UID → 도커 실행 시 덮어씀
   ARG HOST_GID=20               # 호스트 GID
   ARG TZ=Asia/Seoul
   
   ENV DEBIAN_FRONTEND=noninteractive
   ENV TZ=${TZ}
   
   # ---------- 2. 공통 패키지 + 도커 CLI/Compose ----------
   RUN apt-get update -y && \
      apt-get install -y --no-install-recommends \
         sudo curl gnupg ca-certificates tzdata \
         build-essential git vim jq\
         python3 python3-pip python3-venv python-is-python3 \
         ffmpeg docker-cli && \
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
         gpg --dearmor -o /usr/share/keyrings/docker.gpg && \
      echo "deb [arch=$(dpkg --print-architecture) \
         signed-by=/usr/share/keyrings/docker.gpg] \
         https://download.docker.com/linux/ubuntu jammy stable" \
         > /etc/apt/sources.list.d/docker.list && \
      apt-get update -y && \
      apt-get install -y docker-compose-plugin && \
      rm -rf /var/lib/apt/lists/*

   # ---------- 3-B. Gitbook CLI ----------
    RUN apt-get update && apt-get install -y nodejs npm
    RUN npm install -g @gitbook/cli
   
   # ---------- 4. 사용자 생성 / sudo 무비번 ----------
   RUN if ! getent group ${HOST_GID}; then \
         groupadd -g ${HOST_GID} hostgroup ; \
      fi && \
      useradd -m -u ${HOST_UID} -g ${HOST_GID} -s /bin/bash ${USERNAME} && \
      usermod -aG sudo ${USERNAME} && \
      echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} && \
      chmod 0440 /etc/sudoers.d/${USERNAME}

   # ---------- 4-B. 사용자 환경 변수 설정 ----------
   USER ${USERNAME}
   RUN echo 'export M2_HOME=/opt/maven' >> /home/${USERNAME}/.bashrc && \
      echo 'export PATH=${M2_HOME}/bin:${PATH}' >> /home/${USERNAME}/.bashrc && \
      echo 'export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")' >> /home/${USERNAME}/.bashrc && \
      echo 'export PATH=${JAVA_HOME}/bin:${PATH}' >> /home/${USERNAME}/.bashrc

   # ---------- 5. 기본 셸 ----------
   USER ${USERNAME}
   WORKDIR /home/${USERNAME}/workspace
   CMD ["bash"]
   