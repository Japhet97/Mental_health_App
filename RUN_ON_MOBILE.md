# Run Apps on Mobile Devices

## Current Setup
- **PC IP Address**: 102.223.95.6
- **API Port**: 8080
- **Both apps configured to use**: http://102.223.95.6:8080

## Steps to Run

### 1. Start the API on your PC
```bash
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

**Important**: The `--host 0.0.0.0` allows the API to accept connections from any device on your network.

### 2. Connect Your Phone(s) to the Same WiFi Network
- Make sure your mobile devices are connected to the **same WiFi network** as your PC
- Your PC's firewall must allow incoming connections on port 8080

### 3. Run Client App on Mobile Device
```bash
cd D:\Projects\yomehe\yoneco_app
flutter run
```
- Select your connected Android/iOS device when prompted
- The app will use http://102.223.95.6:8080 to connect to the API

### 4. Run Counsellor App on Another Mobile Device
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run
```
- Select your connected Android/iOS device when prompted
- Login with: dr.smith@yoneco.org / DrSmith123!

## Troubleshooting

### If connection fails:
1. **Check PC Firewall**: Windows Firewall might block port 8080
   ```powershell
   # Allow port 8080 in Windows Firewall
   New-NetFirewallRule -DisplayName "YONECO API" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
   ```

2. **Verify IP Address**: Your PC's IP might change
   ```powershell
   ipconfig | Select-String -Pattern "IPv4"
   ```
   If IP changed, update both app_config.dart files

3. **Test API from Phone Browser**: 
   - Open browser on your phone
   - Visit: http://102.223.95.6:8080/docs
   - You should see the API documentation

### Check Connected Devices
```bash
flutter devices
```

### Run on Specific Device
```bash
# List all devices first
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Current Credentials

### Counsellor Login
- Email: dr.smith@yoneco.org
- Password: DrSmith123!

### Client App
- No login required (anonymous access)
- Just select an issue and start chatting
