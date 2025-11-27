package server.online;

import haxe.crypto.Base64;
import haxe.crypto.mode.Mode;
import haxe.crypto.padding.PKCS7;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.crypto.Aes;
import haxe.Http;
import haxe.Json;

#if windows
import trandom.Native;
#end

class LoginClient {
    static final API_URL:String = "https://online.novaflare.top/user/login/api.php";
    static final BLOCK_SIZE:Int = 16;

    static final ENCRYPTION_KEY_STR:String = "c138265b0f77cccd86192a7173668090";
    static final ENCRYPTION_KEY:Bytes = Bytes.ofString(ENCRYPTION_KEY_STR);
    
    public var decision:Dynamic->Void = null;
    
    public function new() {}
    
    /**
     * AES-256-CBC加密：返回Base64编码的字符串（IV+密文）
     */
    function encrypt(data:String):String {
        var iv:Bytes = generateRandomIV();
        
        var dataBytes:Bytes = Bytes.ofString(data);
        var paddedData:Bytes = PKCS7.pad(dataBytes, BLOCK_SIZE);
        
        var aes:Aes = new Aes(ENCRYPTION_KEY, iv);
        var encryptedBytes:Bytes = aes.encrypt(Mode.CBC, paddedData);
        
        var combined = new BytesBuffer();
        combined.add(iv);
        combined.add(encryptedBytes);
        var combinedBytes = combined.getBytes();
        
        return Base64.encode(combinedBytes);
    }
    
    private static function stringReplace(str:String, search:String, replace:String):String {
        var result = "";
        var i = 0;
        var len = str.length;
        var searchLen = search.length;
        
        while (i < len) {
            if (i + searchLen <= len && str.substr(i, searchLen) == search) {
                result += replace;
                i += searchLen;
            } else {
                result += str.charAt(i);
                i++;
            }
        }
        return result;
    }
    
    /**
     * AES-256-CBC解密：从Base64字符串解密为明文（我你妈搞了将近7小时）
     */
    function decrypt(encryptedStr:String):String {
        var cleanStr:String = encryptedStr;
        
        // 去除空白字符（空格、换行等)
        cleanStr = stringReplace(cleanStr, " ", "");
        cleanStr = stringReplace(cleanStr, "\n", "");
        cleanStr = stringReplace(cleanStr, "\r", "");
        cleanStr = stringReplace(cleanStr, "\t", "");
        
        // 过滤非Base64字符（只保留A-Za-z0-9+/=）
        var validChars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
        var filtered:String = "";
        // 用索引遍历替代for-in循环
        for (i in 0...cleanStr.length) {
            var c = cleanStr.charAt(i);
            // 检查字符是否有效
            var isValid = false;
            for (j in 0...validChars.length) {
                if (validChars.charAt(j) == c) {
                    isValid = true;
                    break;
                }
            }
            if (isValid) {
                filtered += c;
            }
        }
        cleanStr = filtered;

        while (cleanStr.length % 4 != 0) {
            cleanStr += "=";
        }

        var encryptedBytes:Bytes;
        try {
            encryptedBytes = Base64.decode(cleanStr);
        } catch (e:Dynamic) {
            throw "Base64解码失败: " + e;
        }

        if (encryptedBytes.length < BLOCK_SIZE) {
            throw "加密数据长度不足（至少需要" + BLOCK_SIZE + "字节）";
        }

        var iv:Bytes = encryptedBytes.sub(0, BLOCK_SIZE);
        var cipherText:Bytes = encryptedBytes.sub(BLOCK_SIZE, encryptedBytes.length - BLOCK_SIZE);

        var aes:Aes = new Aes(ENCRYPTION_KEY, iv);
        var decryptedBytes:Bytes = aes.decrypt(Mode.CBC, cipherText);
        return decryptedBytes.toString();
    }
    
    /**
     * 生成随机IV
     */

    private function generateRandomIV():Bytes {
        #if windows
        var iv = Bytes.alloc(BLOCK_SIZE);
        for (i in 0...Std.int(BLOCK_SIZE / 4)) {
            iv.setInt32(i * 4, Native.get());
        }
        var remaining = BLOCK_SIZE % 4;
        if (remaining > 0) {
            var lastChunk = Native.get();
            for (i in 0...remaining) {
                iv.set((BLOCK_SIZE - remaining) + i, (lastChunk >> (8 * i)) & 0xFF);
            }
        }
        return iv;
        #else
        var iv = Bytes.alloc(BLOCK_SIZE);
        for (i in 0...BLOCK_SIZE) {
            iv.set(i, Std.random(256));
        }
        return iv;
        #end
    }
    
    /**
     * 主登录方法
     */
    public function login(username:String, password:String):Void {
        var loginData:Dynamic = {
            "username": username,
            "password": password
        };
        
        var requestJson:String = Json.stringify(loginData);
        var encryptedRequest:String = encrypt(requestJson);
        //trace('加密后的请求: $encryptedRequest');
        
        var http = new Http(API_URL);
        http.setHeader("Content-Type", "text/plain");
        http.setPostData(encryptedRequest);
        
        http.onError = function(error:String) {
            //trace('请求失败: $error');
            decision({
                message: error
            });
        };
        
        http.onData = function(encryptedResponse:String) {
            try {
                var decryptedResponse:String = decrypt(encryptedResponse);
                
                var result:Dynamic = Json.parse(decryptedResponse);
                if (result.success) {
                    //trace('登录成功！用户组: ${result.user_info.user_group}');
                    decision({
                        message: 'Good',
                        name: result.user_info.username,
                        member: result.user_info.user_group,
                    });
                } else {
                    //trace('登录失败: ${result.message}');
                    decision({
                        message: result.message
                    });
                }
            } catch (e:Dynamic) {
                //trace('解密失败: $e');
            }
        };
        
        http.request(true);
    }
}
