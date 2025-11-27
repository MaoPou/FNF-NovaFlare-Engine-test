package backend.gc;

extern class GCManager {
      @:native("__hxcpp_gc_tick") extern public static function gc_tick():Void;
      @:native("__hxcpp_gc_update") extern public static function gc_update():Void;
}