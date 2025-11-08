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

    public var lerpData:Float = 0; //用于lerp到指定数据的

    public var infScroll:Bool = false;
    
    public var event:Void->Void = null;

    ////////////////////////////////////////////////////////////////////////////////////////////////
    
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
    
    // 鼠标滚轮相关参数
    public var mouseWheelSensitivity:Float = 20.0; // 鼠标滚轮更改量的控制变量(可被修改)
    
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
    public var inputAllow:Bool = true;
    override function update(elapsed:Float) {
        if (!allowUpdate) {
            super.update(elapsed);
            return;
        }

        var mouse = FlxG.mouse;

        var checkInput:Bool = true;

        if (!(mouse.x > mouseLimit[0][0] && mouse.x < mouseLimit[0][1] && mouse.y > mouseLimit[1][0] && mouse.y < mouseLimit[1][1])) {
            if (isDragging) 
                endDrag();
            checkInput = false;
        }
        
        if (checkInput && inputAllow) {
            // 鼠标滚轮
            if (mouse.wheel!= 0) {
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
            else if (isDragging && mouse.justReleased) {
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
        velocity = 0;
        velocityArray = [];
    }
    
    private function updateDrag(currentY:Float) {
        var deltaY = currentY - lastMouseY;
        velocity = deltaY * dragSensitivity;
        target += velocity;
        lastMouseY = currentY;

        if (FlxG.game.ticks - _lastUpdateTime >= 100)
        {
            velocUpdate(velocity);
        }
    }
    
    private function endDrag() {
        isDragging = false;
        velocityChange();
    }

    var isPositive:Bool = true; //正数检测
    private function velocUpdate(data:Float) {
        if (isPositive) { //之前是正数
            if (data > 0) { //正数
                velocityArray.remove(0); //一旦发现有移动，删除帧更新时候插入的0
                velocityArray.push(velocity);
                if (velocityArray.length > 11) velocityArray.shift();
            } else if (data < 0) { //负数
                velocityArray = [];
                velocityArray.push(velocity);
                isPositive = false;
            } else {
                velocityArray.push(velocity); //如果确实没动就加上0进入计算
                if (velocityArray.length > 11) velocityArray.shift();
            }
        } else { //之前是负数
            if (data < 0) { //负数
                velocityArray.remove(0); //一旦发现有移动，删除帧更新时候插入的0
                velocityArray.push(velocity);
                if (velocityArray.length > 11) velocityArray.shift();
            } else if (data > 0)  { //正数
                velocityArray = [];
                velocityArray.push(velocity);
                isPositive = true;
            } else {
                velocityArray.push(velocity); //如果确实没动就加上0进入计算
                if (velocityArray.length > 11) velocityArray.shift();
            }
        } 
    }

    private function velocityChange() {
        if (velocityArray.length < 3) { // 样本太少时不处理
            velocity = 0;
            return;
        }
        
        // 减少过滤比例
        var delete = Std.int(velocityArray.length / 6);
        velocityArray.sort(Reflect.compare);
        
        // 保留中间部分数据
        var filtered = velocityArray.slice(delete, velocityArray.length - delete);
        
        // 计算加权平均(越新的数据权重越高)
        var sum:Float = 0;
        var weightSum:Float = 0;
        for (i in 0...filtered.length) {
            var weight = (i + 1) / filtered.length; // 线性权重
            sum += filtered[i] * weight;
            weightSum += weight;
        }
        
        velocity = sum / weightSum;
        
        // 帧率补偿
        velocity *= EngineSet.FPSfix(1.0, true);
    }

    private function applyInertia(elapsed:Float) {
        // 使用更平滑的减速曲线
        var decelFactor = Math.pow(deceleration, elapsed * 60);
        velocity *= decelFactor;
        
        // 添加速度衰减下限
        if (Math.abs(velocity) < minVelocity) {
            velocity = 0;
        } else {
            target += velocity * elapsed * 60;
        }
    }
}