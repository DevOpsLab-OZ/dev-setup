# 개인 개발 환경 자동화 프로젝트

개발 환경 설정을 자동화한 프로젝트입니다.

## 환경 구성 요소

- **운영체제**: Ubuntu 22.04 LTS on WSL2
- **셸**: Zsh + Oh-My-Zsh
- **버전 관리**: Git
- **개발 도구**: VS Code, Node.js, Python, Docker
- **자동화**: 셸 스크립트

## 설치 방법

1. WSL2 설치 및 Ubuntu 22.04 설정
   ```bash
   # Windows PowerShell에서 실행 (관리자 권한)
   wsl --install -d Ubuntu-22.04
   ```

2. 개발 환경 자동화 스크립트 실행
   ```bash
   # 저장소 클론
   git clone https://github.com/DevOpsLab-OZ/dev-setup.git
   cd dev-setup
   
   # 스크립트 실행 권한 부여
   chmod +x setup.sh
   
   # 스크립트 실행
   ./setup.sh
   ```

3. Dotfiles 설치
   ```bash
   git clone https://github.com/사용자이름/dotfiles.git
   cd dotfiles
   ./install.sh
   ```

4. VS Code 확장 프로그램 설치
   ```bash
   cd dev-setup/vscode
   ./vscode-extensions.sh
   ```

## 작업 흐름

1. 새 프로젝트 시작:
   ```bash
   cd ~/projects/personal
   mkdir 새프로젝트명
   cd 새프로젝트명
   git init
   code .
   ```

2. Docker 컨테이너 실행:
   ```bash
   docker run -it ubuntu bash
   ```

3. Node.js 프로젝트 시작:
   ```bash
   npm init -y
   ```

4. Python 가상 환경 생성:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

## 참고 자료

- [Ubuntu 공식 문서](https://help.ubuntu.com/)
- [WSL2 설명서](https://docs.microsoft.com/windows/wsl/)
- [Git 문서](https://git-scm.com/doc)
- [VS Code 사용자 가이드](https://code.visualstudio.com/docs)
