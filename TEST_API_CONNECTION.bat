@echo off
echo.
echo ========================================
echo  Testing Tithandizane API Connection
echo ========================================
echo.

REM Kill any process on port 6000
echo Step 1: Checking port 6000...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :6000') do (
    echo Found process: %%a
    echo Stopping old process...
    taskkill /F /PID %%a 2>nul
)

timeout /t 2 >nul

echo.
echo Step 2: Starting API on port 6000...
cd /d D:\Projects\yomehe\python_api
start "Tithandizane API" cmd /k "python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 6000"

echo.
echo Waiting for API to start...
timeout /t 5 >nul

echo.
echo Step 3: Testing connection...
curl http://localhost:6000/docs

echo.
echo ========================================
echo If you see HTML above, API is working!
echo If not, check the API window for errors
echo ========================================
echo.
pause
