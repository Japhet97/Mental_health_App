@echo off
echo Starting YONECO Mental Health API Server...
cd /d "d:\Work\YONECO Mental Health App\yomehe\python_api"
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8001
pause