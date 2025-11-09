# Code Quality Recommendations

This document provides recommendations for improving code quality in the NovaFlare Engine beyond the critical security issues addressed in SECURITY_REVIEW.md.

## 🔧 Hardcoded Secrets to Fix (CRITICAL)

These issues were documented but NOT automatically fixed as they require careful testing:

### 1. Update LoginClient.hx

**File:** `source/server/online/LoginClient.hx`

**Current Code (Line 18-19):**
```haxe
static final ENCRYPTION_KEY_STR:String = "c138265b0f77cccd86192a7173668090";
static final ENCRYPTION_KEY:Bytes = Bytes.ofString(ENCRYPTION_KEY_STR);
```

**Recommended Fix:**
```haxe
static final ENCRYPTION_KEY_STR:String = Sys.getEnv("ENCRYPTION_KEY") != null ? 
    Sys.getEnv("ENCRYPTION_KEY") : "";
static final ENCRYPTION_KEY:Bytes = Bytes.ofString(ENCRYPTION_KEY_STR);

// Add validation in constructor
public function new() {
    if (ENCRYPTION_KEY_STR == null || ENCRYPTION_KEY_STR.length == 0) {
        throw "ENCRYPTION_KEY environment variable not set!";
    }
}
```

### 2. Update OnlineStatistics.hx

**File:** `source/server/http/OnlineStatistics.hx`

**Current Code (Line 9):**
```haxe
public static final API_KEY:String = "114514";
```

**Recommended Fix:**
```haxe
public static final API_KEY:String = Sys.getEnv("API_KEY") != null ? 
    Sys.getEnv("API_KEY") : "";

// Add validation in start() method
public function start():Void {
    if (API_KEY == null || API_KEY.length == 0) {
        trace("WARNING: API_KEY environment variable not set!");
        return;
    }
    // ... rest of the method
}
```

## 📝 Code Quality Issues

### 1. Mixed Language Comments

**Issue:** Code comments are in Chinese, making international collaboration difficult.

**Files Affected:**
- `source/server/online/LoginClient.hx`

**Example:**
```haxe
/**
 * AES-256-CBC加密：返回Base64编码的字符串（IV+密文）
 */
```

**Recommendation:**
```haxe
/**
 * AES-256-CBC encryption: Returns Base64-encoded string (IV + ciphertext)
 */
```

### 2. Remove Commented Debug Code

**Issue:** Many commented `trace()` statements throughout the codebase.

**Files Affected:**
- `source/server/online/LoginClient.hx`
- Many Lua/HScript files

**Example:**
```haxe
//trace('加密后的请求: $encryptedRequest');
//trace('登录成功！用户组: ${result.user_info.user_group}');
```

**Recommendation:**
- Remove all commented debug statements
- Use a proper logging framework with log levels
- Example: Add a Logger class with DEBUG/INFO/WARN/ERROR levels

### 3. Generic Exception Handling

**Issue:** Catching `Dynamic` exceptions without proper handling.

**Example in LoginClient.hx:**
```haxe
catch (e:Dynamic) {
    //trace('解密失败: $e');
}
```

**Recommendation:**
```haxe
catch (e:haxe.Exception) {
    trace('Decryption failed: ${e.message}');
    trace('Stack trace: ${e.stack}');
    // Proper error handling or re-throw
    throw e;
}
```

### 4. Complete TODO Items

**Found TODOs:**

1. **source/backend/Conductor.hx:**
```haxe
// TODO: make less shit and take BPM into account PROPERLY
```

2. **source/states/stages/objects/DarnellBlazinHandler.hx:**
```haxe
// TODO: Maybe add a cooldown to this?
// TODO: Which anim?
```

3. **source/states/stages/objects/PicoBlazinHandler.hx:**
```haxe
// TODO: Which anim?
```

**Recommendation:** Review and complete or document all TODO items before production release.

## 🏗️ Architecture Improvements

### 1. Configuration Management

**Recommendation:** Create a centralized configuration system.

**Create:** `source/backend/Config.hx`
```haxe
package backend;

class Config {
    // API Configuration
    public static final API_URL:String = getEnvOrDefault("API_URL", "https://online.novaflare.top/api.php");
    public static final API_KEY:String = getEnv("API_KEY");
    
    // Encryption Configuration
    public static final ENCRYPTION_KEY:String = getEnv("ENCRYPTION_KEY");
    
    // Build Configuration
    public static final IS_DEBUG:Bool = #if debug true #else false #end;
    public static final VERSION:String = "1.2.0-DEV";
    
    private static function getEnv(name:String):String {
        var value = Sys.getEnv(name);
        if (value == null || value.length == 0) {
            throw 'Required environment variable $name is not set!';
        }
        return value;
    }
    
    private static function getEnvOrDefault(name:String, defaultValue:String):String {
        var value = Sys.getEnv(name);
        return (value != null && value.length > 0) ? value : defaultValue;
    }
}
```

### 2. Logging System

**Recommendation:** Implement proper logging instead of trace() calls.

**Create:** `source/backend/Logger.hx`
```haxe
package backend;

enum LogLevel {
    DEBUG;
    INFO;
    WARN;
    ERROR;
}

class Logger {
    public static var currentLevel:LogLevel = #if debug DEBUG #else INFO #end;
    
    public static function debug(message:String, ?pos:haxe.PosInfos):Void {
        log(DEBUG, message, pos);
    }
    
    public static function info(message:String, ?pos:haxe.PosInfos):Void {
        log(INFO, message, pos);
    }
    
    public static function warn(message:String, ?pos:haxe.PosInfos):Void {
        log(WARN, message, pos);
    }
    
    public static function error(message:String, ?pos:haxe.PosInfos):Void {
        log(ERROR, message, pos);
    }
    
    private static function log(level:LogLevel, message:String, pos:haxe.PosInfos):Void {
        if (shouldLog(level)) {
            var levelStr = switch (level) {
                case DEBUG: "DEBUG";
                case INFO: "INFO";
                case WARN: "WARN";
                case ERROR: "ERROR";
            };
            trace('[$levelStr] ${pos.fileName}:${pos.lineNumber} - $message');
        }
    }
    
    private static function shouldLog(level:LogLevel):Bool {
        return Type.enumIndex(level) >= Type.enumIndex(currentLevel);
    }
}
```

**Usage:**
```haxe
import backend.Logger;

// Instead of:
//trace('加密后的请求: $encryptedRequest');

// Use:
Logger.debug('Encrypted request: $encryptedRequest');
```

## 🧪 Testing Recommendations

### 1. Add Unit Tests

**Recommendation:** Add tests for critical security functions.

**Example test for encryption/decryption:**
```haxe
class LoginClientTest {
    public function testEncryptDecrypt():Void {
        var client = new LoginClient();
        var original = "test data";
        var encrypted = client.encrypt(original);
        var decrypted = client.decrypt(encrypted);
        
        Assert.equals(original, decrypted);
        Assert.notEquals(original, encrypted); // Should be encrypted
    }
}
```

### 2. Security Testing Checklist

- [ ] Test login with invalid credentials
- [ ] Test encryption with various data sizes
- [ ] Test API rate limiting
- [ ] Test error handling for network failures
- [ ] Test environment variable validation
- [ ] Test Android keystore configuration

## 📊 Performance Improvements

### 1. Optimize Image Loading

**Current:** Many large PNG files in assets.

**Recommendation:**
- Use texture atlases to reduce file count
- Compress images appropriately
- Consider using WebP format where supported
- Lazy load assets not needed immediately

### 2. Memory Management

**Found:** Manual GC calls in Main.hx
```haxe
cpp.vm.Gc.enable(true);
cpp.vm.Gc.run(true);
```

**Recommendation:**
- Profile memory usage to understand if manual GC is needed
- Consider object pooling for frequently created/destroyed objects
- Review and optimize asset preloading strategy

## 🔄 CI/CD Recommendations

### 1. Automated Security Scanning

Add to `.github/workflows/security.yml`:
```yaml
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run security scan
        run: |
          # Check for hardcoded secrets
          if grep -r "password.*=.*\"" source/ --include="*.hx"; then
            echo "Found hardcoded passwords!"
            exit 1
          fi
          
      - name: Check for TODO items
        run: |
          # Warn about TODO items
          grep -r "TODO\|FIXME" source/ --include="*.hx" || true
```

### 2. Build Validation

Add environment variable validation to build process:
```yaml
- name: Validate environment
  run: |
    if [ -z "$ANDROID_KEYSTORE_PASSWORD" ]; then
      echo "Error: ANDROID_KEYSTORE_PASSWORD not set"
      exit 1
    fi
```

## 📚 Documentation

### 1. API Documentation

**Recommendation:** Add comprehensive documentation for public APIs.

**Example:**
```haxe
/**
 * Handles user authentication via encrypted API calls.
 * 
 * This class provides secure login functionality using AES-256-CBC encryption.
 * All credentials are encrypted before transmission.
 * 
 * @example
 * ```haxe
 * var client = new LoginClient();
 * client.decision = function(result) {
 *     if (result.message == "Good") {
 *         trace('Login successful: ${result.name}');
 *     } else {
 *         trace('Login failed: ${result.message}');
 *     }
 * };
 * client.login("username", "password");
 * ```
 */
class LoginClient {
    // ...
}
```

### 2. Contributing Guidelines

**Create:** `CONTRIBUTING.md`
```markdown
# Contributing to NovaFlare Engine

## Security Guidelines

- Never commit secrets, keys, or passwords
- Never commit keystore files
- Always use environment variables for sensitive data
- Review SECURITY_REVIEW.md before contributing

## Code Style

- Use English for all comments and documentation
- Follow Haxe naming conventions
- Add proper error handling (no silent catch blocks)
- Write unit tests for new features
```

## 🎯 Priority Implementation Plan

### Immediate (This Week)
1. Move hardcoded secrets to environment variables
2. Purge keystore from git history
3. Add input validation to all user inputs
4. Fix all generic exception handlers

### Short-term (This Month)
1. Implement centralized Config system
2. Implement Logger system
3. Replace all trace() with Logger calls
4. Add unit tests for security-critical code
5. Complete all TODO items

### Long-term (Next Quarter)
1. Set up automated security scanning
2. Add comprehensive API documentation
3. Implement CI/CD pipeline
4. Performance profiling and optimization
5. Security audit by professional team

---

**Note:** This document complements SECURITY_REVIEW.md. Address critical security issues first, then work on these code quality improvements.
