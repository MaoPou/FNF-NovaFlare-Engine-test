# Security and Code Review for NovaFlare Engine

**Review Date:** 2025-11-09  
**Repository:** NovaFlare-Engine-Concentration/FNF-NovaFlare-Engine  
**Codebase Size:** ~90,000 lines of Haxe code across 344 files

## Executive Summary

This comprehensive security and code review identified several **CRITICAL** security vulnerabilities and areas for improvement in the NovaFlare Engine codebase. Immediate action is required to address the critical security issues before any production release.

### Risk Level: 🔴 **CRITICAL**

---

## 🚨 Critical Security Issues (Immediate Action Required)

### 1. **Hardcoded Encryption Key** (CRITICAL)
**File:** `source/server/online/LoginClient.hx`  
**Line:** 18-19

```haxe
static final ENCRYPTION_KEY_STR:String = "c138265b0f77cccd86192a7173668090";
static final ENCRYPTION_KEY:Bytes = Bytes.ofString(ENCRYPTION_KEY_STR);
```

**Issue:** The AES encryption key is hardcoded in the source code. This key is used to encrypt/decrypt login credentials.

**Impact:**
- Anyone with access to the source code can decrypt all encrypted communications
- All user login credentials transmitted using this key are compromised
- Zero actual security for the login system

**Recommendation:**
1. **NEVER** hardcode encryption keys in source code
2. Use environment variables or secure key management systems
3. Implement proper key rotation mechanisms
4. Consider using OAuth or other modern authentication methods instead of custom encryption
5. Rotate the current key immediately if this is in production

---

### 2. **Hardcoded API Key** (CRITICAL)
**File:** `source/server/http/OnlineStatistics.hx`  
**Line:** 9

```haxe
public static final API_KEY:String = "114514";
```

**Issue:** API key is hardcoded and publicly visible in source code.

**Impact:**
- Anyone can make requests to your API using this key
- Potential for abuse, DoS attacks, or data manipulation
- No way to revoke access without code changes

**Recommendation:**
1. Remove hardcoded API key from source code
2. Use environment variables or configuration files (excluded from git)
3. Implement proper API authentication (OAuth, JWT, etc.)
4. Add rate limiting to API endpoints
5. Regenerate the API key immediately

---

### 3. **Android Keystore with Password in Repository** (CRITICAL)
**Files:** 
- `key.keystore` (checked into repository)
- `Project.xml` (line 236)

```xml
<certificate path="key.keystore" password="novaFlare" alias="psychport" alias-password="novaFlare" if="android" unless="debug" />
```

**Issue:** 
- The Android signing keystore file is committed to the repository
- The keystore password is hardcoded in `Project.xml`
- This is publicly visible to anyone with repository access

**Impact:**
- Anyone can sign APKs as your application
- Attackers can create malicious versions of your app
- Users cannot distinguish legitimate from malicious versions
- Complete compromise of Android app identity and integrity
- **This violates Google Play Store security policies**

**Recommendation:**
1. **IMMEDIATELY** remove `key.keystore` from the repository
2. Add `*.keystore` to `.gitignore`
3. Purge the keystore from git history (use `git filter-branch` or BFG Repo-Cleaner)
4. Generate a new keystore with a strong password
5. Store keystore securely (not in repository)
6. Use environment variables for keystore password in build scripts
7. Update all existing app versions if already published
8. For open-source projects, use different keystores for:
   - Debug builds (can be in repo with weak password)
   - Release builds (never in repo, strong password)

---

## ⚠️ High Priority Security Issues

### 4. **Weak Password Transmission**
**File:** `source/server/online/LoginClient.hx`

**Issue:** While passwords are encrypted before transmission, the encryption uses a static, hardcoded key (see issue #1), making the encryption effectively useless.

**Recommendation:**
- Implement proper TLS/SSL for all communications
- Use established authentication protocols (OAuth 2.0, OpenID Connect)
- Hash passwords client-side before transmission (with proper salting)
- Never rely on custom encryption for security-critical operations

---

### 5. **Catch-all Error Handling**
**Multiple Files** (LoginClient.hx, many Lua/HScript files)

**Example:**
```haxe
catch (e:Dynamic) {
    //trace('解密失败: $e');
}
```

**Issue:** Generic catch blocks that swallow all exceptions without proper logging or handling.

**Impact:**
- Silent failures make debugging difficult
- Security issues may go unnoticed
- Potential for undefined behavior

**Recommendation:**
- Use specific exception types
- Log errors appropriately (with proper error tracking)
- Implement proper error recovery or fail safely
- Never silently swallow exceptions in production code

---

## 📋 Code Quality Issues

### 6. **TODO Comments**
Found multiple TODO comments indicating incomplete implementations:

```haxe
// source/backend/Conductor.hx
+ ((step - lastChange.stepTime) / (lastChange.bpm / 60) / 4) * 1000; // TODO: make less shit and take BPM into account PROPERLY

// source/states/stages/objects/DarnellBlazinHandler.hx
playCringeAnim(); // TODO: Which anim?
playFakeoutAnim(); // TODO: Which anim?
```

**Recommendation:** Review and complete all TODO items before production release.

---

### 7. **Code Comments in Chinese**
**File:** `source/server/online/LoginClient.hx`

While having a multilingual team is great, mixing languages in code comments can create maintenance issues:

```haxe
/**
 * AES-256-CBC加密：返回Base64编码的字符串（IV+密文）
 */
```

**Recommendation:** 
- Use English for all code comments and documentation
- Maintain separate translated documentation if needed
- Helps with international collaboration and code review

---

### 8. **Commented Debug Code**
Many files contain commented-out trace statements:

```haxe
//trace('加密后的请求: $encryptedRequest');
//trace('登录成功！用户组: ${result.user_info.user_group}');
```

**Recommendation:**
- Remove commented debug code
- Use proper logging framework with log levels
- Implement debug/release build configurations

---

## 🔒 Security Best Practices Recommendations

### Immediate Actions (Before Any Release):
1. ✅ Remove `key.keystore` from repository and git history
2. ✅ Remove all hardcoded secrets (encryption keys, API keys, passwords)
3. ✅ Implement environment-based configuration
4. ✅ Generate new keystore with strong password
5. ✅ Regenerate all API keys and encryption keys

### Short-term Improvements:
1. Implement proper authentication system (OAuth 2.0 or similar)
2. Add input validation and sanitization for all user inputs
3. Implement rate limiting on API endpoints
4. Add comprehensive logging with security event monitoring
5. Set up automated security scanning in CI/CD pipeline
6. Review and fix all exception handling

### Long-term Improvements:
1. Security audit by professional security team
2. Implement security headers and CSP policies
3. Regular dependency updates and vulnerability scanning
4. Security training for development team
5. Implement secure development lifecycle (SDL)
6. Add automated security testing

---

## 📊 Code Statistics

- **Total Files:** 344 Haxe files
- **Total Lines:** ~90,000 lines of code
- **Platform:** Multi-platform (Desktop, Mobile, Web)
- **Framework:** HaxeFlixel-based game engine

---

## ✅ Positive Aspects

1. **Well-structured codebase** with clear separation of concerns
2. **Multi-platform support** through Haxe
3. **Active development** with recent commits
4. **Good documentation** in README
5. **Modding support** through Lua and HScript
6. **Mobile optimization** efforts visible in code

---

## 🎯 Priority Action Items

### Priority 1 (Critical - Do Today):
- [ ] Remove `key.keystore` from repository
- [ ] Add `*.keystore` to `.gitignore`
- [ ] Remove hardcoded encryption key
- [ ] Remove hardcoded API key
- [ ] Purge secrets from git history

### Priority 2 (High - This Week):
- [ ] Implement environment-based configuration
- [ ] Generate new signing keystore
- [ ] Implement proper API authentication
- [ ] Add comprehensive error logging
- [ ] Review and test all authentication flows

### Priority 3 (Medium - This Month):
- [ ] Complete all TODO items
- [ ] Standardize code comments to English
- [ ] Remove all commented debug code
- [ ] Set up automated security scanning
- [ ] Document security practices

---

## 📝 Conclusion

The NovaFlare Engine codebase shows good engineering practices in many areas, but has **critical security vulnerabilities** that must be addressed before any production release. The hardcoded secrets and checked-in keystore represent immediate security risks that could compromise user data and application integrity.

**Recommended Next Steps:**
1. Immediately address all Priority 1 items
2. Conduct a full security audit
3. Implement automated security testing
4. Establish security review process for all code changes

---

**Reviewer Note:** This review was conducted as a static analysis. Dynamic testing and penetration testing would provide additional insights into runtime security issues.
