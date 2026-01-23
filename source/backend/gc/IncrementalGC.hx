package backend.gc;

class IncrementalGC {

    /** 
     * 执行一步增量 GC。 
     * @param limitMs 允许 GC 执行的最大毫秒数（例如 0.5ms, 1.0ms）。 
     * 如果当前没有 GC 在运行，此函数会直接返回。 
     * 如果处于标记阶段，它会运行直到超时。 
     * 如果处于回收阶段，它会回收一部分内存块。 
     */ 
    //@:native("__hxcpp_gc_step") extern public static function step(limitMs:Float):Bool;

    /** 
     * 简单的自动管理策略 
     * @param maxTimeMs 本帧允许 GC 占用的最大时间（毫秒）
     */ 
    public static function run(maxTimeMs:Float = 1.0):Void { 
       //step(maxTimeMs);
    } 
}