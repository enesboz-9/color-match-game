@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

set REPO=https://github.com/enesboz-9/color-match-game.git
set BRANCH=main

where git >nul 2>nul
if errorlevel 1 (
  echo [HATA] Git bulunamadi. https://git-scm.com adresinden kurun.
  pause
  exit /b 1
)

REM Platform klasorleri yoksa proje henuz olusturulmamis demektir.
if not exist "android" (
  echo [UYARI] android klasoru yok. Once bu klasorde su komutu calistirin:
  echo         flutter create --project-name color_match_game --org com.bnovative .
  echo         flutter pub get
  echo         dart run flutter_launcher_icons
  echo Sonra bu dosyayi tekrar calistirin.
  pause
  exit /b 1
)

REM Klasor bir git deposu degilse: baslat ve uzak depoya bagla
if not exist ".git" (
  echo [BILGI] Git deposu bulunamadi, olusturuluyor...
  git init
  git branch -M %BRANCH%
  git remote add origin %REPO%
  git fetch origin
  if errorlevel 1 (
    echo [HATA] Depoya baglanilamadi. GitHub girisinizi kontrol edin.
    pause
    exit /b 1
  )
  REM Uzak depoda zaten commit varsa gecmisi koru, dosyalar oldugu gibi kalir
  git rev-parse --verify origin/%BRANCH% >nul 2>nul
  if not errorlevel 1 git reset --soft origin/%BRANCH%
) else (
  git remote get-url origin >nul 2>nul || git remote add origin %REPO%
)

git add -A
git status --short

set MSG=Color Match: ilk surum
if not "%~1"=="" set MSG=%*

git commit -m "%MSG%"
if errorlevel 1 echo [BILGI] Yeni degisiklik yok ya da commit atlandi.

git push -u origin %BRANCH%
if errorlevel 1 (
  echo.
  echo [HATA] Push basarisiz. Uzakta yeni degisiklik varsa once: git pull --rebase origin %BRANCH%
  pause
  exit /b 1
)

echo.
echo [TAMAM] GitHub'a gonderildi: %REPO%
pause
