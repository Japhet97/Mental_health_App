# Counsellor Login Credentials

All counsellors can now log in with the password: **counsellor123**

## Available Counsellor Accounts

1. **Dr. John Smith**
   - Email: `dr.smith@yoneco.org`
   - Password: `counsellor123`

2. **Dr. Sarah Jones**
   - Email: `dr.jones@yoneco.org`
   - Password: `counsellor123`

3. **Dr. Michael Wilson**
   - Email: `dr.wilson@yoneco.org`
   - Password: `counsellor123`

4. **Dr. Emily Brown**
   - Email: `dr.brown@yoneco.org`
   - Password: `counsellor123`

5. **Dr. James Davis**
   - Email: `dr.davis@yoneco.org`
   - Password: `counsellor123`

6. **Dr. Jane Doe**
   - Email: `counsellor@yoneco.org`
   - Password: `counsellor123`

## Testing on Mobile

When running the app on a physical device, you need to update the API URL in the app configuration to point to your PC's IP address instead of `localhost`.

### Steps:

1. Find your PC's IP address:
   ```powershell
   ipconfig
   ```
   Look for IPv4 Address (e.g., 192.168.1.100)

2. Update the API URL in both apps:
   - Client app: `yoneco_app\lib\services\api_service.dart`
   - Counsellor app: `yoneco_counsellor_app\lib\services\api_service.dart`
   
   Change:
   ```dart
   static const String baseUrl = 'http://localhost:8080';
   ```
   
   To (replace with your actual IP):
   ```dart
   static const String baseUrl = 'http://192.168.1.100:8080';
   ```

3. Make sure your phone and PC are on the same network

4. Restart the API server and run the app on your device

## Quick Test

You can quickly test any credentials with:

```powershell
cd D:\Projects\yomehe\python_api
python3.13 test_credentials.py "dr.smith@yoneco.org" "counsellor123"
```
