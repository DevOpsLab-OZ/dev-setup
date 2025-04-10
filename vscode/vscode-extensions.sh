#!/bin/bash

# VS Code 확장 프로그램 설치 스크립트

extensions=(
  "ms-vscode-remote.remote-wsl"        # WSL 연동
  "ms-python.python"                   # Python 지원
  "dbaeumer.vscode-eslint"             # JavaScript 린트
  "esbenp.prettier-vscode"             # 코드 포맷터
  "ms-azuretools.vscode-docker"        # Docker 지원
  "ritwickdey.liveserver"              # 웹 개발용 라이브 서버
  "ms-vscode.cpptools"                 # C/C++ 지원
  "github.copilot"                     # GitHub Copilot (옵션)
)

for extension in "${extensions[@]}"
do
  code --install-extension "$extension"
done

echo "VS Code 확장 프로그램 설치 완료!"
