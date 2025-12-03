package backend.mouse;

import flixel.FlxBasic;
import flixel.math.FlxMath;

class MouseMove extends FlxBasic
{
    public var allowUpdate:Bool = true;
    
    public var follow:Dynamic; //数据跟谁
    public var followData:String; //数据变量的名称

    public var target:Float;
    public var moveLimit:Array<Float> = [0, 0];  //[min, max]
    public var mouseLimit:Array<Array<Float>> = [];   //[ X[min, max], Y[min, max] ]

    public var mouseWheelSensitivity:Float = 1000.0; // 鼠标滚轮更改量的控制变量
    public var lerpData:Float = 0; //用于lerp到指定数据的
    public var enableMouseWheel:Bool = true;

    public var event:Void->Void = null;

    ////////////////////////////////////////////////////////////////////////////////////////////////

    public var infScroll:Bool = false; //是否无限滚动
    
    private var isDragging:Bool = false;
    private var lastMouseY:Float = 0;
    public var velocity:Float = 0; //检测的时候需要它
    private var velocityArray:Array<Float> = [];

    private var __target:Float;
    public var state:String = 'stop';
    
    // 物理参数
    private var dragSensitivity:Float = 1.0;   // 拖动灵敏度
    private var deceleration:Float = 0.9;      // 减速系数 (0.9 - 0.99 效果较好)
    private var minVelocity:Float = 0.001;       // 最小速度阈值
    private var springStrength:Float = 25.0;
    private var releaseBoost:Float = 1.1;
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    public function new(follow:Dynamic, followData:String, moveData:Array<Float>, mouseData:Array<Array<Float>>, onClick:Void->Void = null, needUpdate:Bool = true) {
        super();
        this.allowUpdate = needUpdate;
        
        this.follow = follow;
        this.followData = followData;

        this.target = Reflect.getProperty(follow, followData); //好像确实没啥用，但是可以用来初始化数据 --狐月影
        if (moveData.length == 0) infScroll = true;
        else this.moveLimit = moveData;
        this.mouseLimit = mouseData;
        
        this.event = onClick;
    }
    
    private var _lastUpdateTime:Int = 0;
    private var __lastDragTick:Int = 0;
    private var _inertiaTime:Float = 0;
    public var inputAllow:Bool = true;
    override function update(elapsed:Float) {
        if (!allowUpdate) {
            super.update(elapsed);
            return;
        }

        var mouse = FlxG.mouse;

        var checkInput:Bool = true;

        if (!(mouse.x > mouseLimit[0][0] && mouse.x < mouseLimit[0][1] && mouse.y > mouseLimit[1][0] && mouse.y < mouseLimit[1][1])) {
            endDrag();
            checkInput = false;
        }
        
        if (checkInput && inputAllow) {
            // 鼠标滚轮
            if (enableMouseWheel && mouse.wheel!= 0) {
                velocity += mouse.wheel * mouseWheelSensitivity;
                lerpData = 0;
            }
            
            // 鼠标按下
            if (mouse.justPressed) {
                startDrag(mouse.y);
                lerpData = 0;
            }
            
            // 拖动中更新位置
            if (isDragging && mouse.pressed)
            {
                updateDrag(mouse.y);
            }

            // 鼠标释放时停止拖动
            if (mouse.justReleased) {
                endDrag();
            }
        } else {
            lastMouseY = mouse.y;
        }
        
        // 惯性滑动
        if (!isDragging && Math.abs(velocity) > minVelocity) {
            applyInertia(elapsed);
        }

        if (lerpData != 0) {
            if (Math.abs(target - lerpData) < 0.01) {
                target = lerpData;
                lerpData = 0;
            } else {
                target = FlxMath.lerp(lerpData, target, Math.exp(-elapsed * 20));
            }
        }
        
        if(!infScroll) {
            if (target < moveLimit[0]) target = FlxMath.lerp(moveLimit[0], target, Math.exp(-elapsed * 20));
            if (target > moveLimit[1]) target = FlxMath.lerp(moveLimit[1], target, Math.exp(-elapsed * 20));
        }

        
        if (__target > target) state = 'up';
        else if (__target < target)state = 'down';
        else if (__target == target) state = 'stop';

        __target = target;

        Reflect.setProperty(follow, followData, target);
        
        if (event!= null) {
            event();
        }

        super.update(elapsed);
    }
    
    private function startDrag(startY:Float) {
        isDragging = true;
        lastMouseY = startY;
        velocLastMouseY = startY;
        _lastUpdateTime = FlxG.game.ticks;
        velocity = 0;
        velocityArray = [];
        __lastDragTick = FlxG.game.ticks;
        _inertiaTime = 0;
    }
    
    private var velocLastMouseY:Float = 0;
    private function updateDrag(currentY:Float) {
        var deltaY = currentY - lastMouseY;
        var now = FlxG.game.ticks;
        var deltaMs = Math.max(1, now - __lastDragTick);
        velocity = (deltaY * dragSensitivity) * (1000.0 / deltaMs);
        target += deltaY * dragSensitivity;
        lastMouseY = currentY;
        __lastDragTick = now;

        if (FlxG.game.ticks - _lastUpdateTime >= 16)
        {
            var dY = currentY - velocLastMouseY;
            var dMs = Math.max(1, FlxG.game.ticks - _lastUpdateTime);
            var vps = (dY * dragSensitivity) * (1000.0 / dMs);
            velocUpdate(vps);
            velocLastMouseY = currentY;
            
            _lastUpdateTime = FlxG.game.ticks;
        }
    }
    
    private function endDrag() {
        if (!isDragging) return;
        isDragging = false;
        if (velocLastMouseY != lastMouseY) {
            var dY = lastMouseY - velocLastMouseY;
            var dMs = Math.max(1, FlxG.game.ticks - _lastUpdateTime);
            var vps = (dY * dragSensitivity) * (1000.0 / dMs);
            velocUpdate(vps);
            velocLastMouseY = lastMouseY;
        }
        velocityChange();
        velocity *= releaseBoost;
        _inertiaTime = 0;
    }

    var isPositive:Bool = true; //正数检测
    private function velocUpdate(data:Float) {
        var zero = Math.abs(data) < minVelocity;
        if (isPositive) {
            if (data > 0) {
                velocityArray = velocityArray.filter(function(v) return Math.abs(v) >= minVelocity);
                velocityArray.push(data);
                if (velocityArray.length > 11) velocityArray.shift();
            } else if (data < 0) {
                velocityArray = [];
                if (!zero) velocityArray.push(data);
                isPositive = false;
            } else {
                velocityArray.push(0);
                if (velocityArray.length > 11) velocityArray.shift();
            }
        } else {
            if (data < 0) {
                velocityArray = velocityArray.filter(function(v) return Math.abs(v) >= minVelocity);
                velocityArray.push(data);
                if (velocityArray.length > 11) velocityArray.shift();
            } else if (data > 0)  {
                velocityArray = [];
                if (!zero) velocityArray.push(data);
                isPositive = true;
            } else {
                velocityArray.push(0);
                if (velocityArray.length > 11) velocityArray.shift();
            }
        }
    }

    private function velocityChange() {
        if (velocityArray.length < 3) {
            velocity = 0;
            return;
        }
        var delete = Std.int(velocityArray.length / 6);
        var sorted = velocityArray.copy();
        sorted.sort(Reflect.compare);
        var low = sorted[delete];
        var high = sorted[sorted.length - 1 - delete];
        var filtered:Array<Float> = [];
        for (v in velocityArray) if (v >= low && v <= high) filtered.push(v);
        if (filtered.length == 0) filtered = velocityArray.copy();
        var sum:Float = 0;
        var weightSum:Float = 0;
        var n = filtered.length;
        for (i in 0...n) {
            var w = Math.pow(1.25, i);
            sum += filtered[i] * w;
            weightSum += w;
        }
        velocity = sum / weightSum;
    }

    private function applyInertia(elapsed:Float) {
        _inertiaTime += elapsed;
        var decelFactor = Math.pow(deceleration, elapsed * 60);
        velocity *= decelFactor;
        if (!infScroll) {
            if (target < moveLimit[0]) {
                var acc = (moveLimit[0] - target) * springStrength;
                velocity += acc * elapsed;
            } else if (target > moveLimit[1]) {
                var acc2 = (moveLimit[1] - target) * springStrength;
                velocity += acc2 * elapsed;
            }
        }
        if (Math.abs(velocity) < minVelocity) {
            velocity = 0;
            return;
        }
        target += velocity * elapsed;
    }
}
