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
    INSTALL_DOTFILES=true
    DOTFILES_REPO="https://github.com/DevOpsLab-OZ/dotfiles.git"
    DOTFILES_PATH="$HOME/dotfiles"
    
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

# dotfiles 설정
dotfiles:
  install: true     # dotfiles 저장소 설치 여부
  repository: "https://github.com/DevOpsLab-OZ/dotfiles.git"  # dotfiles 저장소 URL
  path: "\$HOME/dotfiles"  # 설치 경로
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
        
        # dotfiles 설정
        if grep -q "dotfiles:" "$CONFIG_FILE"; then
            if grep -q "install:[[:space:]]*false" "$CONFIG_FILE"; then
                INSTALL_DOTFILES=false
            fi
            
            repo_line=$(grep -A2 "dotfiles:" "$CONFIG_FILE" | grep "repository:" | cut -d: -f2-)
            if [ -n "$repo_line" ]; then
                DOTFILES_REPO=$(echo $repo_line | sed 's/^[[:space:]]*//;s/"//g')
            fi
            
            path_line=$(grep -A3 "dotfiles:" "$CONFIG_FILE" | grep "path:" | cut -d: -f2-)
            if [ -n "$path_line" ]; then
                DOTFILES_PATH=$(echo $path_line | sed 's/^[[:space:]]*//;s/"//g')
                # 환경 변수 확장 (예: $HOME을 실제 홈 디렉토리로)
                DOTFILES_PATH=$(eval echo "$DOTFILES_PATH")
            fi
        fi
    fi
    
    log_info "설정 로드 완료"
    log_info "Git 사용자: $GIT_NAME ($GIT_EMAIL)"
    log_info "Zsh 테마: $ZSH_THEME"
    log_info "Docker 설치: $([ $INSTALL_DOCKER == true ] && echo '예' || echo '아니오')"
    log_info "Node.js 설치: $([ $INSTALL_NODEJS == true ] && echo '예' || echo '아니오')"
    log_info "Python 설치: $([ $INSTALL_PYTHON == true ] && echo '예' || echo '아니오')"
    log_info "dotfiles 설치: $([ $INSTALL_DOTFILES == true ] && echo '예' || echo '아니오')"
    if [ "$INSTALL_DOTFILES" = true ]; then
        log_info "dotfiles 저장소: $DOTFILES_REPO"
        log_info "dotfiles 경로: $DOTFILES_PATH"
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

# 진행 표시 함수
show_progress() {
    local step=$1
    local total=$2
    local percent=$((step * 100 / total))
    local width=40
    local completed=$((width * step / total))
    
    printf "\r[${YELLOW}"
    for ((i=0; i<completed; i++)); do printf "="; done
    printf ">"
    for ((i=completed; i<width; i++)); do printf " "; done
    printf "${NC}] %3d%% (%d/%d)" $percent $step $total
}

# 명령행 인자 처리
parse_args() {
    MINIMAL_INSTALL=false
    NO_DOTFILES=false

    for arg in "$@"; do
        case $arg in
            --minimal)
                MINIMAL_INSTALL=true
                log_info "최소 설치 모드가 활성화되었습니다."
                ;;
            --no-dotfiles)
                NO_DOTFILES=true
                INSTALL_DOTFILES=false
                log_info "dotfiles 설치를 건너뜁니다."
                ;;
            --help|-h)
                echo "사용법: $(basename "$0") [옵션]"
                echo ""
                echo "옵션:"
                echo "  --minimal       최소 설치 모드 (기본 도구만 설치)"
                echo "  --no-dotfiles   dotfiles 설치 건너뛰기"
                echo "  --help, -h      도움말 표시"
                exit 0
                ;;
            *)
                # 알 수 없는 옵션
                ;;
        esac
    done

    # 최소 설치 모드일 경우 필수 도구만 설치
    if [ "$MINIMAL_INSTALL" = true ]; then
        INSTALL_DOCKER=false
        INSTALL_NODEJS=false
        INSTALL_PYTHON=false
        # 명시적으로 --no-dotfiles가 지정되지 않았다면 dotfiles는 설치
        if [ "$NO_DOTFILES" = false ]; then
            INSTALL_DOTFILES=true
        fi
    fi
}

# 메인 함수 정의
main() {
    echo -e "${BLUE}===== 개발 환경 자동화 스크립트 시작 =====${NC}"
    
    # 명령행 인자 처리
    parse_args "$@"
    
    # 백업 생성 및 설정 로드
    load_config
    create_backup
    
    # 총 단계 수 및 현재 단계 초기화
    total_steps=9  # 주요 단계 수 (dotfiles 포함)
    current_step=0
    
    # 스크립트 시작
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
    log_info "시스템 업데이트 중..."
    sudo apt update && sudo apt upgrade -y
    check_status "시스템 업데이트"
    
    # 기본 개발 도구 설치
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
    log_info "기본 개발 도구 설치 중..."
    sudo apt install -y build-essential git curl wget unzip software-properties-common apt-transport-https ca-certificates
    check_status "기본 개발 도구 설치"
    
    # 개발 디렉토리 생성
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
    log_info "개발 디렉토리 구조 생성 중..."
    mkdir -p ~/projects/personal
    mkdir -p ~/projects/work
    mkdir -p ~/projects/learning
    check_status "개발 디렉토리 구조 생성"
    
    # Git 설정
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
    log_info "Git 전역 설정 중..."
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global init.defaultBranch main
    git config --global core.editor "nano"
    check_status "Git 설정"
    
    # Zsh & Oh-My-Zsh 설치
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
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
    
    # NVM 및 Node.js 설치
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
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
    
    # Docker 설치
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
    if [ "$INSTALL_DOCKER" = true ]; then
        log_info "Docker 설치 중..."
        sudo apt install -y docker.io
        sudo usermod -aG docker ${USER}
        check_status "Docker 설치"
    else
        log_info "Docker 설치를 건너뜁니다."
    fi
    
    # Python 개발 환경 설치
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
    if [ "$INSTALL_PYTHON" = true ]; then
        log_info "Python 개발 도구 설치 중..."
        sudo apt install -y python3-pip python3-venv
        check_status "Python 개발 도구 설치"
    else
        log_info "Python 개발 도구 설치를 건너뜁니다."
    fi
    
    # VS Code 서버 설치
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
    log_info "VS Code 서버 설치 중..."
    curl -fsSL https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64 -o vscode_cli.tar.gz
    tar -xf vscode_cli.tar.gz
    sudo mv code /usr/local/bin/
    rm vscode_cli.tar.gz
    check_status "VS Code 서버 설치"
    
    # dotfiles 설치 및 설정
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps
    log_info "dotfiles 설치 및 설정 중..."
    
    if [ "$INSTALL_DOTFILES" = true ]; then
        # dotfiles 저장소 클론 또는 업데이트
        if [ -d "$DOTFILES_PATH" ]; then
            log_info "기존 dotfiles 저장소 업데이트 중..."
            cd "$DOTFILES_PATH"
            git pull origin main
            cd - > /dev/null
        else
            log_info "dotfiles 저장소 클론 중..."
            git clone "$DOTFILES_REPO" "$DOTFILES_PATH"
        fi
        
        # dotfiles 설치 스크립트 실행
        if [ -f "$DOTFILES_PATH/install.sh" ]; then
            log_info "dotfiles 설치 스크립트 실행 중..."
            cd "$DOTFILES_PATH"
            chmod +x install.sh
            
            # Git 및 Zsh 설정 전달
            export SETUP_GIT_NAME="$GIT_NAME"
            export SETUP_GIT_EMAIL="$GIT_EMAIL"
            export SETUP_ZSH_THEME="$ZSH_THEME"
            
            ./install.sh --from-setup
            cd - > /dev/null
        fi
        
        check_status "dotfiles 설치 및 설정"
    else
        log_info "dotfiles 설치를 건너뜁니다."
    fi
    
    # 줄바꿈 (진행 표시줄 다음에 출력하기 위함)
    echo
    
    log_success "===== 개발 환경 설정 완료! ====="
    log_info "변경사항을 적용하려면 터미널을 재시작하거나 'source ~/.zshrc' 명령어를 실행하세요."
}

# 메인 함수 실행
main "$@"
