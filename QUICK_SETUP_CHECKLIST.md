# Quick Setup Checklist - Multi-Device Configuration

## ✅ Step-by-Step Setup

### 1. Find Your Backend Device IP
**On your backend device (laptop/desktop):**

**Windows:**
```cmd
ipconfig
```

**macOS/Linux:**
```bash
ifconfig
```

**Look for something like:** `192.168.1.100` or `10.0.0.xxx`

---

### 2. Update Flutter App Configuration

**Edit:** `lib/core/config/api_config.dart`

**Replace this line:**
```dart
static const String baseUrl = 'http://YOUR_BACKEND_IP:8081/user-service/api/v1';
```

**With your actual IP (example):**
```dart
static const String baseUrl = 'http://192.168.1.100:8081/user-service/api/v1';
```

---

### 3. Configure Your Spring Boot Backend

**Update your application.properties:**
```properties
server.address=0.0.0.0
server.port=8081
```

**Or application.yml:**
```yaml
server:
  address: 0.0.0.0
  port: 8081
```

---

### 4. Allow Firewall Access

**Windows (Backend Device):**
1. Open "Windows Defender Firewall"
2. Click "Allow an app or feature through Windows Defender Firewall"
3. Click "Change Settings" → "Allow another app"
4. Add Java or allow port 8081

**macOS/Linux:**
```bash
# Allow port 8081
sudo ufw allow 8081
```

---

### 5. Update Android Configuration (if using Android)

**Add to `android/app/src/main/AndroidManifest.xml`:**
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

---

### 6. Test Connection

**Use the Network Test Widget in your app:**
1. Open the Auth Test Page
2. Use "Test Connection" button
3. Verify it shows ✅ success

**Or test manually in browser:**
```
http://192.168.1.100:8081/health
```

---

## 🔧 Common IP Examples

| Network Type | IP Range | Example |
|-------------|----------|---------|
| Home WiFi | 192.168.x.x | 192.168.1.100 |
| Corporate | 10.x.x.x | 10.0.1.50 |
| Hotspot | 172.x.x.x | 172.20.10.2 |

---

## ⚡ Quick Test Commands

**Start backend with external access:**
```bash
java -jar your-app.jar --server.address=0.0.0.0 --server.port=8081
```

**Test from mobile browser:**
```
http://YOUR_IP:8081/health
```

**Test from command line:**
```bash
curl http://YOUR_IP:8081/user-service/api/v1/health
```

---

## 🚨 Troubleshooting

| Problem | Solution |
|---------|----------|
| Connection refused | Check if backend runs on 0.0.0.0 not localhost |
| Timeout | Increase timeout in ApiConfig, check network |
| Firewall blocking | Allow port 8081 in firewall |
| Wrong IP | Double-check IP with ipconfig/ifconfig |
| Android HTTP blocked | Add usesCleartextTraffic="true" |

---

## 📱 Complete Example

**Your setup should look like:**

1. **Backend Device (Laptop):** `192.168.1.100`
   - Spring Boot running on `0.0.0.0:8081`
   - Firewall allows port 8081

2. **Mobile Device:** Connected to same WiFi
   - Flutter app configured with `http://192.168.1.100:8081`
   - Can browse to backend in mobile browser

3. **Test:** Network Test Widget shows ✅ connection successful

---

## 🎯 Production Notes

- For production, use HTTPS and proper domain names
- This HTTP setup is for development only
- Consider using ngrok for external testing
- Docker containers may need additional network configuration
