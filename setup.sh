#!/bin/bash

# 개발 환경 자동화 스크립트

# 색상 코드 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 출력 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 실행 상태 확인 함수
check_status() {
    if [ $? -eq 0 ]; then
        log_success "$1 완료"
        return 0
    else
        log_error "$1 실패"
        return 1
    fi
}

# 백업 생성 함수
create_backup() {
    log_info "설정 파일 백업 시작..."
    
    # 백업 디렉토리 생성
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_dir="$HOME/.dotfiles_backup_$timestamp"
    mkdir -p "$backup_dir"
    
    # 주요 설정 파일 백업
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$backup_dir/"
        log_info ".zshrc 파일을 백업했습니다."
    fi
    
    if [ -f "$HOME/.gitconfig" ]; then
        cp "$HOME/.gitconfig" "$backup_dir/"
        log_info ".gitconfig 파일을 백업했습니다."
    fi
    
    if [ -d "$HOME/.vscode" ]; then
        mkdir -p "$backup_dir/.vscode"
        cp -r "$HOME/.vscode/settings.json" "$backup_dir/.vscode/" 2>/dev/null
        log_info "VS Code 설정을 백업했습니다."
    fi
    
    log_success "설정 파일 백업 완료 (백업 위치: $backup_dir)"
    return 0
}

# 백업 생성 (주요 작업 시작 전)
echo -e "${BLUE}===== 개발 환경 자동화 스크립트 시작 =====${NC}"
create_backup

# 시스템 업데이트
log_info "시스템 업데이트 중..."
sudo apt update && sudo apt upgrade -y
check_status "시스템 업데이트"

# 기본 개발 도구 설치
log_info "기본 개발 도구 설치 중..."
sudo apt install -y build-essential git curl wget unzip software-properties-common apt-transport-https ca-certificates
check_status "기본 개발 도구 설치"

# 개발 디렉토리 생성
log_info "개발 디렉토리 구조 생성 중..."
mkdir -p ~/projects/personal
mkdir -p ~/projects/work
mkdir -p ~/projects/learning
check_status "개발 디렉토리 구조 생성"

# Git 설정
log_info "Git 전역 설정 중..."
git config --global user.name "당신의 이름"
git config --global user.email "당신의이메일@example.com"
git config --global init.defaultBranch main
git config --global core.editor "nano"
check_status "Git 설정"

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
