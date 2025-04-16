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

# 설정 파일 경로
CONFIG_FILE="./config.yaml"

# 기본 설정값
DEFAULT_GIT_NAME="당신의 이름"
DEFAULT_GIT_EMAIL="당신의이메일@example.com"
DEFAULT_ZSH_THEME="robbyrussell"

# 사용자 설정 로드
load_config() {
    log_info "설정 로드 중..."
    
    # 기본값 설정
    GIT_NAME="$DEFAULT_GIT_NAME"
    GIT_EMAIL="$DEFAULT_GIT_EMAIL"
    ZSH_THEME="$DEFAULT_ZSH_THEME"
    INSTALL_DOCKER=true
    INSTALL_NODEJS=true
    INSTALL_PYTHON=true
    
    # 설정 파일이 없는 경우 생성
    if [ ! -f "$CONFIG_FILE" ]; then
        log_warning "설정 파일($CONFIG_FILE)이 없습니다. 기본 설정 파일을 생성합니다."
        cat > "$CONFIG_FILE" << EOF

# 개발 환경 설정 파일

# Git 설정
git:
  name: "$DEFAULT_GIT_NAME"  # Git 사용자 이름
  email: "$DEFAULT_GIT_EMAIL"  # Git 이메일 주소

# Zsh 설정
zsh:
  theme: "$DEFAULT_ZSH_THEME"  # Oh-My-Zsh 테마 (https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)

# 설치 옵션
install:
  docker: true   # Docker 설치 여부
  nodejs: true   # Node.js와 NVM 설치 여부
  python: true   # Python 개발 도구 설치 여부
EOF
        log_info "기본 설정 파일이 생성되었습니다. 필요에 따라 수정 후 스크립트를 다시 실행하세요."
        if [ -n "$EDITOR" ]; then
            log_info "설정 파일을 편집하려면 $EDITOR $CONFIG_FILE 를 실행하세요."
        else
            log_info "설정 파일을 편집하려면 nano $CONFIG_FILE 를 실행하세요."
        fi
        exit 0
    fi
    
    # YAML 파일 파싱 (간단한 방식)
    if [ -f "$CONFIG_FILE" ]; then
        # Git 이름
        name_line=$(grep -A1 "git:" "$CONFIG_FILE" | grep "name:" | cut -d: -f2)
        if [ -n "$name_line" ]; then
            GIT_NAME=$(echo $name_line | sed 's/^[[:space:]]*//;s/"//g')
        fi
        
        # Git 이메일
        email_line=$(grep -A2 "git:" "$CONFIG_FILE" | grep "email:" | cut -d: -f2)
        if [ -n "$email_line" ]; then
            GIT_EMAIL=$(echo $email_line | sed 's/^[[:space:]]*//;s/"//g')
        fi
        
        # Zsh 테마
        theme_line=$(grep -A1 "zsh:" "$CONFIG_FILE" | grep "theme:" | cut -d: -f2)
        if [ -n "$theme_line" ]; then
            ZSH_THEME=$(echo $theme_line | sed 's/^[[:space:]]*//;s/"//g')
        fi
        
        # 설치 옵션
        if grep -q "docker:[[:space:]]*false" "$CONFIG_FILE"; then
            INSTALL_DOCKER=false
        fi
        
        if grep -q "nodejs:[[:space:]]*false" "$CONFIG_FILE"; then
            INSTALL_NODEJS=false
        fi
        
        if grep -q "python:[[:space:]]*false" "$CONFIG_FILE"; then
            INSTALL_PYTHON=false
        fi
    fi
    
    log_info "설정 로드 완료"
    log_info "Git 사용자: $GIT_NAME ($GIT_EMAIL)"
    log_info "Zsh 테마: $ZSH_THEME"
    log_info "Docker 설치: $([ $INSTALL_DOCKER == true ] && echo '예' || echo '아니오')"
    log_info "Node.js 설치: $([ $INSTALL_NODEJS == true ] && echo '예' || echo '아니오')"
    log_info "Python 설치: $([ $INSTALL_PYTHON == true ] && echo '예' || echo '아니오')"
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
load_config  # 설정 로드 추가
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

# Git 설정 - 설정 파일의 값 사용
log_info "Git 전역 설정 중..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main
git config --global core.editor "nano"
check_status "Git 설정"

# Zsh & Oh-My-Zsh 설치
log_info "Zsh 및 Oh-My-Zsh 설치 중..."
sudo apt install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)
check_status "Zsh 및 Oh-My-Zsh 설치"

# Zsh 테마 설정
if [ -f "$HOME/.zshrc" ]; then
    log_info "Zsh 테마를 $ZSH_THEME로 설정 중..."
    sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"$ZSH_THEME\"/" "$HOME/.zshrc"
    check_status "Zsh 테마 설정"
fi

# NVM 및 Node.js 설치 - 설정에 따라 조건부 실행
if [ "$INSTALL_NODEJS" = true ]; then
    log_info "NVM 및 Node.js 설치 중..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm install --lts
    check_status "Node.js 설치"
else
    log_info "Node.js 설치를 건너뜁니다."
fi

# Docker 설치 - 설정에 따라 조건부 실행
if [ "$INSTALL_DOCKER" = true ]; then
    log_info "Docker 설치 중..."
    sudo apt install -y docker.io
    sudo usermod -aG docker ${USER}
    check_status "Docker 설치"
else
    log_info "Docker 설치를 건너뜁니다."
fi

# Python 개발 환경 설치 - 설정에 따라 조건부 실행
if [ "$INSTALL_PYTHON" = true ]; then
    log_info "Python 개발 도구 설치 중..."
    sudo apt install -y python3-pip python3-venv
    check_status "Python 개발 도구 설치"
else
    log_info "Python 개발 도구 설치를 건너뜁니다."
fi

# VS Code 서버 설치 (WSL용)
log_info "VS Code 서버 설치 중..."
curl -fsSL https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64 -o vscode_cli.tar.gz
tar -xf vscode_cli.tar.gz
sudo mv code /usr/local/bin/
rm vscode_cli.tar.gz
check_status "VS Code 서버 설치"

log_success "===== 개발 환경 설정 완료! ====="
log_info "변경사항을 적용하려면 터미널을 재시작하거나 'source ~/.zshrc' 명령어를 실행하세요."
