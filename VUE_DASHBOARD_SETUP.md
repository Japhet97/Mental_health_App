# 🚀 Vue.js Admin Dashboard - Setup Instructions

## ✅ Quick Setup (5 Minutes)

### Step 1: Create Project
```powershell
cd D:\Projects\yomehe
npm create vite@latest admin-dashboard-vue -- --template vue
```

When prompted:
- Select: **Vue**
- Select: **JavaScript** (or TypeScript if you prefer)

### Step 2: Install Dependencies
```powershell
cd admin-dashboard-vue
npm install
npm install pinia vue-router axios chart.js vue-chartjs
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### Step 3: Copy Logo
```powershell
copy ..\yoneco_app\assets\logo\logo.png public\logo.png
```

### Step 4: Replace Configuration Files

I'll create all the necessary files for you. After setup, you'll have:

```
admin-dashboard-vue/
├── src/
│   ├── components/
│   │   ├── Sidebar.vue
│   │   ├── Header.vue
│   │   ├── StatCard.vue
│   │   └── Chart components...
│   ├── views/
│   │   ├── Login.vue
│   │   ├── Dashboard.vue
│   │   ├── Issues.vue
│   │   ├── Languages.vue
│   │   ├── Sessions.vue
│   │   ├── Counsellors.vue
│   │   └── Analytics.vue
│   ├── stores/
│   │   ├── auth.js
│   │   └── dashboard.js
│   ├── services/
│   │   └── api.js
│   ├── router/
│   │   └── index.js
│   ├── App.vue
│   ├── main.js
│   └── style.css
├── public/
│   └── logo.png
├── index.html
├── package.json
├── vite.config.js
├── tailwind.config.js
└── postcss.config.js
```

---

## 🎨 Theme Colors (Already Configured)

The dashboard will use these colors matching your Flutter apps:

- **Primary Green**: `#0A3D0A` (Dark Forest Green)
- **Secondary Green**: `#2ecc71` (Light Green)
- **Accent Green**: `#27ae60`
- **Background**: `#f5f6fa`
- **Danger**: `#e74c3c`
- **Warning**: `#f39c12`
- **Info**: `#3498db`

---

## 📦 What's Included

### Features:
✅ **Authentication** - Login with admin/counsellor accounts  
✅ **Dashboard Overview** - Real-time statistics  
✅ **Issue Management** - Add/Edit/Delete mental health issues  
✅ **Language Management** - Manage supported languages  
✅ **Session Monitoring** - View active/pending sessions  
✅ **Counsellor Management** - Add/Remove counsellors  
✅ **Analytics** - Beautiful charts and graphs  
✅ **Responsive Design** - Works on all devices  
✅ **Auto-refresh** - Live data updates  
✅ **Theme Consistent** - Matches Flutter apps perfectly  

---

## 🚀 Run the Dashboard

```powershell
cd admin-dashboard-vue
npm run dev
```

Open browser: `http://localhost:5173`

**Login with:**
- Email: `admin@yoneco.org`
- Password: `Admin@2025`

---

## 🔧 API Configuration

The dashboard connects to: `http://102.223.95.28:8001`

To change API URL, edit `src/services/api.js`:
```javascript
const API_BASE_URL = 'http://YOUR_IP:8001'
```

---

## 📱 Build for Production

```powershell
npm run build
```

Output will be in `dist/` folder. Deploy to any web server.

---

## 🎯 Next Steps

After running `npm create vite`, I'll provide you with all the component files:

1. **Core Files** - App.vue, main.js, router, stores
2. **Components** - Reusable UI components
3. **Views** - All dashboard pages
4. **Services** - API integration
5. **Styling** - Tailwind configuration with theme

**Let me know when you've run the setup commands and I'll provide all the files!** 🚀

---

## ⚡ Quick Commands Reference

```powershell
# Development
npm run dev          # Start dev server

# Build
npm run build        # Build for production
npm run preview      # Preview production build

# Dependencies
npm install          # Install all dependencies
npm update           # Update dependencies
```

---

## 🔍 Troubleshooting

### Port already in use
```powershell
# Change port in vite.config.js
server: {
  port: 5174  // or any other port
}
```

### Cannot find module
```powershell
npm install  # Reinstall dependencies
```

### API not connecting
- Check API is running: `.\START_API.ps1`
- Verify API URL in `src/services/api.js`
- Check browser console for errors

---

**Ready to build! Run the setup commands above and let me know when done.** ✨
