#!/bin/bash

echo "===== 개발 환경 자동화 스크립트 시작 ====="

# 시스템 업데이트
echo "시스템 업데이트 중..."
sudo apt update && sudo apt upgrade -y

# 기본 개발 도구 설치
echo "기본 개발 도구 설치 중..."
sudo apt install -y build-essential git curl wget unzip software-properties-common apt-transport-https ca-certificates

# 개발 디렉토리 생성
echo "개발 디렉토리 구조 생성 중..."
mkdir -p ~/projects/personal
mkdir -p ~/projects/work
mkdir -p ~/projects/learning

# Git 설정
echo "Git 전역 설정 중..."
git config --global user.name "당신의 이름"
git config --global user.email "당신의이메일@example.com"
git config --global init.defaultBranch main
git config --global core.editor "nano"

# Zsh & Oh-My-Zsh 설치
echo "Zsh 및 Oh-My-Zsh 설치 중..."
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)

# NVM 및 Node.js 설치
echo "NVM 및 Node.js 설치 중..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install --lts

# Docker 설치
echo "Docker 설치 중..."
sudo apt install -y docker.io
sudo usermod -aG docker ${USER}

# Python 개발 환경 설치
echo "Python 개발 도구 설치 중..."
sudo apt install -y python3-pip python3-venv

# VS Code 서버 설치 (WSL용)
echo "VS Code 서버 설치 중..."
curl -fsSL https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64 -o vscode_cli.tar.gz
tar -xf vscode_cli.tar.gz
sudo mv code /usr/local/bin/
rm vscode_cli.tar.gz

echo "===== 개발 환경 설정 완료! ====="
echo "변경사항을 적용하려면 터미널을 재시작하거나 'source ~/.zshrc' 명령어를 실행하세요."
