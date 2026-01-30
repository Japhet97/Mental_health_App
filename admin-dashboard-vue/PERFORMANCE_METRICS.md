# 📊 Dashboard & Counsellor Performance Metrics

## ✅ Dashboard is Now Fully Connected to API

The Vue.js dashboard is now properly integrated with the Python API with **real-time data**.

---

## 🎯 Counsellor Performance Metrics

### **What We Track:**

#### 1. **Sessions Handled** 
- Total number of sessions a counsellor has taken
- Displayed with blue badge

#### 2. **Closed Sessions**
- Number of sessions successfully completed
- Displayed with green badge

#### 3. **Active Sessions**
- Currently ongoing sessions
- Displayed with yellow badge

#### 4. **Completion Rate** 📈
- Formula: `(Closed Sessions / Total Sessions) × 100`
- Shows progress bar + percentage
- Higher is better (shows efficiency)

#### 5. **Average Response Time** ⏱️
- Time between client's first message and counsellor's first response
- **Color Coded:**
  - 🟢 **Green** (< 5 min) - Excellent
  - 🟡 **Yellow** (5-15 min) - Good
  - 🔴 **Red** (> 15 min) - Needs Improvement

#### 6. **Average Session Duration**
- How long sessions typically last
- Calculated from session start to close time

#### 7. **Messages Sent**
- Total messages sent by the counsellor
- Shows engagement level

---

## 📈 Analytics Charts (Real Data)

### 1. **Sessions by Issue** (Doughnut Chart)
- Shows distribution of mental health issues
- Uses real session data from database
- Color-coded by issue type

### 2. **Sessions by Language** (Bar Chart)
- Shows language preference of clients
- Uses actual language data from sessions
- Helps identify which languages need more support

### 3. **Sessions Over Last 7 Days** (Line Chart)
- Shows daily session trends
- Uses real data from `sessions_by_day` endpoint
- Helps identify busy periods

### 4. **Counsellor Performance** (Horizontal Bar Chart)
- Shows sessions handled per counsellor
- Sorted by performance
- Easy comparison between counsellors

---

## 🔄 Data Flow

```
Client/Counsellor App 
    ↓
Python API (FastAPI)
    ↓
PostgreSQL Database
    ↓
Admin Dashboard API Call
    ↓
Vue.js Dashboard (Charts & Tables)
```

---

## 🚀 Key Features

✅ **Real-time Updates**
- Dashboard auto-refreshes every 30 seconds
- Sessions page updates every 10 seconds

✅ **Comprehensive Metrics**
- Total sessions, counsellors, messages
- Pending and active sessions
- Today's activity
- Weekly trends

✅ **Performance Insights**
- Average response time across all counsellors
- Individual counsellor performance metrics
- Completion rates for quality tracking

✅ **Visual Analytics**
- 4 interactive Chart.js charts
- Color-coded for easy understanding
- Responsive design

---

## 📊 API Endpoints Used

| Endpoint | Purpose |
|----------|---------|
| `/admin/dashboard` | Main dashboard statistics |
| `/admin/sessions/recent` | Recent session activity |
| `/admin/issues` | Mental health issues list |
| `/admin/languages` | Supported languages |
| `/admin/counsellors/active` | Counsellor status & metrics |

---

## 🎨 Performance Indicators

### Response Time Ratings:
- **< 2 min** - Outstanding ⭐⭐⭐⭐⭐
- **2-5 min** - Excellent ⭐⭐⭐⭐
- **5-10 min** - Good ⭐⭐⭐
- **10-15 min** - Average ⭐⭐
- **> 15 min** - Needs improvement ⭐

### Completion Rate Ratings:
- **> 90%** - Excellent
- **70-90%** - Good
- **50-70%** - Fair
- **< 50%** - Needs attention

---

## 🔧 How to Use

1. **View Dashboard**: Main overview with stats cards and recent activity
2. **Check Analytics**: Visual charts for trends and patterns
3. **Monitor Counsellors**: Track individual performance metrics
4. **Manage Sessions**: View all active and recent sessions
5. **Admin Issues/Languages**: Add or remove mental health issues and languages

---

## 💡 Future Enhancements

Potential additions:
- Export reports to PDF/Excel
- Email notifications for performance alerts
- Real-time notifications using WebSockets
- Advanced filtering and date range selection
- Counsellor rating system
- Client feedback collection
- Session recordings/transcripts

---

## 🎯 Performance Goals

**Recommended Targets:**
- Average Response Time: < 5 minutes
- Completion Rate: > 85%
- Active Sessions per Counsellor: 2-3 concurrent
- Daily Sessions Handled: 5-10 per counsellor

---

**The dashboard is now production-ready with comprehensive analytics and performance tracking! 🚀**
