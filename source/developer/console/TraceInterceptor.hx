package developer.console;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import crowplexus.iris.ErrorSeverity;
#end

class TraceInterceptor {
    static var originalTrace = haxe.Log.trace;
    #if HSCRIPT_ALLOWED
    static var originalLogLevel = Iris.logLevel;
    #end
    
    public static function init() {
        TraceServer.start(1145);
        
        haxe.Log.trace = customTrace;
        
        #if HSCRIPT_ALLOWED
        Iris.logLevel = customLogLevel;
        #end
        ConsoleToggleButton.show();
    }
    
    static function customTrace(v:Dynamic, ?infos:haxe.PosInfos) {
        var message = if (infos != null) {
            '${infos.fileName}:${infos.lineNumber}: ' + Std.string(v);
        } else {
            Std.string(v);
        };

        originalTrace(v, infos);
        Console.log(message);
        
        // 发送到网络服务器
        TraceServer.sendTraceMessage("INFO", message, 0xFFFFFF);
    }
    
    #if HSCRIPT_ALLOWED
    static function customLogLevel(level:ErrorSeverity, x, ?infos:haxe.PosInfos) {
        var head = switch(level) {
            case WARN: "WARN: ";
            case ERROR: "ERROR: ";
            case FATAL: "FATAL: ";
            case NONE: "";
        };

        var message = if (infos != null) {
            '${infos.fileName}:${infos.lineNumber}: ' + Std.string(x);
        } else {
            Std.string(x);
        };

        originalLogLevel(level, x, infos);
        
        var color = getColorByLevel(level);
        
        if (level != NONE) {
            Console.logWithColoredHead(head, message, color);
            TraceServer.sendTraceMessage(level.getName(), message, color);
        } else {
            Console.log(message);
            TraceServer.sendTraceMessage("INFO", message, color);
        }
    }

    static function getColorByLevel(level:ErrorSeverity):Int {
        return switch(level) {
            case WARN: 0xFFFF00; // 黄色
            case ERROR: 0xFF0000; // 红色
            case FATAL: 0xFF00FF; // 品红色
            case NONE: 0xFFFFFF; // 白色
        }
    }
    #end
}