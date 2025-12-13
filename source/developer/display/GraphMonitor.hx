package developer.display;

/*
    GraphMonitor - Performance Visualization Tool
    Author: [beihu235（北狐丶望舒），AI]
    
    A customizable performance monitor that displays real-time data graphs (FPS, Memory, etc.)
    with support for multiple tabs, auto-scaling, and extensive styling options.
    
    Usage:
    
    1. Instantiate:
       var monitor = new GraphMonitor(x, y, width, height);
       addChild(monitor);
       
    2. Add Monitors:
       monitor.addMonitor("FPS", "fps", () -> currentFPS, 0, 120);
       monitor.addMonitor("Mem", "MB", () -> System.totalMemory / 1024 / 1024);
       
    3. Customization (Optional):
       monitor.setBackground(0x000000, 0.5);
       monitor.graphFillAlpha = 0.5;
       monitor.tabTextColor = 0xAAAAAA;
       monitor.tabTextActiveColor = 0xFFFFFF;
       
    4. Layout:
       monitor.marginGraphBottom = 60; // Increase bottom space
*/

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.GradientType;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormatAlign;
import openfl.display.Graphics;
import openfl.utils.Assets;
import openfl.events.Event;
import openfl.Lib;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

// import openfl.display.Bitmap; // Removed
// import openfl.display.BitmapData; // Removed
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.geom.Point;

typedef MonitorItem = {
    var name:String;
    var suffix:String;
    var func:Void->Float;
    var min:Dynamic; // Float or Void->Float
    var max:Dynamic; // Float or Void->Float
    var minColor:FlxColor;
    var maxColor:FlxColor;
    var ?titleLeft:String;
    var ?titleRight:String;
    
    // Data history (Ring Buffer)
    var dataHistory:openfl.Vector<Float>;
    var historyIndex:Int; // Current write position
    
    // Optimization flags
    var minIsFunc:Bool;
    var maxIsFunc:Bool;

    // Cached HSL for min/max colors
    var minHue:Float;
    var minSat:Float;
    var minLight:Float;
    var maxHue:Float;
    var maxSat:Float;
    var maxLight:Float;
}

class GraphMonitor extends Sprite
{
    // --- Public Components ---
    
    /** Background shape of the monitor */
    /** 监控器的背景图形对象 */
    public var bg:Shape;
    
    /** Top-left title text field */
    /** 左上角的标题文本框 */
    public var titleLeft:TextField;
    
    /** Top-right title text field */
    /** 右上角的标题文本框 */
    public var titleRight:TextField;
    
    /** The grid lines layer (static layer) */
    /** 网格线绘制层（静态层） */
    public var gridLayer:Shape;

    /** The main graph drawing area (Vector Shape) */
    /** 主要的波形图绘制区域（矢量图层） */
    public var graph:Shape;
    private var graphBitmapData:BitmapData;
    private var graphBitmap:Bitmap;
    
    /** Container for axis labels (left side numbers) */
    /** 坐标轴标签容器（左侧数值） */
    public var labelsContainer:Sprite; 
    
    /** Container for bottom tabs */
    /** 底部标签页容器 */
    public var tabsContainer:Sprite;

    /** The selector highlight for the active tab */
    /** 底部标签页的选中高亮块 */
    public var tabSelector:Sprite;
    private var tabItems:Array<Sprite> = [];

    // --- Configuration Variables ---

    /** Maximum number of history points to keep (determines graph density) */
    /** 保留的历史数据点数量（决定图表密度） */
    public var maxHistory:Int = 60; 

    // --- Style Properties (Customizable) ---

    /** Alpha transparency of the graph fill area (0.0 - 1.0) */
    /** 图表填充区域的透明度 (0.0 - 1.0) */
    public var graphFillAlpha:Float = 0.3;
    
    /** Alpha transparency of the graph line (0.0 - 1.0) */
    /** 图表线条的透明度 (0.0 - 1.0) */
    public var graphLineAlpha:Float = 1.0;
    public var graphLineThickness:Float = 2.0;
    public var useSmoothCurve:Bool = true;

    public function setSmoothCurve(enable:Bool):Void {
        useSmoothCurve = enable;
    }
    
    /** Color of the horizontal grid lines */
    /** 水平网格线的颜色 */
    public var gridLineColor:FlxColor = 0xFFFFFF;
    
    /** Alpha transparency of the grid lines */
    /** 网格线的透明度 */
    public var gridLineAlpha:Float = 1.0;
    
    /** Color of the axis labels (left side numbers) */
    /** 坐标轴标签（左侧数字）的颜色 */
    public var axisLabelColor:FlxColor = 0xFFFFFF;
    
    /** Alpha transparency of the axis labels */
    /** 坐标轴标签的透明度 */
    public var axisLabelAlpha:Float = 1.0;
    
    /** Color of inactive tab text */
    /** 未选中标签的文字颜色 */
    public var tabTextColor:FlxColor = 0xFFFFFF;
    
    /** Color of active tab text */
    /** 选中标签的文字颜色 */
    public var tabTextActiveColor:FlxColor = 0xFFFFFF;
    
    /** Alpha transparency of tab text */
    /** 标签文字的透明度 */
    public var tabTextAlpha:Float = 1.0;
    
    /** Color of the top-left title */
    /** 左上角标题颜色 */
    public var titleLeftColor:FlxColor = 0xFFFFFF;
    
    /** Color of the top-right title */
    /** 右上角标题颜色 */
    public var titleRightColor:FlxColor = 0xFFFFFF;
    
    /** Color of the active tab selector background */
    /** 底部选中块的背景颜色 */
    public var tabSelectorColor:FlxColor = 0xFFFFFF;
    
    /** Alpha transparency of the active tab selector */
    /** 底部选中块的透明度 */
    public var tabSelectorAlpha:Float = 1.0;
    
    /** Manual X offset for mouse input detection (useful if parent is moved) */
    /** 鼠标输入检测的手动 X 轴偏移量（如果父容器移动了，可用此修正） */
    public var inputFixX:Float = 0.0;
    
    /** Manual Y offset for mouse input detection */
    /** 鼠标输入检测的手动 Y 轴偏移量 */
    public var inputFixY:Float = 0.0;
    
    // --- Layout Margins ---
    
    /** Left margin for the graph (space for axis labels) */
    /** 图表左边距（留给坐标轴标签的空间） */
    public var marginGraphLeft:Float = 40.0; 
    
    /** Right margin for the graph */
    /** 图表右边距 */
    public var marginGraphRight:Float = 20.0;
    
    /** Top margin for the graph (space for title) */
    /** 图表上边距（留给标题的空间） */
    public var marginGraphTop:Float = 50.0; 
    
    /** Bottom margin for the graph (space for tabs) */
    /** 图表下边距（留给底部标签的空间） */
    public var marginGraphBottom:Float = 50.0; 

    // --- Private Variables ---

    public var monitors:Array<MonitorItem> = [];
    public var currentIndex:Int = 0;
    private var tabTween:FlxTween;
    private var _width:Float;
    private var _height:Float;
    private var bgColor:FlxColor = 0xFFFFFF;
    private var bgAlpha:Float = 1.0;
    
    // Optimization state
    private var lastMinVal:Float = -999999.0;
    private var lastMaxVal:Float = -999999.0;
    
    // Optimization pools
    private var labelPool:Array<TextField> = [];
    private var activeLabels:Array<TextField> = [];
    private var segFillShape:Shape = new Shape();
    private var strokeShape:Shape = new Shape();
    private var tmpMatrix:Matrix = new Matrix();
    private var gradientMatrix:Matrix = new Matrix();
    private var tmpRect:Rectangle = new Rectangle();
    private var gradColors:Array<Int> = [0, 0];
    private var gradAlphas:Array<Float> = [0.0, 0.0];
    private var gradRatios:Array<Int> = [0, 255];
    private var axisSteps:Array<Float> = [0, 0.2, 0.4, 0.6, 0.8, 1.0];
    private var axisLabelFormat:TextFormat;
    private var fontName:String;
    private var tabFmtActive:TextFormat;
    private var tabFmtInactive:TextFormat;
    private var colWidthCache:Int = -1;
    private var lastGraphWCache:Int = -1;
    private var lastMaxHistoryCache:Int = -1;

    public function new(x:Float = 0, y:Float = 0, w:Float = 300, h:Float = 200)
    {
        super();
        this.x = x;
        this.y = y;
        this._width = w;
        this._height = h;

        // Background (White rounded rect like the image)
        bg = new Shape();
        // Initial draw
        updateBackground();
        addChild(bg);

        // Top Left Title
        fontName = Assets.getFont("assets/fonts/FPS.ttf").fontName;
        titleLeft = new TextField();
        titleLeft.defaultTextFormat = new TextFormat(fontName, 24, titleLeftColor, true, null, null, null, null, TextFormatAlign.LEFT);
        titleLeft.autoSize = TextFieldAutoSize.LEFT;
        titleLeft.text = "System Monitor";
        titleLeft.x = 20;
        titleLeft.y = 10;
        titleLeft.selectable = false;
        addChild(titleLeft);

        // Top Right Title (Category)
        titleRight = new TextField();
        titleRight.defaultTextFormat = new TextFormat(fontName, 20, titleRightColor, true);
        titleRight.autoSize = TextFieldAutoSize.RIGHT;
        titleRight.text = "Category";
        titleRight.x = w - 20; // Will be adjusted in update
        titleRight.y = 12;
        titleRight.selectable = false;
        addChild(titleRight);

        // Grid Layer (Static)
        gridLayer = new Shape();
        gridLayer.x = marginGraphLeft;
        gridLayer.y = marginGraphTop;
        addChild(gridLayer);

        var graphW = Std.int(_width - (marginGraphLeft + marginGraphRight));
        var graphH = Std.int(_height - (marginGraphTop + marginGraphBottom));
        graphBitmapData = new BitmapData(graphW, graphH, true, 0x00000000);
        graphBitmap = new Bitmap(graphBitmapData);
        graphBitmap.x = marginGraphLeft;
        graphBitmap.y = marginGraphTop;
        addChild(graphBitmap);

        graph = new Shape();
        graph.x = marginGraphLeft;
        graph.y = marginGraphTop;
        addChild(graph);
        
        labelsContainer = new Sprite();
        labelsContainer.x = graph.x;
        labelsContainer.y = graph.y;
        addChild(labelsContainer);

        // Tabs Container
        tabsContainer = new Sprite();
        tabsContainer.x = 0;
        // Default pos, will be updated based on marginGraphBottom in updateLayout or similar
        tabsContainer.y = h - marginGraphBottom; 
        addChild(tabsContainer);

        // Default Data
        maxHistory = Std.int((w - 40) / 4); // roughly 4px per point
        
        // Auto-start update loop
        addEventListener(Event.ENTER_UPDATE, onEnterFrame);

        axisLabelFormat = new TextFormat(fontName, 10, axisLabelColor);
        tabFmtActive = new TextFormat(fontName, 12, tabTextActiveColor, true);
        tabFmtActive.align = TextFormatAlign.CENTER;
        tabFmtActive.leading = 2;
        tabFmtInactive = new TextFormat(fontName, 12, tabTextColor, false);
        tabFmtInactive.align = TextFormatAlign.CENTER;
        tabFmtInactive.leading = 2;
    }
    
    private function onEnterFrame(e:Event):Void
    {
        // Handle Input Check (Only mouse event logic here)
        if (FlxG.mouse.justPressed)
        {
            var mx = Lib.current.stage.mouseX;
            var my = Lib.current.stage.mouseY;
            
            // Use this.x/y plus manual fix
            var absX = this.x + inputFixX; 
            var absY = this.y + inputFixY; 
            
            // Check overlap with tabs container area (bottom margin area)
            if (mx >= absX && mx <= absX + _width && my >= absY + _height - marginGraphBottom && my <= absY + _height)
            {
                var tabWidth = _width / monitors.length;
                var clickedIndex = Math.floor((mx - absX) / tabWidth);
                if (clickedIndex >= 0 && clickedIndex < monitors.length)
                {
                    selectMonitor(clickedIndex);
                }
            }
        }
    }

    private function updateBackground():Void
    {
        bg.graphics.clear();
        bg.graphics.beginFill(bgColor, bgAlpha); // Custom bg color and alpha
        bg.graphics.drawRoundRect(0, 0, _width, _height, 20, 20);
        bg.graphics.endFill();
    }
    
    public function setBackground(color:FlxColor = 0xFFFFFF, alpha:Float = 1.0):Void
    {
        this.bgColor = color;
        this.bgAlpha = alpha;
        updateBackground();
    }

    public function addMonitor(name:String, suffix:String, func:Void->Float, min:Dynamic = 0, max:Dynamic = null, minColor:FlxColor = 0xFF00FF00, maxColor:FlxColor = 0xFFFF0000, ?titleLeft:String, ?titleRight:String):Void
    {
        var minHue = minColor.hue;
        var minSat = minColor.saturation;
        var minLight = minColor.lightness;
        var maxHue = maxColor.hue;
        var maxSat = maxColor.saturation;
        var maxLight = maxColor.lightness;

        monitors.push({
            name: name,
            suffix: suffix,
            func: func,
            min: min,
            max: max,
            minColor: minColor,
            maxColor: maxColor,
            titleLeft: titleLeft,
            titleRight: titleRight,
            minIsFunc: Reflect.isFunction(min),
            maxIsFunc: max != null && Reflect.isFunction(max),
            dataHistory: new openfl.Vector<Float>(maxHistory, true), // Fixed length Vector
            historyIndex: 0,
            minHue: minHue,
            minSat: minSat,
            minLight: minLight,
            maxHue: maxHue,
            maxSat: maxSat,
            maxLight: maxLight
        });

        // Pre-fill history with min value
        var m = monitors[monitors.length - 1];
        var minVal:Float = m.minIsFunc ? m.min() : cast m.min;
        for(i in 0...maxHistory) m.dataHistory[i] = minVal;

        if (monitors.length == 1)
        {
            selectMonitor(0);
        }
        refreshTabs();
    }

    public function selectMonitor(index:Int):Void
    {
        if (index < 0 || index >= monitors.length) return;
        currentIndex = index;
        
        var m = monitors[index];
        var minVal:Float = m.minIsFunc ? m.min() : cast m.min;
        
        // Reset dirty check state to force label update
        lastMinVal = -999999.0;
        lastMaxVal = -999999.0;
        
        // Clear graph
        graph.graphics.clear();

        // Redraw BG and move containers
        updateBackground();
        
        // Update layout based on potentially changed margins
        graph.x = marginGraphLeft;
        graph.y = marginGraphTop;
        if (graphBitmap != null) {
            graphBitmap.x = marginGraphLeft;
            graphBitmap.y = marginGraphTop;
        }
        gridLayer.x = marginGraphLeft;
        gridLayer.y = marginGraphTop;
        labelsContainer.x = graph.x;
        labelsContainer.y = graph.y;
        tabsContainer.y = _height - marginGraphBottom;
        
        // Update Titles
        titleLeft.text = (m.titleLeft != null) ? m.titleLeft : m.name;
        
        var idx = (m.historyIndex - 1 + maxHistory) % maxHistory;
        var currentVal = m.dataHistory[idx];
        var displayVal = Math.floor(currentVal * 10) / 10;
        
        if (m.titleRight != null) 
            titleRight.text = m.titleRight;
        else
            titleRight.text = displayVal + " " + m.suffix;
            
        titleRight.x = _width - 20 - titleRight.width; // Re-align right
        
        // Update Title Colors if needed
        var formatL = titleLeft.defaultTextFormat; 
        formatL.color = titleLeftColor; 
        formatL.align = TextFormatAlign.LEFT; // Ensure alignment stays left
        titleLeft.setTextFormat(formatL); 
        titleLeft.defaultTextFormat = formatL;
        
        var formatR = titleRight.defaultTextFormat; formatR.color = titleRightColor; titleRight.setTextFormat(formatR); titleRight.defaultTextFormat = formatR;

        // Animate Tab Selector
         if (tabSelector != null)
         {
             var tabWidth = _width / monitors.length;
             var targetX = (index * tabWidth) + 5;
             if (tabTween != null) tabTween.cancel();
             tabTween = FlxTween.tween(tabSelector, {x: targetX}, 0.25, {ease: FlxEase.circOut});
         }
 
         refreshTabs();
         
        drawGrid(m);
        rebuildGraphBitmap(m);
    }

    private function refreshTabs():Void
    {
        var tabWidth = _width / (monitors.length == 0 ? 1 : monitors.length);
        if (tabSelector == null)
        {
            tabSelector = new Sprite();
        }
        tabSelector.graphics.clear();
        tabSelector.graphics.beginFill(tabSelectorColor, tabSelectorAlpha);
        var selectorH = marginGraphBottom - 10;
        tabSelector.graphics.drawRoundRect(0, (marginGraphBottom - selectorH)/2, tabWidth - 10, selectorH, 10, 10);
        tabSelector.graphics.endFill();
        if (tabSelector.parent != tabsContainer) tabsContainer.addChildAt(tabSelector, 0);

        while (tabItems.length > monitors.length)
        {
            var rem = tabItems.pop();
            if (rem != null && rem.parent != null) rem.parent.removeChild(rem);
        }

        for (i in 0...monitors.length)
        {
            var item = monitors[i];
            var tab:Sprite;
            if (i < tabItems.length)
            {
                tab = tabItems[i];
            }
            else
            {
                tab = new Sprite();
                var tf = new TextField();
                tf.defaultTextFormat = tabFmtInactive;
                tf.alpha = tabTextAlpha;
                tf.autoSize = TextFieldAutoSize.CENTER;
                tf.name = "tf_" + i;
                tf.selectable = false;
                tf.mouseEnabled = false;
                tab.addChild(tf);
                tabItems.push(tab);
                tabsContainer.addChild(tab);
            }

            var tf = cast(tab.getChildByName("tf_" + i), TextField);
            var idx = (item.historyIndex - 1 + maxHistory) % maxHistory;
            var val = item.dataHistory[idx];
            var displayVal = Math.floor(val * 10) / 10;
            tf.text = item.name + "\n" + displayVal + " " + item.suffix;

            var maxWidth = tabWidth - 4;
            tf.scaleX = 1.0;
            tf.scaleY = 1.0;
            if (tf.width > maxWidth)
            {
                tf.scaleX = maxWidth / tf.width;
                tf.scaleY = tf.scaleX;
            }

            tf.x = (tabWidth - tf.width) / 2;
            tf.y = (marginGraphBottom - tf.height) / 2;

            tab.x = i * tabWidth;
        }

        var tabWidthAll = _width / (monitors.length == 0 ? 1 : monitors.length);
        var targetX = (currentIndex * tabWidthAll) + 5;
        tabSelector.x = targetX;
    }

    public function update():Void
    {
        if (monitors.length == 0) return;
        
        // Update ALL monitors' data history
        for (m in monitors)
        {
            var val = m.func();
            // Ring buffer write
            m.dataHistory[m.historyIndex] = val;
            m.historyIndex = (m.historyIndex + 1) % maxHistory;
        }

        var currentMon = monitors[currentIndex];
        drawGraphIncremental(currentMon);

        // Update Tab Texts (Current Values) and Right Title
        for (i in 0...monitors.length)
        {
            var m = monitors[i];
            
            if (i == currentIndex && m.titleRight == null)
            {
                var idx = (m.historyIndex - 1 + maxHistory) % maxHistory;
                var currentVal = m.dataHistory[idx];
                var displayVal = Math.floor(currentVal * 10) / 10;
                titleRight.text = displayVal + " " + m.suffix;
                titleRight.x = _width - 20 - titleRight.width; 
            }

            if (i >= tabItems.length) break;
            var tab = tabItems[i];
            var tf = cast(tab.getChildByName("tf_" + i), TextField);
            if (tf != null)
            {
                var m = monitors[i];
                var idx = (m.historyIndex - 1 + maxHistory) % maxHistory;
                var v = m.dataHistory[idx];
                
                var displayVal = Math.floor(v * 10) / 10; // Simple formatting
                tf.text = m.name + "\n" + displayVal + " " + m.suffix;
                
                var tabWidth = _width / monitors.length;
                var maxWidth = tabWidth - 4;
                
                tf.scaleX = 1.0; 
                tf.scaleY = 1.0;
                
                if (tf.width > maxWidth)
                {
                    tf.scaleX = maxWidth / tf.width;
                    tf.scaleY = tf.scaleX;
                }
                
                tf.x = (tabWidth - tf.width) / 2;
                tf.y = (marginGraphBottom - tf.height) / 2;
                
                 var isSelected = (i == currentIndex);
                 var color = isSelected ? tabTextActiveColor : tabTextColor;
                 tf.setTextFormat(isSelected ? tabFmtActive : tabFmtInactive);
                 tf.alpha = tabTextAlpha;
            }
        }
    }

    private function getColWidth(graphW:Int):Int
    {
        if (colWidthCache == -1 || lastGraphWCache != graphW || lastMaxHistoryCache != maxHistory)
        {
            var cw = Std.int(Math.max(1, Math.round(graphW / (maxHistory - 1))));
            if (cw > graphW) cw = graphW;
            colWidthCache = cw;
            lastGraphWCache = graphW;
            lastMaxHistoryCache = maxHistory;
        }
        return colWidthCache;
    }
    
    // Separated static grid drawing to avoid redrawing every frame
    private function drawGrid(m:MonitorItem):Void
    {
        gridLayer.graphics.clear();
        
        var graphW = _width - (marginGraphLeft + marginGraphRight);
        var graphH = _height - (marginGraphTop + marginGraphBottom);
        
        // Draw grid lines
        gridLayer.graphics.lineStyle(1, gridLineColor, gridLineAlpha);
        
        for (ratio in axisSteps)
        {
            var lineY = graphH - (ratio * graphH);
            
            // Draw Line
            gridLayer.graphics.moveTo(0, lineY); 
            gridLayer.graphics.lineTo(graphW, lineY);
        }
    }
    
    // Get a label from pool or create new
    private function getLabel():TextField
    {
        if (labelPool.length > 0) return labelPool.pop();
        
        var tf = new TextField();
        tf.defaultTextFormat = new TextFormat(Assets.getFont("assets/fonts/FPS.ttf").fontName, 10, axisLabelColor);
        tf.autoSize = TextFieldAutoSize.LEFT; 
        tf.selectable = false;
        return tf;
    }
    
    // Return label to pool
    private function recycleLabel(tf:TextField):Void
    {
        if (tf.parent != null) tf.parent.removeChild(tf);
        labelPool.push(tf);
    }

    private function drawAxisLabels(m:MonitorItem, graphH:Int, minVal:Float, maxVal:Float):Void
    {
        while (activeLabels.length > 0) recycleLabel(activeLabels.pop());
        for (ratio in axisSteps)
        {
            var lineY = graphH - (ratio * graphH);
            var v = minVal + (maxVal - minVal) * ratio;
            var labelText = "";
            var displayVal = Math.floor(v * 10) / 10;
            if (m.suffix == "%") labelText = displayVal + "%"; else labelText = Std.string(displayVal);
            var tf = getLabel();
            axisLabelFormat.color = axisLabelColor;
            tf.defaultTextFormat = axisLabelFormat;
            tf.alpha = axisLabelAlpha;
            tf.text = labelText;
            tf.x = -tf.width - 5;
            tf.y = lineY - tf.height / 2;
            labelsContainer.addChild(tf);
            activeLabels.push(tf);
        }
    }

    // Helper to get color for a specific value
    private function getColorForValue(val:Float, minVal:Float, maxVal:Float, minColor:FlxColor, maxColor:FlxColor):Int
    {
        var ratio = (val - minVal) / (maxVal - minVal);
        if (ratio < 0) ratio = 0; if (ratio > 1) ratio = 1;
        return interpolateColor(minColor, maxColor, ratio);
    }

    private function getColorForValueCached(m:MonitorItem, val:Float, minVal:Float, maxVal:Float):Int
    {
        var ratio = (val - minVal) / (maxVal - minVal);
        if (ratio < 0) ratio = 0; if (ratio > 1) ratio = 1;
        var h1 = m.minHue;
        var s1 = m.minSat;
        var l1 = m.minLight;
        var h2 = m.maxHue;
        var s2 = m.maxSat;
        var l2 = m.maxLight;

        if (h2 - h1 > 180) h2 -= 360;
        if (h2 - h1 < -180) h2 += 360;
        if (Math.abs(h1 - h2) > 180) {
            if (h1 < h2) h1 += 360; else h2 += 360;
        }

        var h = h1 + (h2 - h1) * ratio;
        var s = s1 + (s2 - s1) * ratio;
        var l = l1 + (l2 - l1) * ratio;

        if (h < 0) h += 360; if (h >= 360) h -= 360;
        return FlxColor.fromHSL(h, s, l);
    }

    private function drawGraph(m:MonitorItem):Void
    {
        // Adjust graph width based on margins
        var graphW = Std.int(_width - (marginGraphLeft + marginGraphRight));
        var graphH = Std.int(_height - (marginGraphTop + marginGraphBottom));
        
        if (graphW <= 0 || graphH <= 0) return;

        // Resolve min/max first as they are needed for labels
        var minVal:Float = m.minIsFunc ? m.min() : cast m.min;
        var maxVal:Float;

        if (m.max == null)
        {
            // Auto-scale: find max in history
            maxVal = minVal; // Start with min
            for (val in m.dataHistory)
            {
                if (val > maxVal) maxVal = val;
            }
            if (maxVal == minVal) maxVal = minVal + 1; // Avoid divide by zero
            
            // Stabilization
            maxVal = Math.ceil(maxVal / 5) * 5; 
            if (maxVal == 0) maxVal = 5; 
        }
        else
        {
            maxVal = m.maxIsFunc ? m.max() : cast m.max;
        }
        
        // Check if axis changed for labels
        if (Math.abs(minVal - lastMinVal) > 0.001 || Math.abs(maxVal - lastMaxVal) > 0.001)
        {
            lastMinVal = minVal;
            lastMaxVal = maxVal;
            
            // Update Labels
            while (activeLabels.length > 0) recycleLabel(activeLabels.pop());
    
            var steps = [0, 0.2, 0.4, 0.6, 0.8, 1.0];
            for (ratio in steps)
            {
                var lineY = graphH - (ratio * graphH);
                var val = minVal + (maxVal - minVal) * ratio;
                var labelText = "";
                var displayVal = Math.floor(val * 10) / 10;
                
                if (m.suffix == "%") labelText = displayVal + "%";
                else labelText = Std.string(displayVal);
    
                var tf = getLabel();
                if (tf.defaultTextFormat.color != axisLabelColor) {
                    var fmt = tf.defaultTextFormat;
                    fmt.color = axisLabelColor;
                    tf.defaultTextFormat = fmt;
                }
                tf.alpha = axisLabelAlpha;
                tf.text = labelText;
                tf.x = -tf.width - 5;
                tf.y = lineY - tf.height / 2;
                
                labelsContainer.addChild(tf);
                activeLabels.push(tf);
            }
        }
        
        // --- Vector Drawing ---
        graph.graphics.clear();
        
        if (maxHistory < 2) return;
        
        var stepX = graphW / (maxHistory - 1);
        var startIdx = m.historyIndex;
        
        // 1. Draw Fill (One solid color matching latest value, or max value)
        // Using latest value color for fill
        var lastIdx = (m.historyIndex - 1 + maxHistory) % maxHistory;
        var lastVal = m.dataHistory[lastIdx];
        var fillColor = getColorForValueCached(m, lastVal, minVal, maxVal);
        
        graph.graphics.lineStyle(0, 0, 0);
        graph.graphics.beginFill(fillColor, graphFillAlpha);
        
        // Move to Bottom-Left
        graph.graphics.moveTo(0, graphH);
        
        // First Point
        var firstVal = m.dataHistory[startIdx];
        var firstRatio = (firstVal - minVal) / (maxVal - minVal);
        if (firstRatio < 0) firstRatio = 0; if (firstRatio > 1) firstRatio = 1;
        var firstY = graphH - (firstRatio * graphH);
        
        // Line to P0
        graph.graphics.lineTo(0, firstY);
        
        var p0x = 0.0;
        var p0y = firstY;
        
        // Trace Curve for Fill
        for (i in 0...maxHistory - 1)
        {
            var p1idx = (startIdx + i + 1) % maxHistory;
            var p1val = m.dataHistory[p1idx];
            var p1ratio = (p1val - minVal) / (maxVal - minVal);
            if (p1ratio < 0) p1ratio = 0; if (p1ratio > 1) p1ratio = 1;
            
            var p1x = (i + 1) * stepX;
            var p1y = graphH - (p1ratio * graphH);
            
            var midX = (p0x + p1x) / 2;
            var midY = (p0y + p1y) / 2;
            
            graph.graphics.curveTo(p0x, p0y, midX, midY);
            
            p0x = p1x;
            p0y = p1y;
        }
        
        // Line to last point
        graph.graphics.lineTo(p0x, p0y);
        // Line to Bottom-Right
        graph.graphics.lineTo(p0x, graphH);
        // Line to Bottom-Left (Close)
        graph.graphics.lineTo(0, graphH);
        
        graph.graphics.endFill();
        
        // 2. Draw Stroke (Segments with Gradient)
        
        // Reset to first point
        p0x = 0.0;
        p0y = firstY;
        var p0val = firstVal;
        
        // Need to move to start for stroke
        // Since we change lineStyle, we do many segments
        
        for (i in 0...maxHistory - 1)
        {
            var p1idx = (startIdx + i + 1) % maxHistory;
            var p1val = m.dataHistory[p1idx];
            var p1ratio = (p1val - minVal) / (maxVal - minVal);
            if (p1ratio < 0) p1ratio = 0; if (p1ratio > 1) p1ratio = 1;
            
            var p1x = (i + 1) * stepX;
            var p1y = graphH - (p1ratio * graphH);
            
            var midX = (p0x + p1x) / 2;
            var midY = (p0y + p1y) / 2;
            
            // Color for this segment
            var avgVal = (p0val + p1val) * 0.5;
            var segColor = getColorForValueCached(m, avgVal, minVal, maxVal);
            
        graph.graphics.lineStyle(graphLineThickness, segColor, graphLineAlpha);
            
            if (i == 0) {
                 graph.graphics.moveTo(p0x, p0y);
            }
            
            graph.graphics.curveTo(p0x, p0y, midX, midY);
            
            p0x = p1x;
            p0y = p1y;
            p0val = p1val;
        }
        
        var lastSegColor = getColorForValueCached(m, p0val, minVal, maxVal);
        graph.graphics.lineStyle(graphLineThickness, lastSegColor, graphLineAlpha);
        graph.graphics.lineTo(p0x, p0y);
    }

    private function clearGraphImage():Void
    {
        if (graphBitmapData != null)
            graphBitmapData.fillRect(graphBitmapData.rect, 0x00000000);
        graph.graphics.clear();
    }

    private function ensureGraphSurface(graphW:Int, graphH:Int):Void
    {
        if (graphBitmapData == null || graphBitmapData.width != graphW || graphBitmapData.height != graphH)
        {
            graphBitmapData = new BitmapData(graphW, graphH, true, 0x00000000);
            if (graphBitmap == null)
            {
                graphBitmap = new Bitmap(graphBitmapData);
                graphBitmap.x = marginGraphLeft;
                graphBitmap.y = marginGraphTop;
                addChildAt(graphBitmap, getChildIndex(graph));
            }
            else
            {
                graphBitmap.bitmapData = graphBitmapData;
            }
        }
    }

    private function drawGraphIncremental(m:MonitorItem):Void
    {
        var graphW = Std.int(_width - (marginGraphLeft + marginGraphRight));
        var graphH = Std.int(_height - (marginGraphTop + marginGraphBottom));
        if (graphW <= 0 || graphH <= 0) return;

        ensureGraphSurface(graphW, graphH);

        var minVal:Float = m.minIsFunc ? m.min() : cast m.min;
        var lastIdx = (m.historyIndex - 1 + maxHistory) % maxHistory;
        var lastVal = m.dataHistory[lastIdx];
        var maxVal:Float;
        if (m.max == null)
        {
            if (lastMaxVal < -900000.0) maxVal = minVal + 1; else maxVal = lastMaxVal;
            if (lastVal > maxVal)
            {
                maxVal = Math.ceil(lastVal / 5) * 5;
                if (maxVal == 0) maxVal = 5;
            }
        }
        else
        {
            maxVal = m.maxIsFunc ? m.max() : cast m.max;
        }

        if (Math.abs(minVal - lastMinVal) > 0.001 || Math.abs(maxVal - lastMaxVal) > 0.001)
        {
            rebuildGraphBitmap(m);
            return;
        }

        var prevIdx = (lastIdx - 1 + maxHistory) % maxHistory;
        var prevVal = m.dataHistory[prevIdx];

        var ratioPrev = (prevVal - minVal) / (maxVal - minVal);
        if (ratioPrev < 0) ratioPrev = 0; if (ratioPrev > 1) ratioPrev = 1;
        var yPrev = graphH - (ratioPrev * graphH);

        var ratioCurr = (lastVal - minVal) / (maxVal - minVal);
        if (ratioCurr < 0) ratioCurr = 0; if (ratioCurr > 1) ratioCurr = 1;
        var yCurr = graphH - (ratioCurr * graphH);

        var colWidth = getColWidth(graphW);

        graphBitmapData.scroll(-colWidth, 0);
        tmpRect.x = graphW - colWidth;
        tmpRect.y = 0;
        tmpRect.width = colWidth;
        tmpRect.height = graphH;
        graphBitmapData.fillRect(tmpRect, 0x00000000);

        segFillShape.graphics.clear();
        gradientMatrix.createGradientBox(colWidth, graphH, 0, 0, 0);
        var leftColor = getColorForValueCached(m, prevVal, minVal, maxVal);
        var rightColor = getColorForValueCached(m, lastVal, minVal, maxVal);
        gradColors[0] = leftColor;
        gradColors[1] = rightColor;
        gradAlphas[0] = graphFillAlpha;
        gradAlphas[1] = graphFillAlpha;
        segFillShape.graphics.beginGradientFill(GradientType.LINEAR, gradColors, gradAlphas, gradRatios, gradientMatrix);
        strokeShape.graphics.clear();
        var leftColor = getColorForValueCached(m, prevVal, minVal, maxVal);
        var rightColor = getColorForValueCached(m, lastVal, minVal, maxVal);
        strokeShape.graphics.lineStyle(graphLineThickness, 0, graphLineAlpha);
        strokeShape.graphics.lineGradientStyle(GradientType.LINEAR, [leftColor, rightColor], [graphLineAlpha, graphLineAlpha], gradRatios, gradientMatrix);

        if (useSmoothCurve)
        {
            var midX = colWidth * 0.5;
            var midY = (yPrev + yCurr) * 0.5;
            var prevPrevIdx = (lastIdx - 2 + maxHistory) % maxHistory;
            var prevPrevVal = m.dataHistory[prevPrevIdx];
            var ratioPrevPrev = (prevPrevVal - minVal) / (maxVal - minVal);
            if (ratioPrevPrev < 0) ratioPrevPrev = 0; if (ratioPrevPrev > 1) ratioPrevPrev = 1;
            var yPrevPrev = graphH - (ratioPrevPrev * graphH);
            var tangentY = yPrev - yPrevPrev;
            var c0x = colWidth * 0.25;
            var c0y = yPrev + tangentY * 0.25;
            var c1x = colWidth * 0.75;
            var c1y = yCurr - tangentY * 0.25;
            segFillShape.graphics.moveTo(0, graphH);
            segFillShape.graphics.lineTo(0, yPrev);
            segFillShape.graphics.curveTo(c0x, c0y, midX, midY);
            segFillShape.graphics.curveTo(c1x, c1y, colWidth, yCurr);
            segFillShape.graphics.lineTo(colWidth, graphH);
            segFillShape.graphics.lineTo(0, graphH);

            strokeShape.graphics.moveTo(0, yPrev);
            strokeShape.graphics.curveTo(c0x, c0y, midX, midY);
            strokeShape.graphics.curveTo(c1x, c1y, colWidth, yCurr);
        }
        else
        {
            segFillShape.graphics.moveTo(0, graphH);
            segFillShape.graphics.lineTo(0, yPrev);
            segFillShape.graphics.lineTo(colWidth, yCurr);
            segFillShape.graphics.lineTo(colWidth, graphH);
            segFillShape.graphics.lineTo(0, graphH);

            var midX = colWidth * 0.5;
            var midY = (yPrev + yCurr) * 0.5;
            strokeShape.graphics.moveTo(0, yPrev);
            strokeShape.graphics.lineTo(midX, midY);
            strokeShape.graphics.lineTo(colWidth, yCurr);
        }

        segFillShape.graphics.endFill();

        tmpMatrix.identity();
        tmpMatrix.tx = graphW - colWidth;
        graphBitmapData.draw(segFillShape, tmpMatrix, null, null, null, true);
        graphBitmapData.draw(strokeShape, tmpMatrix, null, null, null, true);
    }
    
    private function rebuildGraphBitmap(m:MonitorItem):Void
    {
        var graphW = Std.int(_width - (marginGraphLeft + marginGraphRight));
        var graphH = Std.int(_height - (marginGraphTop + marginGraphBottom));
        if (graphW <= 0 || graphH <= 0) return;

        ensureGraphSurface(graphW, graphH);
        clearGraphImage();

        var minVal:Float = m.minIsFunc ? m.min() : cast m.min;
        var maxVal:Float;
        if (m.max == null)
        {
            maxVal = minVal;
            for (val in m.dataHistory) if (val > maxVal) maxVal = val;
            if (maxVal == minVal) maxVal = minVal + 1;
            maxVal = Math.ceil(maxVal / 5) * 5;
            if (maxVal == 0) maxVal = 5;
        }
        else
        {
            maxVal = m.maxIsFunc ? m.max() : cast m.max;
        }

        lastMinVal = minVal;
        lastMaxVal = maxVal;

        drawAxisLabels(m, graphH, minVal, maxVal);

        var colWidth = getColWidth(graphW);

        for (i in 1...maxHistory)
        {
            var idxPrev = (m.historyIndex + i - 1) % maxHistory;
            var idxCurr = (m.historyIndex + i) % maxHistory;
            var idxPrevPrev = (m.historyIndex + i - 2 + maxHistory) % maxHistory;

            var vPrev = m.dataHistory[idxPrev];
            var vCurr = m.dataHistory[idxCurr];
            var vPrevPrev = m.dataHistory[idxPrevPrev];

            var rPrev = (vPrev - minVal) / (maxVal - minVal);
            if (rPrev < 0) rPrev = 0; if (rPrev > 1) rPrev = 1;
            var yPrev = graphH - (rPrev * graphH);

            var rCurr = (vCurr - minVal) / (maxVal - minVal);
            if (rCurr < 0) rCurr = 0; if (rCurr > 1) rCurr = 1;
            var yCurr = graphH - (rCurr * graphH);

            var yPrevPrev:Float = 0;

            segFillShape.graphics.clear();
            gradientMatrix.createGradientBox(colWidth, graphH, 0, 0, 0);
            var leftColor = getColorForValueCached(m, vPrev, minVal, maxVal);
            var rightColor = getColorForValueCached(m, vCurr, minVal, maxVal);
            gradColors[0] = leftColor;
            gradColors[1] = rightColor;
            gradAlphas[0] = graphFillAlpha;
            gradAlphas[1] = graphFillAlpha;
            segFillShape.graphics.beginGradientFill(GradientType.LINEAR, gradColors, gradAlphas, gradRatios, gradientMatrix);

            strokeShape.graphics.clear();
            var leftColor = getColorForValueCached(m, vPrev, minVal, maxVal);
            var rightColor = getColorForValueCached(m, vCurr, minVal, maxVal);
            strokeShape.graphics.lineStyle(graphLineThickness, 0, graphLineAlpha);
            strokeShape.graphics.lineGradientStyle(GradientType.LINEAR, [leftColor, rightColor], [graphLineAlpha, graphLineAlpha], gradRatios, gradientMatrix);

            if (useSmoothCurve)
            {
                var midX = colWidth * 0.5;
                var midY = (yPrev + yCurr) * 0.5;
                var rPrevPrev = (vPrevPrev - minVal) / (maxVal - minVal);
                if (rPrevPrev < 0) rPrevPrev = 0; if (rPrevPrev > 1) rPrevPrev = 1;
                yPrevPrev = graphH - (rPrevPrev * graphH);
                var tangentY = yPrev - yPrevPrev;
                var c0x = colWidth * 0.25;
                var c0y = yPrev + tangentY * 0.25;
                var c1x = colWidth * 0.75;
                var c1y = yCurr - tangentY * 0.25;
                segFillShape.graphics.moveTo(0, graphH);
                segFillShape.graphics.lineTo(0, yPrev);
                segFillShape.graphics.curveTo(c0x, c0y, midX, midY);
                segFillShape.graphics.curveTo(c1x, c1y, colWidth, yCurr);
                segFillShape.graphics.lineTo(colWidth, graphH);
                segFillShape.graphics.lineTo(0, graphH);

                strokeShape.graphics.moveTo(0, yPrev);
                strokeShape.graphics.curveTo(c0x, c0y, midX, midY);
                strokeShape.graphics.curveTo(c1x, c1y, colWidth, yCurr);
            }
            else
            {
                segFillShape.graphics.moveTo(0, graphH);
                segFillShape.graphics.lineTo(0, yPrev);
                segFillShape.graphics.lineTo(colWidth, yCurr);
                segFillShape.graphics.lineTo(colWidth, graphH);
                segFillShape.graphics.lineTo(0, graphH);

                var midX = colWidth * 0.5;
                var midY = (yPrev + yCurr) * 0.5;
                strokeShape.graphics.moveTo(0, yPrev);
                strokeShape.graphics.lineTo(midX, midY);
                strokeShape.graphics.lineTo(colWidth, yCurr);
            }
            tmpMatrix.identity();
            tmpMatrix.tx = (i - 1) * colWidth;
            graphBitmapData.draw(segFillShape, tmpMatrix, null, null, null, true);
            graphBitmapData.draw(strokeShape, tmpMatrix, null, null, null, true);
        }
    }
    
    private function resolveValue(val:Dynamic):Float {
        if (Reflect.isFunction(val)) return val();
        return cast(val, Float);
    }
    
    private function interpolate(a:Float, b:Float, ratio:Float):Float {
        return a + (b - a) * ratio;
    }
    
    private function interpolateColor(color1:FlxColor, color2:FlxColor, ratio:Float):Int
    {
        var h1 = color1.hue;
        var s1 = color1.saturation;
        var l1 = color1.lightness;
        
        var h2 = color2.hue;
        var s2 = color2.saturation;
        var l2 = color2.lightness;
        
        if (h2 - h1 > 180) h2 -= 360;
        if (h2 - h1 < -180) h2 += 360;
        
        if (Math.abs(h1 - h2) > 180) {
             if (h1 < h2) h1 += 360; else h2 += 360;
        }
        
        var h = h1 + (h2 - h1) * ratio;
        var s = s1 + (s2 - s1) * ratio;
        var l = l1 + (l2 - l1) * ratio;
        
        return FlxColor.fromHSL(h, s, l);
    }
}
