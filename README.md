# Dev-Setup: 개발 환경 자동화 프로젝트

개발 환경 설정을 자동화하여 새로운 시스템에서 빠르고 일관되게 개발 환경을 구축할 수 있도록 돕는 프로젝트를 진행하였습니다.

## 주요 기능

- WSL2 기반 Ubuntu 환경 자동 구성
- 필수 개발 도구 및 라이브러리 설치
- Git, Zsh, Oh-My-Zsh 자동 설정
- 프로그래밍 언어 환경 (Node.js, Python) 설정
- Docker 개발 환경 구성
- VS Code 설정 및 확장 프로그램 자동 설치

## 시스템 요구사항

- Ubuntu 22.04 LTS (WSL2 또는 네이티브)
- 관리자 권한 (sudo)
- 인터넷 연결

## 설치 방법

### 1. WSL2 및 Ubuntu 설정 (Windows 사용자)

Windows PowerShell에서 관리자 권한으로 실행:

```bash
wsl --install -d Ubuntu-22.04
```

### 2. 저장소 클론

```bash
git clone https://github.com/DevOpsLab-OZ/dev-setup.git
cd dev-setup
```

### 3. 설정 파일 수정 (선택사항)

설치 옵션과 개인 설정을 조정하려면 `config.yaml` 파일을 수정하세요:

```bash
nano config.yaml
```

### 4. 자동화 스크립트 실행

```bash
# 스크립트 실행 권한 부여
chmod +x setup.sh

# 스크립트 실행
./setup.sh
```

### 5. VS Code 확장 프로그램 설치

```bash
cd vscode
chmod +x vscode-extensions.sh
./vscode-extensions.sh
```

대화형 모드로 확장 프로그램을 선택적으로 설치하려면:

```bash
./vscode-extensions.sh --interactive
```

## 주요 구성 요소

- **setup.sh**: 주요 개발 환경 자동화 스크립트
- **config.yaml**: 환경 설정 값 (Git 사용자 정보, 설치 옵션 등)
- **vscode/vscode-extensions.sh**: VS Code 확장 프로그램 설치 스크립트

## 통합 기능

이 프로젝트는 [dotfiles](https://github.com/DevOpsLab-OZ/dotfiles) 저장소를 자동으로 설치하고 구성합니다:

- Git 설정 (.gitconfig)
- Zsh 및 Oh-My-Zsh 설정 (.zshrc)
- 기타 개인 설정 파일

dotfiles 설치를 비활성화하려면 `config.yaml` 파일의 `dotfiles.install` 값을 `false`로 설정하거나 명령행에서 `--no-dotfiles` 옵션을 사용하세요.

## 개발 워크플로우

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

## 명령행 옵션

스크립트는 다음 옵션을 지원합니다:

- `--minimal`: 최소 설치 모드 (기본 도구만 설치)
- `--no-dotfiles`: dotfiles 설치 건너뛰기
- `--help`, `-h`: 도움말 표시

예시:
```bash
./setup.sh --minimal  # 최소한의 도구만 설치
./setup.sh --no-dotfiles  # dotfiles 설치 건너뛰기
```

## 문제 해결

- **스크립트 실행 권한 오류**: `chmod +x 스크립트명.sh`으로 실행 권한을 부여하세요.
- **APT 패키지 설치 실패**: `sudo apt update`를 실행하여 패키지 목록을 갱신하세요.
- **권한 문제**: 필요에 따라 `sudo` 명령어를 사용하여 스크립트를 실행하세요.

## 참고 자료

- [Ubuntu 공식 문서](https://help.ubuntu.com/)
- [WSL2 설명서](https://docs.microsoft.com/windows/wsl/)
- [Git 문서](https://git-scm.com/doc)
- [VS Code 사용자 가이드](https://code.visualstudio.com/docs)

## 라이선스

MIT License - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.
