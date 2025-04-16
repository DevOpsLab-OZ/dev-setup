#!/bin/bash

# VS Code 확장 프로그램 설치 스크립트

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

# VS Code 확인 함수
check_vscode() {
    if ! command -v code &> /dev/null; then
        log_error "VS Code가 설치되어 있지 않습니다."
        log_info "VS Code를 먼저 설치하거나 시스템 경로에 추가해주세요."
        return 1
    fi
    
    return 0
}

# 확장 프로그램 설치 함수
install_extension() {
    local extension=$1
    local description=$2
    
    log_info "설치 중: $description ($extension)"
    code --install-extension "$extension" --force
    
    if [ $? -eq 0 ]; then
        log_success "설치 완료: $description"
        return 0
    else
        log_error "설치 실패: $extension"
        return 1
    fi
}

# 확장 프로그램 설치 함수 (대화형)
install_extensions_interactive() {
    local installed=0
    local failed=0
    
    # 카테고리별 확장 프로그램 배열
    declare -A categories
    categories["개발 환경"]="ms-vscode-remote.remote-wsl ms-vscode-remote.remote-containers"
    categories["프로그래밍 언어"]="ms-python.python ms-vscode.cpptools dbaeumer.vscode-eslint"
    categories["개발 도구"]="esbenp.prettier-vscode ritwickdey.liveserver ms-azuretools.vscode-docker"
    categories["AI 도우미"]="github.copilot"
    
    # 확장 프로그램 설명
    declare -A descriptions
    descriptions["ms-vscode-remote.remote-wsl"]="WSL 연동"
    descriptions["ms-vscode-remote.remote-containers"]="컨테이너 연동"
    descriptions["ms-python.python"]="Python 지원"
    descriptions["ms-vscode.cpptools"]="C/C++ 지원"
    descriptions["dbaeumer.vscode-eslint"]="JavaScript 린트"
    descriptions["esbenp.prettier-vscode"]="코드 포맷터"
    descriptions["ritwickdey.liveserver"]="웹 개발용 라이브 서버"
    descriptions["ms-azuretools.vscode-docker"]="Docker 지원"
    descriptions["github.copilot"]="GitHub Copilot (AI 코드 생성)"
    
    log_info "VS Code 확장 프로그램 설치를 시작합니다."
    
    # 카테고리별 설치
    for category in "${!categories[@]}"; do
        echo -e "\n${BLUE}==== $category ====${NC}"
        
        # 카테고리 내 확장 프로그램 목록
        extensions=(${categories[$category]})
        
        for extension in "${extensions[@]}"; do
            description=${descriptions[$extension]}
            
            # 사용자에게 설치 여부 확인
            read -p "$(echo -e "${YELLOW}$description${NC} 확장을 설치하시겠습니까? [Y/n] ")" answer
            
            # 기본값은 Yes
            if [[ "$answer" == "" || "$answer" =~ ^[Yy]$ ]]; then
                install_extension "$extension" "$description"
                
                if [ $? -eq 0 ]; then
                    ((installed++))
                else
                    ((failed++))
                fi
            else
                log_info "$description 설치를 건너뜁니다."
            fi
        done
    done
    
    # 설치 요약
    echo -e "\n${BLUE}===== 설치 요약 =====${NC}"
    log_info "설치 완료: $installed 개"
    if [ $failed -gt 0 ]; then
        log_warning "설치 실패: $failed 개"
    fi
    
    log_success "VS Code 확장 프로그램 설치가 완료되었습니다."
}

# 확장 프로그램 일괄 설치 함수 (비대화형)
install_extensions_noninteractive() {
    local installed=0
    local failed=0
    
    # 기본 확장 프로그램 목록
    extensions=(
        "ms-vscode-remote.remote-wsl:WSL 연동"
        "ms-python.python:Python 지원"
        "dbaeumer.vscode-eslint:JavaScript 린트"
        "esbenp.prettier-vscode:코드 포맷터"
        "ms-azuretools.vscode-docker:Docker 지원"
        "ritwickdey.liveserver:웹 개발용 라이브 서버"
        "ms-vscode.cpptools:C/C++ 지원"
    )
    
    log_info "VS Code 확장 프로그램 일괄 설치를 시작합니다."
    
    # 각 확장 프로그램 설치
    for item in "${extensions[@]}"; do
        # ID와 설명 분리
        IFS=':' read -r extension description <<< "$item"
        
        install_extension "$extension" "$description"
        
        if [ $? -eq 0 ]; then
            ((installed++))
        else
            ((failed++))
        fi
    done
    
    # 설치 요약
    echo -e "\n${BLUE}===== 설치 요약 =====${NC}"
    log_info "설치 완료: $installed 개"
    if [ $failed -gt 0 ]; then
        log_warning "설치 실패: $failed 개"
    fi
    
    log_success "VS Code 확장 프로그램 설치가 완료되었습니다."
}

# 메인 함수
main() {
    echo -e "${BLUE}===== VS Code 확장 프로그램 설치 스크립트 =====${NC}"
    
    # VS Code 설치 확인
    check_vscode || exit 1
    
    # 명령행 인자 처리
    if [ "$1" == "--interactive" ] || [ "$1" == "-i" ]; then
        # 대화형 모드
        install_extensions_interactive
    else
        if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
            # 도움말 표시
            echo "사용법: $(basename "$0") [옵션]"
            echo ""
            echo "옵션:"
            echo "  -i, --interactive    대화형 모드로 확장 프로그램 설치"
            echo "  -h, --help           도움말 표시"
            echo "  (옵션 없음)          기본 확장 프로그램 자동 설치"
            exit 0
        else
            # 비대화형 모드 (기본)
            install_extensions_noninteractive
        fi
    fi
}

# 스크립트 실행
main "$@"
