@echo off
echo.
echo ========================================
echo  Starting Tithandizane API Server
echo ========================================
echo.
cd /d D:\Projects\yomehe\python_api
echo Starting on http://localhost:8080
echo Docs available at http://localhost:8080/docs
echo.
echo Press Ctrl+C to stop
echo.
venv\Scripts\python.exe -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
pause
