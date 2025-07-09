# Multi-Device Backend Configuration Guide

## Overview

This guide helps you configure the Thirikkale Rider app to connect to a backend running on a different device. This is common during development when your Spring Boot backend runs on a laptop/desktop and your Flutter app runs on a physical device or emulator.

## Step 1: Find Your Backend Device IP Address

### On Windows (Backend Device):
```cmd
ipconfig
```
Look for the IPv4 Address under your active network adapter (usually Wi-Fi or Ethernet)

### On macOS/Linux (Backend Device):
```bash
ifconfig
# or
ip addr show
```

### Example Output:
```
IPv4 Address: 192.168.1.100
```

## Step 2: Update Flutter App Configuration

### Update API Config
In `lib/core/config/api_config.dart`, replace `YOUR_BACKEND_IP` with your actual IP:

```dart
// Replace this line:
static const String baseUrl = 'http://YOUR_BACKEND_IP:8081/user-service/api/v1';

// With your actual IP (example):
static const String baseUrl = 'http://192.168.1.100:8081/user-service/api/v1';
```

## Step 3: Backend Configuration (Spring Boot)

### Update application.properties/application.yml

Add these configurations to allow external connections:

#### application.properties:
```properties
# Allow connections from any IP
server.address=0.0.0.0
server.port=8081

# CORS configuration for Flutter app
cors.allowed-origins=*
cors.allowed-methods=GET,POST,PUT,DELETE,OPTIONS
cors.allowed-headers=*
cors.allow-credentials=true
```

#### application.yml:
```yaml
server:
  address: 0.0.0.0
  port: 8081

cors:
  allowed-origins: "*"
  allowed-methods: "GET,POST,PUT,DELETE,OPTIONS"
  allowed-headers: "*"
  allow-credentials: true
```

### Add CORS Configuration Class (if needed):

```java
@Configuration
@EnableWebMvc
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(false);
    }
}
```

## Step 4: Network Configuration

### Firewall Configuration

#### Windows (Backend Device):
1. Open Windows Defender Firewall
2. Click "Allow an app or feature through Windows Defender Firewall"
3. Click "Change Settings" → "Allow another app"
4. Browse and select your Java application or add port 8081
5. Or create a new inbound rule for port 8081

#### macOS (Backend Device):
```bash
# Allow incoming connections on port 8081
sudo pfctl -f /etc/pf.conf
```

#### Linux (Backend Device):
```bash
# Using ufw
sudo ufw allow 8081

# Using iptables
sudo iptables -A INPUT -p tcp --dport 8081 -j ACCEPT
```

### Router Configuration (if needed)
If devices are on different networks, you may need to:
1. Configure port forwarding on your router
2. Use the router's external IP address
3. Ensure both devices can communicate

## Step 5: Test Network Connectivity

### From Mobile Device/Emulator

#### Test 1: Basic Connectivity
Open a web browser on your mobile device and try:
```
http://192.168.1.100:8081/health
```
(Replace with your backend IP)

#### Test 2: Using cURL (if available)
```bash
curl -v http://192.168.1.100:8081/user-service/api/v1/health
```

#### Test 3: Using Flutter HTTP Test
Add this test method to your Flutter app:

```dart
Future<void> testBackendConnectivity() async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/health'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    print('✅ Backend connectivity test: ${response.statusCode}');
    print('Response: ${response.body}');
  } catch (e) {
    print('❌ Backend connectivity failed: $e');
  }
}
```

## Step 6: Common Network Issues & Solutions

### Issue 1: Connection Refused
**Symptoms:** App shows "Connection refused" errors
**Solutions:**
- Verify backend is running on 0.0.0.0:8081 (not localhost)
- Check firewall settings
- Ensure IP address is correct

### Issue 2: Connection Timeout
**Symptoms:** App hangs or times out
**Solutions:**
- Increase timeout values in ApiConfig
- Check network latency
- Verify both devices are on same network

### Issue 3: HTTP vs HTTPS
**Symptoms:** SSL/TLS errors
**Solutions:**
- Use HTTP for development (not HTTPS)
- Update Android network security config for HTTP

### Issue 4: Android HTTP Traffic
For Android apps to allow HTTP traffic, add to `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

Or create `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">192.168.1.100</domain>
    </domain-config>
</network-security-config>
```

And reference it in AndroidManifest.xml:
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

## Step 7: Development vs Production

### Development Configuration
```dart
class ApiConfig {
  // Development - specific IP address
  static const String baseUrl = 'http://192.168.1.100:8081/user-service/api/v1';
}
```

### Production Configuration
```dart
class ApiConfig {
  // Production - domain name with HTTPS
  static const String baseUrl = 'https://api.thirikkale.com/user-service/api/v1';
}
```

### Environment-based Configuration
```dart
class ApiConfig {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static String get baseUrl {
    if (isProduction) {
      return 'https://api.thirikkale.com/user-service/api/v1';
    } else {
      return 'http://192.168.1.100:8081/user-service/api/v1'; // Your dev IP
    }
  }
}
```

## Step 8: Testing Checklist

- [ ] Backend starts on 0.0.0.0:8081
- [ ] Firewall allows port 8081
- [ ] Both devices on same network
- [ ] IP address correctly configured in Flutter
- [ ] HTTP cleartext traffic allowed (Android)
- [ ] CORS properly configured
- [ ] Network connectivity test passes
- [ ] Authentication endpoints respond correctly

## Step 9: Debug Network Issues

### Enable Network Logging in Flutter
```dart
import 'package:http/http.dart' as http;

class LoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('🌐 ${request.method} ${request.url}');
    print('📤 Headers: ${request.headers}');
    
    final response = await _inner.send(request);
    
    print('📥 Status: ${response.statusCode}');
    return response;
  }
}

// Use in your API calls:
final client = LoggingClient();
```

### Monitor Network Traffic
- Use Charles Proxy or similar tools
- Check browser developer tools
- Monitor Spring Boot logs for incoming requests

## Quick Setup Example

1. **Find your backend IP:** `192.168.1.100`
2. **Update Flutter:** Change `YOUR_BACKEND_IP` to `192.168.1.100`
3. **Start backend:** `java -jar app.jar --server.address=0.0.0.0`
4. **Test connectivity:** Browse to `http://192.168.1.100:8081/health`
5. **Run Flutter app** and test authentication

## Production Deployment

For production, consider:
- Using a proper domain name
- SSL/TLS certificates
- Load balancing
- API Gateway
- Container orchestration (Docker/Kubernetes)

This setup allows your Flutter app running on any device to communicate with your Spring Boot backend running on a different device in the same network.
