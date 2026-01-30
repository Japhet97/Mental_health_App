# 🚀 Admin Dashboard - Quick Start Guide

## ✅ Prerequisites
- Node.js installed
- Python API running on port 8000
- Logo file at `public/logo/logo.png`

---

## 📦 Installation

```powershell
cd admin-dashboard-vue
npm install
```

---

## 🎨 Features Included

### 1. **Modern Login Page**
- Your Tithandizane logo prominently displayed
- Green gradient background matching your brand
- SVG icons for inputs
- Smooth animations

### 2. **Dashboard**
- 4 stat cards (Total Sessions, Active Sessions, Counsellors, Issues)
- Recent activity feed
- Quick action buttons
- Auto-refresh every 30 seconds

### 3. **Issues Management**
- View all mental health issues
- Add new issues (English + Chichewa)
- Delete issues
- Table view with actions

### 4. **Languages Management**
- Manage supported languages
- Add language codes (en, ny, etc.)
- Native name display

### 5. **Sessions Monitor**
- View all sessions (pending, active, closed)
- Real-time status
- Duration tracking
- Close sessions manually
- Auto-refresh every 10 seconds

### 6. **Counsellors Management**
- View all counsellors with enhanced metrics
- Performance tracking:
  - Sessions handled
  - Closed sessions
  - Active sessions
  - Completion rate (%)
  - Average response time
- Add new counsellors
- Delete counsellors

### 7. **Analytics & Reports**
- **Sessions by Issue** - Doughnut chart
- **Sessions by Language** - Bar chart
- **Sessions Over Time** - Line chart (7 days)
- **Counsellor Performance** - Horizontal bar chart
- Refresh button for latest data

---

## 🎯 Running the Dashboard

### 1. Start the API
```powershell
cd D:\Projects\yomehe\python_api
python -m uvicorn main:app --reload --port 8000
```

### 2. Start the Dashboard
```powershell
cd D:\Projects\yomehe\admin-dashboard-vue
npm run dev
```

### 3. Open Browser
Navigate to: **http://localhost:5173**

---

## 🔐 Login Credentials

**Admin Account:**
- Email: `admin@yoneco.org`
- Password: `Admin@2025`

**Counsellor Account (for testing):**
- Email: `counsellor1@yoneco.org`
- Password: `counsellor123`

---

## 🎨 Theme Colors

The dashboard uses your exact brand colors:

```css
Primary: #0A3D0A (Dark Forest Green)
Secondary: #2ecc71 (Light Green)
Accent: #27ae60 (Medium Green)
Background: #f5f6fa (Light Gray)
Danger: #e74c3c (Red)
Warning: #f39c12 (Orange)
Info: #3498db (Blue)
```

---

## 📁 Project Structure

```
admin-dashboard-vue/
├── public/
│   └── logo/
│       └── logo.png          # Your logo here
├── src/
│   ├── components/
│   │   └── StatCard.vue      # Dashboard stat cards
│   ├── router/
│   │   └── index.js          # Route configuration
│   ├── services/
│   │   └── api.js            # API client (Axios)
│   ├── stores/
│   │   ├── auth.js           # Authentication store
│   │   └── dashboard.js      # Dashboard data store
│   ├── views/
│   │   ├── Analytics.vue     # Analytics with charts
│   │   ├── Counsellors.vue   # Counsellor management
│   │   ├── Dashboard.vue     # Main dashboard
│   │   ├── Issues.vue        # Issues management
│   │   ├── Languages.vue     # Languages management
│   │   ├── Layout.vue        # Main layout with sidebar
│   │   ├── Login.vue         # Login page
│   │   └── Sessions.vue      # Sessions monitor
│   ├── App.vue               # Root component
│   ├── main.js               # App entry point
│   └── style.css             # Global styles
├── package.json              # Dependencies
├── tailwind.config.js        # Tailwind configuration
├── postcss.config.js         # PostCSS configuration
└── vite.config.js            # Vite configuration
```

---

## 🔧 API Configuration

The dashboard connects to: `http://localhost:8000`

To change this, edit `src/services/api.js`:
```javascript
const API_BASE_URL = 'http://localhost:8000'
```

---

## 📊 Performance Metrics Explained

See `PERFORMANCE_METRICS.md` for detailed explanation of:
- How counsellor performance is measured
- What each metric means
- Performance rating system
- API data flow

---

## 🛠️ Development

### Build for Production
```powershell
npm run build
```

### Preview Production Build
```powershell
npm run preview
```

---

## 📱 Responsive Design

The dashboard is fully responsive and works on:
- ✅ Desktop (1920px+)
- ✅ Laptop (1366px)
- ✅ Tablet (768px)
- ✅ Mobile (375px+)

---

## 🐛 Troubleshooting

### API Connection Error
- Make sure Python API is running on port 8000
- Check CORS settings in Python API

### Charts Not Loading
- Check browser console for errors
- Ensure Chart.js is installed: `npm list chart.js`

### Login Fails
- Verify credentials in database
- Check API endpoint: `POST /admin/login`

### Tailwind CSS Not Working
- Make sure Tailwind v3 is installed
- Check `tailwind.config.js` exists
- Verify `@tailwind` directives in `style.css`

---

## 🎉 You're All Set!

Your Tithandizane Helpline Admin Dashboard is ready to use with:
- ✅ Beautiful modern UI with your branding
- ✅ Real-time data from API
- ✅ Comprehensive performance analytics
- ✅ Full CRUD operations
- ✅ Professional charts and visualizations

**Happy monitoring! 🚀**
