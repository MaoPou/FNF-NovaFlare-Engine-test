package backend;

import lime.app.Application;
import lime.graphics.Image;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GL;
import openfl.display3D.textures.RectangleTexture;
import openfl.display.BitmapData;
import flixel.FlxG;
import sys.thread.Thread;
import haxe.MainLoop;
import lime.system.ThreadPool;
import lime.app.Application;

/**
 * 异步纹理上传工具类
 * 利用共享上下文在线程池中上传纹理，避免主线程卡顿。
 */
class AsyncTextureUploader {
    private static var threadPool:ThreadPool;
    private static var sharedContext:Dynamic;
    private static var _initialized:Bool = false;

    /**
     * 初始化线程池和共享上下文
     * 必须在主线程调用
     */
    public static function init():Void {
        if (_initialized) return;

        // 1. 获取当前窗口的 Native Backend
        var window = Application.current.window;
        
        // 注意：这是通过 privateAccess 访问 NativeWindow，确保只在 Native 平台使用
        #if (cpp || hl)
        var backend:lime._internal.backend.native.NativeWindow = @:privateAccess window.__backend;
        
        // 2. 创建共享上下文
        sharedContext = backend.contextCreate();
        if (sharedContext == 0) {
            trace("AsyncTextureUploader: Failed to create shared context");
            return;
        }

        // 3. 创建线程池
        // 使用 ClientPrefs 中的配置或默认为 2
        var threads = ClientPrefs.data.loadThreads > 0 ? ClientPrefs.data.loadThreads : 2;
        threadPool = new ThreadPool(0, threads, MULTI_THREADED);
        
        // 4. 为每个线程做初始化（激活共享上下文）
        threadPool.doWork.add(function(context:Dynamic) {
             #if (cpp || hl)
             var window = Application.current.window;
             var backend:lime._internal.backend.native.NativeWindow = @:privateAccess window.__backend;
             backend.contextMakeCurrentCustom(sharedContext);
             #end
        });
        
        _initialized = true;
        #else
        trace("AsyncTextureUploader: Not supported on this platform");
        #end
    }

    /**
     * 销毁线程池
     */
    public static function destroy():Void {
        if (!_initialized) return;
        // 简单的取消所有任务，Lime 的 ThreadPool 没有显式的 destroy 方法来释放上下文
        // 但我们可以发送一个关闭信号或者 just cancel
        // 注意：实际上 Lime ThreadPool 不太好完全销毁并重建，通常保持它是全局的
        // 这里暂时不通过 destroy 销毁 context，因为可能会有其他地方用到，或者让它随程序生命周期
    }

    /**
     * 异步从文件上传纹理
     * @param path 图片路径
     * @param onComplete 完成回调 (GLTexture -> Void)
     * @param onError 错误回调 (String -> Void)
     */
    public static function uploadFromFile(path:String, onComplete:GLTexture->Void, onError:String->Void = null):Void {
        if (!_initialized) init();

        #if (cpp || hl)
        threadPool.run(function(state:Dynamic) {
            try {
                // 确保在当前线程激活了共享上下文 (虽然 init 里的 doWork 应该做了，但安全起见)
                var window = Application.current.window;
                var backend:lime._internal.backend.native.NativeWindow = @:privateAccess window.__backend;
                backend.contextMakeCurrentCustom(sharedContext);

                // 加载图片 (CPU 操作)
                var image = Image.fromFile(path);
                if (image == null) {
                    throw "Failed to load image: " + path;
                }

                uploadImageInternal(image, onComplete, onError);

            } catch (e:Dynamic) {
                MainLoop.runInMainThread(function() {
                    if (onError != null) onError(Std.string(e));
                });
            }
        });
        #else
        if (onError != null) onError("Async upload only supported on Native (CPP/HL) platforms");
        #end
    }

    /**
     * 异步从Image对象上传纹理，并直接缓存到Paths
     * @param key 缓存的key
     * @param bitmap 包含Image的BitmapData对象
     * @param onComplete 完成回调
     * @param onError 错误回调
     */
    public static function uploadFromBitmap(key:String, bitmap:BitmapData, onComplete:Void->Void = null, onError:String->Void = null):Void {
        if (!_initialized) init();

        #if (cpp || hl)
        threadPool.run(function(state:Dynamic) {
            try {
                var window = Application.current.window;
                var backend:lime._internal.backend.native.NativeWindow = @:privateAccess window.__backend;
                backend.contextMakeCurrentCustom(sharedContext);

                uploadImageInternal(bitmap.image, function(texture:GLTexture) {
                    // 主线程回调
                    var rectTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, openfl.display3D.Context3DTextureFormat.BGRA, true);
                    @:privateAccess {
                        GL.deleteTexture(rectTexture.__textureID);
                        rectTexture.__textureID = texture;
                    }
                    
                    var newBitmap = BitmapData.fromTexture(rectTexture);
                    // 释放原始内存位图
                    bitmap.dispose();
                    bitmap.disposeImage();

                    // 将生成好的GPU位图放入缓存
                    if (Paths.cacheBitmap(key, newBitmap, false) != null) {
                        trace('IMAGE: finished preloading image $key');
                    } else {
                        trace('IMAGE: failed to cache image $key');
                    }
                    
                    if (onComplete != null) onComplete();
                }, onError);

            } catch (e:Dynamic) {
                MainLoop.runInMainThread(function() {
                    if (onError != null) onError(Std.string(e));
                });
            }
        });
        #else
        if (onError != null) onError("Async upload only supported on Native (CPP/HL) platforms");
        #end
    }

    static function uploadImageInternal(image:Image, onComplete:GLTexture->Void, onError:String->Void):Void {
        // 创建并上传纹理 (GPU 操作)
        var texture = GL.createTexture();
        GL.bindTexture(GL.TEXTURE_2D, texture);
        
        // 设置基本的纹理参数
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.CLAMP_TO_EDGE);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR);
        GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);

        // 上传数据
        GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, image.width, image.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, image.data);
        
        // 确保命令已提交给 GPU
        GL.flush();

        // 解绑上下文 (可选，但在销毁线程前是个好习惯，这里是在线程池里所以不用太在意，但为了保险)
        // backend.contextMakeCurrentCustom(0); 

        // 回到主线程通知完成
        MainLoop.runInMainThread(function() {
            if (onComplete != null) onComplete(texture);
        });
    }
}
