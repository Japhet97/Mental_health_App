# Quick Test Guide - New Features

## 🎯 What's New

✅ **Multilingual Support**: English & Chichewa
✅ **New Splash Screens**: White background with green YONECO branding  
✅ **Typing Indicators**: Real-time "...is typing" messages
✅ **Session Timers**: Track conversation duration

---

## 🚀 How to Test (Web - Easiest)

### Step 1: Start the API
```bash
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

### Step 2: Run Client App
```bash
cd D:\Projects\yomehe\yoneco_app
flutter run -d chrome
```

### Step 3: Run Counsellor App (in another terminal)
```bash
cd D:\Projects\yomehe\yoneco_counsellor_app  
flutter run -d chrome --web-port 8081
```

---

## 📱 Testing the New Features

### Test 1: Multilingual Support

**Client App:**
1. Launch app → See new **white splash screen** with green text
2. After 3 seconds → **Language selection** appears
3. Tap **"English"** → green border highlights selection
4. Tap **"Continue"** → Welcome screen in English
5. Tap **language icon** (🌐) in top-right → Go back to language selection
6. Select **"Chichewa"** → Welcome screen now in Chichewa
7. Tap **"Yambani"** (Get Started)
8. See issues in Chichewa: **Kukhumudwa**, **Nkhawa**, etc.

**Verify:**
- [ ] Splash screen is white with green text
- [ ] Language selection shows both options
- [ ] Welcome message changes when language changes
- [ ] Issues translate correctly
- [ ] Language persists if you reload the app

---

### Test 2: Typing Indicators

**Setup:**
1. **Client App**: Select an issue → Create session
2. **Counsellor App**: Login → Accept the session
3. Open both chat screens side-by-side

**Test:**
1. **In Client App**: Start typing a message (don't send yet)
2. **In Counsellor App**: Should see animated dots **"Client is typing..."**
3. **In Client App**: Stop typing (wait 2 seconds)
4. **In Counsellor App**: Typing indicator disappears
5. **Reverse**: Counsellor types → Client sees **"Counsellor is typing..."** or **"Mlangizi akulemba..."** (if Chichewa selected)

**Verify:**
- [ ] Typing indicators appear within 1 second
- [ ] Animated dots show correctly
- [ ] Indicator disappears 2 seconds after typing stops
- [ ] Works in both languages
- [ ] Works bidirectionally (client ↔ counsellor)

---

### Test 3: Session Timer

**Setup:**
1. Create and accept a session as above
2. Open chat screen (both client and counsellor)

**Test:**
1. Look at **AppBar** → See timer **"00:00"**
2. Wait 1 minute → Timer shows **"01:00"**
3. Wait longer → Timer continues: **"01:30"**, **"02:00"**, etc.
4. Send messages → Timer keeps running
5. Close session → Timer stops

**Verify:**
- [ ] Timer starts at 00:00 when session begins
- [ ] Updates every second
- [ ] Shows in MM:SS format
- [ ] Visible in both client and counsellor apps
- [ ] Doesn't reset when messages are sent
- [ ] Stops when session ends

---

### Test 4: Complete User Journey (English)

**Client Side:**
1. ✅ Launch → White splash with "Welcome to YONECO"
2. ✅ Select Language → Choose **English**
3. ✅ Welcome Screen → "Welcome to YONECO Mental Health Support"
4. ✅ Get Started → See issues in English
5. ✅ Select "Anxiety" → Create session
6. ✅ Waiting screen → "Waiting for counsellor to join..."
7. ✅ Type message → See timer start (00:01, 00:02...)

**Counsellor Side:**
1. ✅ Launch → White splash "YONECO Counsellor Portal"
2. ✅ Login → Use credentials: `dr.smith@yoneco.org` / `SecurePass123!`
3. ✅ Dashboard → See pending session with "Anxiety"
4. ✅ Accept Session → Chat opens
5. ✅ Type message → Client sees "Counsellor is typing..."
6. ✅ Send message → Client receives instantly
7. ✅ Check timer → Shows duration (00:45, 01:00, etc.)

**Verify:**
- [ ] Complete flow works smoothly
- [ ] No errors in console
- [ ] Real-time communication works
- [ ] All new features visible

---

### Test 5: Complete User Journey (Chichewa)

**Client Side:**
1. ✅ Launch → Splash "Takulandirani ku YONECO"
2. ✅ Select Language → Choose **Chichewa**
3. ✅ Welcome Screen → "Takulandirani ku YONECO"
4. ✅ Yambani → See issues: "Kukhumudwa", "Nkhawa", etc.
5. ✅ Select "Nkhawa" (Anxiety) → Create session
6. ✅ Waiting → "Tikudikirira mlangizi..."
7. ✅ Chat → Interface in Chichewa

**Counsellor Side:**
1. ✅ Same as English (counsellor app is English-only)
2. ✅ Issue shows as "Nkhawa" in session list
3. ✅ Communication works the same

**Verify:**
- [ ] All client UI in Chichewa
- [ ] Issue name preserved through system
- [ ] Chat works with Chichewa interface

---

## 🎨 Visual Verification

### Splash Screen Checklist:
- [ ] **Background**: Pure white
- [ ] **Icon**: Green heart (client) or brain (counsellor) in circle
- [ ] **Text**: "Welcome to" in small font
- [ ] **Title**: "YONECO" in large bold green
- [ ] **Subtitle**: "Mental Health Support" or "Counsellor Portal"
- [ ] **Tagline**: In rounded green-tinted box
- [ ] **Loader**: Green circular progress indicator
- [ ] **Animation**: Smooth fade-in and scale effect

### Language Selection Checklist:
- [ ] **Title**: "Select Language / Sankhani Chilankhulo"
- [ ] **Cards**: Two options with icons
- [ ] **Selection**: Green border (3px) on selected
- [ ] **Background tint**: Light green on selected
- [ ] **Checkmark**: Green ✓ on selected option
- [ ] **Button**: "Continue / Pitirizani" at bottom

---

## 🐛 Common Issues & Solutions

### Issue 1: "shared_preferences not found"
**Solution:**
```bash
cd D:\Projects\yomehe\yoneco_app
flutter pub get
flutter clean
flutter run
```

### Issue 2: Language doesn't persist
**Solution:** 
- Clear app data/cache
- Ensure `shared_preferences` is installed
- Check browser local storage (for web)

### Issue 3: Typing indicator doesn't show
**Solution:**
- Check WebSocket connection is active
- Verify API is running on port 8080
- Check browser console for errors

### Issue 4: Timer doesn't update
**Solution:**
- Ensure chat screen is mounted
- Check `_startTimer()` is called in `initState()`
- Verify no exceptions in console

### Issue 5: Translations missing
**Solution:**
- Check `language_service.dart` has all keys
- Verify language code matches ('en' or 'ny')
- Fallback to English if key not found

---

## 📊 Performance Checklist

- [ ] Splash screen loads in < 1 second
- [ ] Language selection is instant
- [ ] Translations load without delay
- [ ] Typing indicators appear immediately (< 500ms)
- [ ] Timer updates smoothly every second
- [ ] No memory leaks (check DevTools)
- [ ] WebSocket stable (no disconnections)

---

## 🎯 Key Testing Points

### Must Work:
1. ✅ Both languages switch correctly
2. ✅ Splash screens look professional
3. ✅ Typing indicators are real-time
4. ✅ Session timers count accurately
5. ✅ No crashes or errors
6. ✅ Language persists on reload

### Nice to Have:
- Smooth animations
- Fast loading times
- Clean console (no warnings)
- Responsive design

---

## 📞 Test Credentials

**Counsellor Login:**
- Email: `dr.smith@yoneco.org`
- Password: `SecurePass123!`

---

## ✅ Success Criteria

**Client App:**
- [x] White/green splash screen displays
- [x] Language selection works
- [x] All screens translate
- [x] Typing indicators show
- [x] Session timer runs

**Counsellor App:**
- [x] White/green splash screen displays
- [x] Login works
- [x] Typing indicators show
- [x] Session timer runs
- [x] Can chat with client

**System:**
- [x] Real-time communication
- [x] No errors in console
- [x] Language persists
- [x] Professional appearance

---

## 🎉 Testing Complete!

If all checkboxes above are checked, congratulations! 🎊

The system is ready with:
- ✅ Bilingual support (English & Chichewa)
- ✅ Professional branding (white & green)
- ✅ Real-time features (typing, timer)
- ✅ Smooth user experience

---

**Next**: Test on mobile devices or proceed with additional features!
