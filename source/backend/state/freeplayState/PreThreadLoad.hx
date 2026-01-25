package backend.state.freeplayState;

import sys.thread.Thread;
import sys.thread.FixedThreadPool;
import sys.thread.Mutex;
import thread.ThreadEvent;

import Lambda;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

typedef DataPrepare = {
    modPath:String,
    bgPath:String,
    iconPath:String,
    color:Array<Int>
}

class PreThreadLoad {
    public var loadFinish:Bool = false;

    public var maxCount:Int = 0;
    public var count:Int = 0;

    ///////////////////////////////////////////////////////

    var loadRect:Array<DataPrepare> = [];
    var loadIcon:Array<String> = [];

    var rectPool:FixedThreadPool = null;
    var iconPool:FixedThreadPool = null;
    
    var threadCount = 0;
    var countMutex:Mutex;

    ///////////////////////////////////////////////////////

    var devTrace:Bool = true; //开发测试用的

    public function new() {
        countMutex = new Mutex();
    }

    var rectPre:Map<String, DataPrepare> = [];
    var iconPre:Array<String> = [];
    public function start(data:Array<DataPrepare>) {
        ThreadEvent.create(function() {
            for (mem in data) {
                var rd:DataPrepare = mem;
                rd.bgPath = bgPathCheck(rd.modPath, 'data/${rd.bgPath}/bg');
                if (!rectPre.exists(rd.bgPath + ' ' + rd.color))
                    rectPre.set(rd.bgPath + ' ' + rd.color, rd);

                var id:String = iconCheck(rd.modPath, mem.iconPath);
                if (!iconPre.contains(id))
                    iconPre.push(id);
            }
            maxCount = Std.int(Lambda.count(rectPre) + iconPre.length);
            threadCount = CoolUtil.getCPUThreadsCount() - 1;
            if (devTrace) trace('load count: ' + maxCount);

            for (key => value in rectPre) {
                loadRect.push(value);
            }
            loadIcon = iconPre;
        }, load);
    }

    static public function bgPathCheck(mod:String, path:String):String {
        if (!FileSystem.exists(Paths.modCachePath(mod, path + '.png')))
            path = 'images/menuDesat.png';     
        return Paths.modCachePath(mod, path);
    }

    static public function iconCheck(mod:String, path:String):String {
        var name:String = 'images/icons/' + path;
        if (!FileSystem.exists(Paths.modCachePath(mod, name + '.png')))
            name = 'images/icons/icon-' + path;
        if (!FileSystem.exists(Paths.modCachePath(mod, name + '.png')))
            name = 'images/icons/icon-face';
        return Paths.modCachePath(mod, name + '.png');
    }

    function load() {
        Sys.sleep(0.005); //先释放下线程

        lineShape = null;
        var light = new Rect(0, 0, 560, SongRect.fixHeight, SongRect.fixHeight / 2, SongRect.fixHeight / 2, FlxColor.WHITE, 1, 1, EngineSet.mainColor);
        drawLine(light.pixels); //lineShape此时赋予数据

        var rectThread:Int = Math.ceil(threadCount * 0.75);
        var iconThread:Int = Std.int(Math.max(1, threadCount - rectThread));
        if (devTrace) trace('thread count: ' + threadCount + ' rect: ' + rectThread + ' icon: ' + iconThread);

        rectPool = new FixedThreadPool(rectThread);
        iconPool = new FixedThreadPool(iconThread);

        for (i in 0...loadRect.length) {
            var memData:DataPrepare = loadRect[i];
            rectPool.run(() -> {
                var file:String = memData.bgPath;
                try
				{	
				    var newGraphic:FlxGraphic = null;
					var bitmap:BitmapData = null;
					
					if (Cache.currentTrackedFrames.exists(file + ' r:' + memData.color[0] + ' g:' + memData.color[1] + ' b:' + memData.color[2]))
					{
                        if (devTrace) trace('RECT: already cached ' + file + ' r:' + memData.color[0] + ' g:' + memData.color[1] + ' b:' + memData.color[2]);
						return;
					}
					else if (FileSystem.exists(file)) {
						bitmap = BitmapData.fromFile(file);
					} else {
						trace('RECT: no such image ${file} exists');
						return;
					}

					if (bitmap != null) {
						newGraphic = Paths.cacheBitmap(file, bitmap, false, true);
					} else {
						trace('RECT: oh no the bitmap is null NOOOO ${file}');		
					}
										                         
                    if (newGraphic == null) {
    
                        trace('RECT: load ' + file + ' fail');
                        return;
                    }
                    
                    var matrix:Matrix = new Matrix();
                    var scale:Float = light.width / newGraphic.width;
                    if (light.height / newGraphic.height > scale)
                        scale = light.height / newGraphic.height;
                    matrix.scale(scale, scale);
                    matrix.translate(-(newGraphic.width * scale - light.width) / 2, -(newGraphic.height * scale - light.height) / 2);
                    
                    var resizedBitmapData:BitmapData = new BitmapData(Std.int(light.width), Std.int(light.height), true, 0x00000000);
                    resizedBitmapData.draw(newGraphic.bitmap, matrix);
                    
                    if (file.indexOf('menuDesat') != -1)
                    {
                        var colorTransform:ColorTransform = new ColorTransform();
                        var color:FlxColor = FlxColor.fromRGB(memData.color[0], memData.color[1], memData.color[2]);
                        colorTransform.redMultiplier = color.redFloat;
                        colorTransform.greenMultiplier = color.greenFloat;
                        colorTransform.blueMultiplier = color.blueFloat;
                        
                        resizedBitmapData.colorTransform(new Rectangle(0, 0, resizedBitmapData.width, resizedBitmapData.height), colorTransform);
                    }
                    
                    drawLine(resizedBitmapData);
                    
                    resizedBitmapData.copyChannel(light.pixels, new Rectangle(0, 0, light.width, light.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
    
                    newGraphic = FlxGraphic.fromBitmapData(resizedBitmapData);
                    
                    countMutex.acquire();
                        count++;
                        if (count >= maxCount) {
                            loadFinish = true;
                            rectPool.shutdown();
                            rectPool = null;
                            iconPool.shutdown();
                            iconPool = null;
                        }
                        
                        Cache.setFrame(file + ' r:' + memData.color[0] + ' g:' + memData.color[1] + ' b:' + memData.color[2], {graphic:newGraphic, frame:null});
                    countMutex.release();
                    if (devTrace) trace('RECT: load ' + file + ' color r:' + memData.color[0] + ' g:' + memData.color[1] + ' b:' + memData.color[2] + ' finish');
                }
				catch (e:Dynamic)
				{
					Sys.sleep(0.001);
					trace('RECT: ERROR! fail on preloading image ' + file);
				}
            });
        }

        for (i in 0...loadIcon.length) {
            iconPool.run(() -> {
                var file:String = loadIcon[i];
                try
                {	
                    var newGraphic:FlxGraphic = null;
                    var bitmap:BitmapData = null;
                    
                    if (Cache.currentTrackedFrames.exists(file))
                    {
                        trace('ICON: already cached ' + file);
                        return;
                    }
                    else if (FileSystem.exists(file)) {
                        bitmap = BitmapData.fromFile(file);
                    } else {
                        trace('ICON: no such image ${file} exists');
                        return;
                    }

                    if (bitmap != null) {
                        newGraphic = Paths.cacheBitmap(file, bitmap, false, true);
                    } else {
                        trace('oh no the bitmap is null NOOOO ${file}');		
                    }
                                                                    
                    if (newGraphic == null) {

                        trace('ICON: load ' + file + ' fail');
                        return;
                    }
                    
                    countMutex.acquire();
                        count++;
                        
                        if (count >= maxCount) {
                            loadFinish = true;
                            rectPool.shutdown();
                            rectPool = null;
                            iconPool.shutdown();
                            iconPool = null;
                        }
                        
                        Cache.setFrame(file, {graphic:newGraphic, frame:null});
                    countMutex.release();
                    if (devTrace) trace('ICON: load ' + file + ' finish');
                }
                catch (e:Dynamic)
                {
                    Sys.sleep(0.001);
                    trace('ICON: ERROR! fail on preloading image ' + file);
                }
            });
        }
    }

    static var lineShape:Shape = null;
    function drawLine(bitmap:BitmapData)
	{
        if (lineShape == null) {
            lineShape = new Shape();
            var lineSize:Int = 2;
            var round:Int = Std.int(bitmap.height / 2);
            lineShape.graphics.beginFill(EngineSet.mainColor);
            lineShape.graphics.lineStyle(1, EngineSet.mainColor, 1);
            lineShape.graphics.drawRoundRect(0, 0, bitmap.width, bitmap.height, round, round);
            lineShape.graphics.lineStyle(0, 0, 0);
            lineShape.graphics.drawRoundRect(lineSize, lineSize, bitmap.width - lineSize * 2, bitmap.height - lineSize * 2, round - lineSize * 2, round - lineSize * 2);
            lineShape.graphics.endFill();
        }

		bitmap.draw(lineShape);
	}
}
