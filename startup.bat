@echo off
title Sistema de Impressoras LT3 - Iniciando...
color 0A
echo.
echo ============================================
echo   SISTEMA DE IMPRESSORAS LT3
echo   Desenvolvido pelo Setor de Tecnologia
echo ============================================
echo.
:: ── CONFIGURACOES ──────────────────────────────────────
set REPO=https://github.com/qzsousa/contador-lt3.git
set PASTA=C:\contador-lt3-master\contador-lt3-master\frontend
set PORTA=8080
set LOG=%PASTA%\startup_log.txt

:: ── AGUARDA REDE ANTES DE CONTINUAR (com limite) ───────
echo [1/4] Aguardando conexao de rede...
set TENTATIVAS=0
set MAX_TENTATIVAS=12
:AGUARDA_REDE
set /a TENTATIVAS+=1
powershell -Command "(Test-NetConnection github.com -Port 443 -WarningAction SilentlyContinue).TcpTestSucceeded" > "%TEMP%\netcheck.txt" 2>nul
findstr /i "True" "%TEMP%\netcheck.txt" >nul
if errorlevel 1 (
    if %TENTATIVAS% geq %MAX_TENTATIVAS% (
        echo       AVISO: sem rede apos %MAX_TENTATIVAS% tentativas. Prosseguindo sem atualizar.
        echo [%date% %time%] Sem rede apos %MAX_TENTATIVAS% tentativas >> "%LOG%"
        goto REDE_FIM
    )
    echo       Tentativa %TENTATIVAS%/%MAX_TENTATIVAS% sem sucesso, aguardando 5s...
    timeout /t 5 /nobreak >nul
    goto AGUARDA_REDE
)
echo       Rede OK.
:REDE_FIM
echo.

:: ── GIT PULL (com timeout) ──────────────────────────────
echo [2/4] Atualizando arquivos do repositorio...
cd /d "%PASTA%"
set GIT_HTTP_LOW_SPEED_LIMIT=1000
set GIT_HTTP_LOW_SPEED_TIME=10

start /min cmd /c "git pull origin main > "%LOG%.pull" 2>&1"
set WAITED=0
:WAIT_PULL
tasklist /fi "imagename eq git.exe" 2>nul | find /i "git.exe" >nul
if not errorlevel 1 (
    if %WAITED% geq 20 (
        echo       AVISO: git pull demorando demais, encerrando...
        taskkill /f /im git.exe >nul 2>&1
        goto PULL_FIM
    )
    set /a WAITED+=2
    timeout /t 2 /nobreak >nul
    goto WAIT_PULL
)
:PULL_FIM
echo       Git pull finalizado (ver log em %LOG%.pull se necessario).
echo.

:: ── MATA PROCESSO NA PORTA 8080 ────────────────────────
echo [3/4] Verificando porta %PORTA%...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":%PORTA% " ^| find "LISTENING"') do (
    echo       Encerrando processo %%a na porta %PORTA%...
    taskkill /PID %%a /F >nul 2>&1
)
echo       Porta %PORTA% liberada.
echo.

:: ── INICIA SERVIDOR PYTHON ─────────────────────────────
echo [4/4] Iniciando servidor na porta %PORTA%...
echo.
:: Descobre o IP local automaticamente
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| find "IPv4"') do (
    set IP=%%a
    goto :IP_FOUND
)
:IP_FOUND
set IP=%IP: =%
echo ============================================
echo   SERVIDOR RODANDO
echo.
echo   Acesso local:   http://localhost:%PORTA%
echo   Acesso na rede: http://%IP%:%PORTA%
echo ============================================
echo.
:: Notificacao balloon no Windows
powershell -Command ^
  "$n = New-Object System.Windows.Forms.NotifyIcon;" ^
  "$n.Icon = [System.Drawing.SystemIcons]::Information;" ^
  "$n.Visible = $true;" ^
  "$n.BalloonTipTitle = 'Impressoras LT3';" ^
  "$n.BalloonTipText = 'Servidor iniciado! Acesse: http://%IP%:%PORTA%';" ^
  "$n.ShowBalloonTip(5000);" ^
  "Start-Sleep -s 6;" ^
  "$n.Dispose()" >nul 2>&1
:: Inicia o servidor (mantém janela aberta)
python -m http.server %PORTA%
pause
