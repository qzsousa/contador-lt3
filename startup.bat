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

:: ── AGUARDA REDE ANTES DE CONTINUAR ────────────────────
echo [1/4] Aguardando conexao de rede...
:AGUARDA_REDE
ping -n 1 github.com >nul 2>&1
if errorlevel 1 (
    timeout /t 5 /nobreak >nul
    goto AGUARDA_REDE
)
echo       Rede OK.
echo.

:: ── GIT PULL ───────────────────────────────────────────
echo [2/4] Atualizando arquivos do repositorio...
cd /d "%PASTA%"
git pull origin main
if errorlevel 1 (
    echo       AVISO: git pull falhou. Continuando com arquivos locais.
) else (
    echo       Arquivos atualizados com sucesso.
)
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