package thread;

import sys.thread.Thread;
import haxe.ds.IntMap;

/**
 * 在使用此类时，请确保你在以前已经研究过haxe线程的用法
 * workthread用于执行一些耗时的操作，event用于workthread完成后主线程去执行后续的操作
 * by 狐月影
 */


class ThreadEvent {
    var event:Void->Void = null;
    var workThread:Thread; //运行的新建线程
    var mainThread:Thread; //主线程
    var updateListener:Void->Void = null; //每帧监听

    static var IDcount:Int = 0;
    private var id:Int; //线程的专属id
    static var pendingMessages:IntMap<Array<Dynamic>> = new IntMap();

    public static function create(job:()->Void, event:Void->Void):ThreadEvent
    {
        var thread = new ThreadEvent(event);
        thread.id = IDcount;
        IDcount++;
		thread.__create(job);
        return thread;
    }

    @:noCompletion private function __create(job:()->Void):Void
	{
		workThread = Thread.create(function() {
            try {
                job();
            } catch (e:Dynamic) {
                trace("Thread Error: " + e);
            }
            
            if (mainThread != null) {
                mainThread.sendMessage({
                    type: "complete",
                    data: {id: this.id}
                });
            }
        });
	}

    public function new(event:Void->Void) {
        this.event = event;
        this.mainThread = Thread.current();
        addIndividualListener();
    }

    public function checkCompletion(blocking:Bool = false) {
        var list = pendingMessages.get(id);
        if (list != null && list.length > 0) {
            if (event != null) {
                event();
            }
            if (updateListener != null) {
                removeIndividualListener();
            }
            list.shift();
            if (list.length == 0) {
                pendingMessages.remove(id);
            }
            return;
        }

        var msg:Dynamic = null;
        do {
            msg = Thread.readMessage(blocking);
            if (msg != null && Reflect.hasField(msg, "type") && Std.string(msg.type).toLowerCase() == "complete" && Reflect.hasField(msg, "data") && Reflect.hasField(msg.data, "id")) {
                var mid:Int = msg.data.id;
                if (mid == id) {
                    if (event != null) {
                        event();
                    }
                    if (updateListener != null) {
                        removeIndividualListener();
                    }
                    return;
                } else {
                    var other = pendingMessages.get(mid);
                    if (other == null) {
                        other = [];
                        pendingMessages.set(mid, other);
                    }
                    other.push(msg);
                }
            }
        } while (!blocking && msg != null);
    }
    
    function addIndividualListener():Void {
        updateListener = function() {
            checkCompletion(false);
        };
        
        FlxG.signals.preUpdate.add(updateListener);
    }
    
    function removeIndividualListener():Void {
        FlxTimer.wait(0.001, () -> {
            if (updateListener != null) {
                FlxG.signals.preUpdate.remove(updateListener);
                updateListener = null;
                destroy();
            }
        });
    }

    public function cancel():Void {
        if (updateListener != null) {
            FlxG.signals.preUpdate.remove(updateListener);
            updateListener = null;
        }
        mainThread = null;
        event = null;
    }
    //workthread仍然会运行，但是后续的操作不会执行，haxe你个fv你完蛋了
    
    public function destroy():Void {
        event = null;
        workThread = null;
        mainThread = null;
    }
    
    /**
     * 向工作线程发送消息
     * @param message 要发送的消息
     */
    public function sendToThread(message:Dynamic):Void {
        if (workThread != null) {
            workThread.sendMessage(message);
        }
    }
    
    /**
     * 在工作线程中读取消息
     * @param blocking 是否阻塞等待消息
     * @return Dynamic 接收到的消息，如果没有消息且非阻塞则返回null
     */
    public function readThreadMessage(blocking:Bool = true):Dynamic {
            var msg = Thread.readMessage(blocking);
            if (msg != null && msg.data.result == id) {
                return msg;
            }
        return null;
    }
}
