# Testing Guide: Typing Indicators & Session Timer

## Quick Start

### 1. Restart the API (if needed)
The API should already be running. If you need to restart:

```powershell
cd D:\Projects\yomehe\python_api
python3.13 -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

### 2. Test on Web (Easiest)

#### Client App:
```powershell
cd D:\Projects\yomehe\yoneco_app
flutter run -d chrome
```

#### Counsellor App (in another terminal):
```powershell
cd D:\Projects\yomehe\yoneco_counsellor_app
flutter run -d chrome
```

### 3. Test the Features

#### Session Timer Test:
1. **Client Side:** Select an issue and create a session
2. **Look at the app bar** - You should see a timer like `00:00` below the issue
3. **Wait 5 seconds** - Timer should update to `00:05`
4. **Counsellor Side:** Accept the session
5. **Look at the app bar** - Timer should start from `00:00`
6. Both timers update independently every second

#### Typing Indicator Test:
1. **Client Side:** Start typing in the message box (don't send)
2. **Counsellor Side:** You should see animated dots with "..." 
3. **Client Side:** Stop typing for 2 seconds
4. **Counsellor Side:** Dots should disappear
5. **Counsellor Side:** Now you type
6. **Client Side:** You should see the typing indicator
7. **Either Side:** Send a message - typing indicator disappears immediately

## What You Should See

### Session Timer Display:
```
┌─────────────────────────┐
│    Counsellor Chat      │
│   Issue: Depression     │
│        01:23           │  ← Timer here
└─────────────────────────┘
```

### Typing Indicator:
```
┌────────────────────────┐
│ Message 1              │
│ Message 2              │
│ ┌────────┐             │
│ │ • • • │             │  ← Animated dots
│ └────────┘             │
└────────────────────────┘
```

## Expected Behavior

### Typing Indicators:
- ✅ Appears when other person starts typing
- ✅ Disappears after 2 seconds of no typing
- ✅ Disappears immediately when message is sent
- ✅ Three dots with pulsing animation
- ✅ Only shows for the OTHER person (not your own typing)

### Session Timer:
- ✅ Starts at `00:00` when chat opens
- ✅ Updates every second
- ✅ Format: `MM:SS` (e.g., `01:30` = 1 min 30 sec)
- ✅ Visible in app bar below issue
- ✅ Each participant has independent timer

## Troubleshooting

### Typing Indicator Not Showing:
1. Check browser console for errors
2. Verify WebSocket connection is established
3. Try sending a regular message first (to confirm WebSocket works)
4. Check that you're typing in the OTHER app (indicator only shows for other person)

### Timer Not Updating:
1. Check that the screen hasn't frozen
2. Look for any console errors
3. Timer starts when screen opens - try closing and reopening chat

### API Errors:
```powershell
# Check API is running:
curl http://localhost:8080/docs

# Should show the FastAPI documentation page
```

## Testing Checklist

- [ ] Client timer starts and updates
- [ ] Counsellor timer starts and updates
- [ ] Client typing → Counsellor sees indicator
- [ ] Counsellor typing → Client sees indicator
- [ ] Typing stops after 2 seconds
- [ ] Typing stops after sending message
- [ ] Messages still send normally
- [ ] Session still closes properly
- [ ] No console errors

## Console Commands for Testing

### Check WebSocket connections:
```javascript
// In browser console (Chrome DevTools)
// Open while on chat screen
console.log(performance.getEntriesByType('resource').filter(r => r.name.includes('ws://')));
```

### Monitor typing events:
Look for these in API console:
```
INFO: ... - "POST /chat/1/typing HTTP/1.1" 200 OK
```

## Test Credentials

**Counsellor Login:**
- Email: `dr.smith@yoneco.org`
- Password: `SecurePass123!`

## Next Steps After Testing

If everything works:
1. ✅ Mark features as tested
2. ✅ Document any issues found
3. ✅ Consider additional features (read receipts, etc.)

If issues found:
1. Note the specific issue
2. Check browser console and API logs
3. Verify the exact steps to reproduce
4. Report for debugging

## Additional Features to Consider

Based on testing experience, you might want to add:
1. **"Counsellor is online"** indicator
2. **Message read receipts** (seen/unseen)
3. **Sound notification** when typing starts
4. **Session timeout warning** (e.g., "30 minutes elapsed")
5. **Auto-save draft messages** if connection lost

## Success Criteria

✅ **All features working** = Both apps show typing indicators in real-time and session timers update correctly

🎉 **Ready for production** when all items in Testing Checklist are checked!
