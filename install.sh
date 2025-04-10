#!/bin/bash

# 개발 환경 자동화 스크립트
echo "===== 개발 환경 자동화 스크립트 시작 ====="

# 시스템 업데이트
echo "시스템 업데이트 중..."
sudo apt update && sudo apt upgrade -y

# 기본 개발 도구 설치
echo "기본 개발 도구 설치 중..."
sudo apt install -y build-essential git curl wget unzip
   
# 개발 디렉토리 생성
echo "개발 디렉토리 생성 중..."
mkdir -p ~/projects/personal
mkdir -p ~/projects/work
mkdir -p ~/projects/learning

echo "===== 기본 설치 완료 ====="


