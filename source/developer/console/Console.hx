package developer.console;

import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
import openfl.geom.Rectangle;
import openfl.text.TextFieldAutoSize;

class Console extends Sprite {
    public static var consoleInstance(get, null):Console;
    private var textContainer:Sprite;
    private var output:TextField;
    private var buffer:Array<String> = [];
    private var isDragging:Bool = false;
    private var dragOffsetX:Float = 0;
    private var dragOffsetY:Float = 0;
    private var isScrolling:Bool = false;
    private var scrollStartY:Float = 0;
    private var scrollStartV:Float = 0;
    private var captureEnabled:Bool = true;
    private var autoScroll:Bool = true;
    
    private var currentWidth:Float;
    private var currentHeight:Float;
    
    // 按钮引用
    private var captureButton:Sprite;
    private var autoScrollButton:Sprite;
    private var clearButton:Sprite;
    private var closeButton:Sprite;
    private var maximizeButton:Sprite;
    private var minimizeButton:Sprite; 
    
    private var pendingLogs:Array<String> = [];
    private var pendingColoredLogs:Array<{head:String, message:String, color:Int}> = [];
    private var renderTimer:haxe.Timer = null;
    private var maxBatchSize:Int = 100; // 每批处理的最大日志数
    private var maxLogLines:Int = 1000; // 最大日志行数
    private var renderDelay:Int = 100; // 渲染延迟(毫秒)
    
    private static var _consoleInstance:Console = null;
    
    // 参考线
    private var dragReference:Sprite;
    private var lastWidth:Float = 0;
    private var lastHeight:Float = 0;
    
    //窗口大小
    private var minWidth:Float = 400;
    private var minHeight:Float = 300;
    private var resizeHandle:Sprite;
    private var isResizing:Bool = false;
    private var startResizeX:Float = 0;
    private var startResizeY:Float = 0;
    private var startWidth:Float = 0;
    private var startHeight:Float = 0;
    
    private var isMaximized:Bool = false;
    private var normalSize:Rectangle = new Rectangle();
    
    private static function get_consoleInstance():Console {
        if (_consoleInstance == null) {
            _consoleInstance = new Console();
        }
        return _consoleInstance;
    }
    
    public function new() {
        super();
        scaleX = scaleY = ClientPrefs.data.DevConScale;
        createConsoleUI();
    }
    
    private function createConsoleUI():Void {
        var initialWidth = openfl.Lib.current.stage.stageWidth * 0.4;
        var initialHeight = openfl.Lib.current.stage.stageHeight * 0.3;
        
        currentWidth = initialWidth;
        currentHeight = initialHeight;

        normalSize = new Rectangle(0, 0, initialWidth, initialHeight);
        
        dragReference = new Sprite();
        dragReference.visible = false;
        addChild(dragReference);
        
        graphics.beginFill(0x333333, 0.8);
        graphics.drawRoundRect(0, 0, initialWidth, initialHeight, 10);
        graphics.endFill();
        
        textContainer = new Sprite();
        textContainer.x = 15;
        textContainer.y = 50;
        textContainer.scrollRect = new Rectangle(0, 0, initialWidth - 30, initialHeight - 100);
        addChild(textContainer);
        
        output = new TextField();
        output.defaultTextFormat = new TextFormat(Paths.font('Lang-ZH.ttf'), 14, 0xFFFFFF);
        output.width = initialWidth - 30;
        output.autoSize = TextFieldAutoSize.LEFT;
        output.multiline = true;
        output.wordWrap = true;
        output.selectable = false;
        output.htmlText = "";
        output.addEventListener(MouseEvent.MOUSE_DOWN, startTextScroll);
        textContainer.addChild(output);
        
        createTitleBar();
        createControlButtons();
        createWindowButtons();
        createResizeHandle();
    }
    
    var titleBar:Sprite;
    
    private function createTitleBar():Void {
        titleBar = new Sprite();
        titleBar.graphics.beginFill(0x444444);
        titleBar.graphics.drawRoundRect(0, 0, currentWidth, 30, 10, 10);
        titleBar.graphics.endFill();
        addChild(titleBar);
        
        var title = new TextField();
        title.text = "Trace Console (拖拽移动)";
        title.setTextFormat(new TextFormat(Paths.font('Lang-ZH.ttf'), 12, 0xFFFFFF));
        title.x = 10;
        title.y = 5;
        title.width = 300;
        title.selectable = false;
        titleBar.addChild(title);
    
        titleBar.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) {
            isDragging = true;
            dragOffsetX = e.stageX - x;
            dragOffsetY = e.stageY - y;
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onTitleDragMove);
            stage.addEventListener(MouseEvent.MOUSE_UP, onTitleDragEnd);
            
            e.stopPropagation();
        });
    }
    
    private function createWindowButtons():Void {
        closeButton = createWindowButton("×", 0xFF5555, currentWidth - 30, 5);
        closeButton.addEventListener(MouseEvent.CLICK, function(e) {
            closeConsole();
        });
        
        maximizeButton = createWindowButton("□", 0x55AA55, currentWidth - 60, 5);
        maximizeButton.addEventListener(MouseEvent.CLICK, function(e) {
            toggleMaximize();
        });
        
        minimizeButton = createWindowButton("-", 0xAAAAAA, currentWidth - 90, 5);
        minimizeButton.addEventListener(MouseEvent.CLICK, function(e) {
            closeConsole();
        });
    }
    
    private function createWindowButton(label:String, color:Int, xPos:Float, yPos:Float):Sprite {
        var button = new Sprite();
        button.graphics.beginFill(color, 0.7);
        button.graphics.drawRoundRect(0, 0, 25, 20, 3);
        button.graphics.endFill();
        
        var text = new TextField();
        text.text = label;
        text.setTextFormat(new TextFormat(Paths.font('Lang-ZH.ttf'), 14, 0xFFFFFF));
        text.x = 5;
        text.y = 0;
        text.width = 20;
        text.selectable = false;
        button.addChild(text);
        
        button.x = xPos;
        button.y = yPos;
        addChild(button);
        
        button.addEventListener(MouseEvent.MOUSE_OVER, function(e) {
            button.graphics.clear();
            button.graphics.beginFill(color, 1.0);
            button.graphics.drawRoundRect(0, 0, 25, 20, 3);
            button.graphics.endFill();
            button.addChild(text);
            Mouse.cursor = MouseCursor.BUTTON;
        });
        
        button.addEventListener(MouseEvent.MOUSE_OUT, function(e) {
            button.graphics.clear();
            button.graphics.beginFill(color, 0.7);
            button.graphics.drawRoundRect(0, 0, 25, 20, 3);
            button.graphics.endFill();
            button.addChild(text);
            Mouse.cursor = MouseCursor.AUTO;
        });
        
        return button;
    }
    
    private function onTitleDragMove(e:MouseEvent):Void {
        if (isDragging) {
            var unscaledX = e.stageX / scaleX;
            var unscaledY = e.stageY / scaleY;
            
            var newX = unscaledX - dragOffsetX;
            var newY = unscaledY - dragOffsetY;
            
            var maxX = (openfl.Lib.current.stage.stageWidth / scaleX) - currentWidth;
            var maxY = (openfl.Lib.current.stage.stageHeight / scaleY) - currentHeight;
            
            x = Math.max(0, Math.min(maxX, newX));
            y = Math.max(0, Math.min(maxY, newY));
        }
    }
    
    private function onTitleDragEnd(e:MouseEvent):Void {
        if (isDragging) {
            isDragging = false;
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onTitleDragMove);
            stage.removeEventListener(MouseEvent.MOUSE_UP, onTitleDragEnd);
            e.stopPropagation();
        }
    }
    
    private function createControlButtons():Void {
        var buttonY = currentHeight - 20;
        
        captureButton = createButton("捕捉:开", 0xFF5555, 20, buttonY);
        captureButton.addEventListener(MouseEvent.CLICK, function(e) {
            toggleCapture();
        });
        
        autoScrollButton = createButton("自动滚动:开", 0x55AA55, 110, buttonY);
        autoScrollButton.addEventListener(MouseEvent.CLICK, function(e) {
            toggleAutoScroll();
        });
        
        clearButton = createButton("清空日志", 0x5555FF, 220, buttonY);
        clearButton.addEventListener(MouseEvent.CLICK, function(e) {
            clearLogs();
        });
    }
    
    private function createButton(label:String, color:Int, xPos:Float, yPos:Float):Sprite {
        var button = new Sprite();
        button.graphics.beginFill(color);
        button.graphics.drawRoundRect(0, 0, 80, 20, 5);
        button.graphics.endFill();
        
        var text = new TextField();
        text.text = label;
        text.setTextFormat(new TextFormat(Paths.font('Lang-ZH.ttf'), 10, 0xFFFFFF));
        text.x = 5;
        text.y = 3;
        text.width = 70;
        text.selectable = false;
        button.addChild(text);
        
        button.x = xPos;
        button.y = yPos;
        addChild(button);
        
        button.addEventListener(MouseEvent.MOUSE_OVER, function(e) {
            Mouse.cursor = MouseCursor.BUTTON;
        });
        
        button.addEventListener(MouseEvent.MOUSE_OUT, function(e) {
            Mouse.cursor = MouseCursor.AUTO;
        });
        
        return button;
    }
    
    private function startTextScroll(e:MouseEvent):Void {
        isScrolling = true;
        scrollStartY = e.stageY;
        scrollStartV = output.y;
        stage.addEventListener(MouseEvent.MOUSE_MOVE, doTextScroll);
        stage.addEventListener(MouseEvent.MOUSE_UP, stopTextScroll);
    }
    
    private function doTextScroll(e:MouseEvent):Void {
        if (isScrolling) {
            var deltaY:Float = e.stageY - scrollStartY;
            var newY:Float = scrollStartV + deltaY;
            
            var visibleHeight = textContainer.scrollRect.height;
            var contentHeight = output.height;
            
            if (contentHeight <= visibleHeight) {
                newY = 0;
            } else {
                var minY = visibleHeight - contentHeight;
                if (newY < minY) newY = minY;
                if (newY > 0) newY = 0;
            }
            
            output.y = newY;
            
            if (autoScroll) {
                toggleAutoScroll(false);
            }
            updateAutoScrollButton();
        }
    }
    
    private function stopTextScroll(e:MouseEvent):Void {
        isScrolling = false;
        stage.removeEventListener(MouseEvent.MOUSE_MOVE, doTextScroll);
        stage.removeEventListener(MouseEvent.MOUSE_UP, stopTextScroll);
    }
    
    private function startDragConsole(e:MouseEvent):Void {
        isDragging = true;
        dragOffsetX = e.stageX - x;
        dragOffsetY = e.stageY - y;
        stage.addEventListener(MouseEvent.MOUSE_MOVE, dragConsole);
    }
    
    private function stopDragConsole(e:MouseEvent):Void {
        isDragging = false;
        if (stage != null) {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragConsole);
        }
    }
    
    private function dragConsole(e:MouseEvent):Void {
        if (isDragging) {
            x = e.stageX - dragOffsetX;
            y = e.stageY - dragOffsetY;
        }
    }
    
    private function scrollToBottom():Void {
        var visibleHeight = textContainer.scrollRect.height;
        var contentHeight = output.height;
        if (contentHeight > visibleHeight) {
            output.y = visibleHeight - contentHeight;
        } else {
            output.y = 0;
        }
    }
    
    private function toggleCapture():Void {
        captureEnabled = !captureEnabled;
        updateCaptureButton();
    }
    
    private function toggleAutoScroll(?value:Bool):Void {
        autoScroll = value != null ? value : !autoScroll;
        if (autoScroll) scrollToBottom();
        updateAutoScrollButton();
    }
    
    private function clearLogs():Void {
        output.htmlText = "";
        output.y = 0;
        buffer = [];
    }
    
    private function closeConsole():Void {
        visible = false;
        ConsoleToggleButton.show();
    }
    
    private function updateCaptureButton():Void {
        var textField:TextField = cast(captureButton.getChildAt(0), TextField);
        textField.setTextFormat(new TextFormat(Paths.font('Lang-ZH.ttf'), 10, 0xFFFFFF));
        textField.text = captureEnabled ? "捕捉:开" : "捕捉:关";
    }
    
    private function updateAutoScrollButton():Void {
        var textField:TextField = cast(autoScrollButton.getChildAt(0), TextField);
        textField.setTextFormat(new TextFormat(Paths.font('Lang-ZH.ttf'), 10, 0xFFFFFF));
        textField.text = autoScroll ? "自动滚动:开" : "自动滚动:关";
    }
    
    public static function log(message:String):Void {
        if (consoleInstance != null) {
            consoleInstance.addLog(message);
        }
    }
    
    private function addLog(message:String):Void {
        if (!captureEnabled) return;
        
        pendingLogs.push(StringTools.htmlEscape(message));
        scheduleRender();
    }
    
    public static function show():Void {
        if (consoleInstance.parent == null) {
            openfl.Lib.current.stage.addChild(consoleInstance);
        }
        consoleInstance.visible = true;
        consoleInstance.scaleX = consoleInstance.scaleY = ClientPrefs.data.uiScale;
        ConsoleToggleButton.hide();
    }
    
    public static function hide():Void {
        if (consoleInstance != null) {
            consoleInstance.visible = false;
        }
    }
    
    public static function isVisible():Bool {
        return consoleInstance != null && consoleInstance.visible;
    }
    
    public static function toggle():Void {
        if (isVisible()) {
            hide();
        } else {
            show();
        }
    }
    
    public static function logWithColoredHead(head:String, message:String, color:Int):Void {
        if (consoleInstance != null) {
            consoleInstance.addLogWithColoredHead(head, message, color);
        }
    }
    
    private function addLogWithColoredHead(head:String, message:String, color:Int):Void {
        if (!captureEnabled) return;
        
        pendingColoredLogs.push({
            head: head,
            message: message,
            color: color
        });
        scheduleRender();
    }
    
    private function scheduleRender():Void {
        if (renderTimer == null) {
            renderTimer = haxe.Timer.delay(processPendingLogs, renderDelay);
        }
    }
    
    private function processPendingLogs():Void {
        renderTimer = null;
        
        var hasNewContent = false;
        var batchCount = 0;
        
        // 处理普通日志
        while (pendingLogs.length > 0 && batchCount < maxBatchSize) {
            var message = pendingLogs.shift();
            buffer.push(message);
            hasNewContent = true;
            batchCount++;
        }
        
        // 处理带颜色的日志
        while (pendingColoredLogs.length > 0 && batchCount < maxBatchSize) {
            var log = pendingColoredLogs.shift();
            var htmlLine = '<font color="#${StringTools.hex(log.color, 6)}">${StringTools.htmlEscape(log.head)}</font>${StringTools.htmlEscape(log.message)}';
            buffer.push(htmlLine);
            hasNewContent = true;
            batchCount++;
        }
        
        if (hasNewContent) {
            // 限制日志行数
            while (buffer.length > maxLogLines) {
                buffer.shift();
            }
            
            output.htmlText = buffer.join("<br/>");
            
            if (autoScroll) {
                scrollToBottom();
            }
        }
        
        // 如果还有待处理日志，继续调度下一批
        if (pendingLogs.length > 0 || pendingColoredLogs.length > 0) {
            scheduleRender();
        }
    }
    
    private function createResizeHandle():Void {
        resizeHandle = new Sprite();
        resizeHandle.graphics.beginFill(0x666666, 0);
        resizeHandle.graphics.drawRect(0, 0, 40, 40);
        resizeHandle.graphics.endFill();
        
        resizeHandle.x = currentWidth - 40;
        resizeHandle.y = currentHeight - 40;
        addChild(resizeHandle);
        
        resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, startResize);
        resizeHandle.addEventListener(MouseEvent.MOUSE_OVER, function(e) {
            Mouse.cursor = MouseCursor.HAND;
        });
        resizeHandle.addEventListener(MouseEvent.MOUSE_OUT, function(e) {
            if (!isResizing) Mouse.cursor = MouseCursor.AUTO;
        });
    }
    
    private function startResize(e:MouseEvent):Void {
        isResizing = true;
        startResizeX = e.stageX;
        startResizeY = e.stageY;
        startWidth = currentWidth;
        startHeight = currentHeight;
        
        // 显示参考线
        drawDragReference(startWidth, startHeight);
        dragReference.visible = true;
        
        stage.addEventListener(MouseEvent.MOUSE_MOVE, onResize);
        stage.addEventListener(MouseEvent.MOUSE_UP, stopResize);
        
        e.stopPropagation();
    }
    
    private function onResize(e:MouseEvent):Void {
        if (isResizing) {
            var deltaX = (e.stageX - startResizeX) / scaleX;
            var deltaY = (e.stageY - startResizeY) / scaleY;
            
            var newWidth = Math.max(minWidth, startWidth + deltaX);
            var newHeight = Math.max(minHeight, startHeight + deltaY);
            
            var maxWidth = (openfl.Lib.current.stage.stageWidth / scaleX) - x;
            var maxHeight = (openfl.Lib.current.stage.stageHeight / scaleY) - y;
            
            currentWidth = Math.min(newWidth, maxWidth);
            currentHeight = Math.min(newHeight, maxHeight);
            
            drawDragReference(currentWidth, currentHeight);
        }
    }
    
    private function stopResize(e:MouseEvent):Void {
        if (isResizing) {
            isResizing = false;
            dragReference.visible = false;
    
            redrawConsole(currentWidth, currentHeight);
    
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onResize);
            stage.removeEventListener(MouseEvent.MOUSE_UP, stopResize);
            Mouse.cursor = MouseCursor.AUTO;
            e.stopPropagation();
        }
    }
    
    private function resizeConsole(newWidth:Float, newHeight:Float):Void {
        currentWidth = newWidth;
        currentHeight = newHeight;
        
        graphics.clear();
        graphics.beginFill(0x333333, 0.8);
        graphics.drawRoundRect(0, 0, newWidth, newHeight, 10);
        graphics.endFill();
        
        output.width = newWidth - 30;
        textContainer.scrollRect = new Rectangle(0, 0, newWidth - 30, newHeight - 100);
        
        resizeHandle.x = newWidth - 40;
        resizeHandle.y = newHeight - 40;
        
        updateTitleBar(newWidth);
        updateWindowButtons(newWidth);
        updateControlButtons(newHeight);

        if (autoScroll) scrollToBottom();
    }
    
    private function toggleMaximize():Void {
        if (isMaximized) {
            resizeConsole(normalSize.width, normalSize.height);
            x = normalSize.x;
            y = normalSize.y;
            isMaximized = false;
        } else {
            normalSize.setTo(x * scaleX, y * scaleY, 
                           currentWidth * scaleX, 
                           currentHeight * scaleY);
            
            var stage = openfl.Lib.current.stage;
            resizeConsole(stage.stageWidth / scaleX, 
                         stage.stageHeight / scaleY);
            x = y = 0;
            isMaximized = true;
        }
    }
    
    private function updateWindowButtonsPosition():Void {
        if (closeButton != null) {
            closeButton.x = currentWidth - 30;
            maximizeButton.x = currentWidth - 60;
            minimizeButton.x = currentWidth - 90;
        }
    }

    private function updateControlButtonsPosition():Void {
        var buttonY = currentHeight - 20;
        
        if (captureButton != null) {
            captureButton.x = 20;
            captureButton.y = buttonY;
        }
        
        if (autoScrollButton != null) {
            autoScrollButton.x = 110;
            autoScrollButton.y = buttonY;
        }
        
        if (clearButton != null) {
            clearButton.x = 220;
            clearButton.y = buttonY;
        }
    }
    
    private function updateTitleBar(newWidth:Float):Void {
        titleBar.graphics.clear();
        titleBar.graphics.beginFill(0x444444);
        titleBar.graphics.drawRoundRect(0, 0, newWidth, 30, 10, 10);
        titleBar.graphics.endFill();
    }
    
    private function updateControlButtons(newHeight:Float):Void {
        var buttonY = newHeight - 20;
        
        if (captureButton != null) {
            captureButton.y = buttonY;
        }
        
        if (autoScrollButton != null) {
            autoScrollButton.y = buttonY;
        }
        
        if (clearButton != null) {
            clearButton.y = buttonY;
        }
    }
    
    private function updateWindowButtons(newWidth:Float):Void {
        if (closeButton != null) {
            closeButton.x = newWidth - 30;
        }
        if (maximizeButton != null) {
            maximizeButton.x = newWidth - 60;
        }
        if (minimizeButton != null) {
            minimizeButton.x = newWidth - 90;
        }
    }
    
    private function drawDragReference(w:Float, h:Float):Void {
        dragReference.graphics.clear();
        
        dragReference.graphics.lineStyle(1, 0xFFFFFF, 0.7);
        
        // 上边线
        dragReference.graphics.moveTo(0, 0);
        dragReference.graphics.lineTo(w, 0);
        
        // 右边线
        dragReference.graphics.moveTo(w, 0);
        dragReference.graphics.lineTo(w, h);
        
        // 下边线
        dragReference.graphics.moveTo(w, h);
        dragReference.graphics.lineTo(0, h);
        
        // 左边线
        dragReference.graphics.moveTo(0, h);
        dragReference.graphics.lineTo(0, 0);
    }
    
    private function redrawConsole(newWidth:Float, newHeight:Float):Void {
        graphics.clear();
        graphics.beginFill(0x333333, 0.8);
        graphics.drawRoundRect(0, 0, newWidth, newHeight, 10);
        graphics.endFill();
        
        updateAllElements(newWidth, newHeight);
        
        lastWidth = newWidth;
        lastHeight = newHeight;
    }
    
    private function updateAllElements(newWidth:Float, newHeight:Float):Void {
        output.width = newWidth - 30;
        textContainer.scrollRect = new Rectangle(0, 0, newWidth - 30, newHeight - 100);
        
        updateTitleBar(newWidth);
        
        updateControlButtons(newHeight);
        
        updateWindowButtons(newWidth);
        
        resizeHandle.x = newWidth - 40;
        resizeHandle.y = newHeight - 40;
    }
    
    public function updateScale(newScale:Float):Void {
        var actualX = x * scaleX;
        var actualY = y * scaleY;
        var actualWidth = currentWidth * scaleX;
        var actualHeight = currentHeight * scaleY;
        
        scaleX = scaleY = newScale;
        
        x = actualX / newScale;
        y = actualY / newScale;
        currentWidth = actualWidth / newScale;
        currentHeight = actualHeight / newScale;
        
        redrawConsole(currentWidth, currentHeight);
        
        if (isMaximized) {
            var stage = openfl.Lib.current.stage;
            resizeConsole(stage.stageWidth / newScale, 
                         stage.stageHeight / newScale);
            x = y = 0;
        }
    }
}