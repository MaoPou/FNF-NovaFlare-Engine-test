package developer.console;

import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;

class ConsoleToggleButton extends Sprite {
    public static var instance(get, null):ConsoleToggleButton;
    
    private static function get_instance():ConsoleToggleButton {
        if (_instance == null) {
            _instance = new ConsoleToggleButton();
        }
        return _instance;
    }
    private static var _instance:ConsoleToggleButton = null;
    
    public function new() {
        super();
        createButton();
    }
    
    private function createButton():Void {
        graphics.beginFill(0x4CAF50, 0.8);
        graphics.drawRoundRect(0, 0, 80, 30, 5);
        graphics.endFill();
        
        var label = new TextField();
        label.text = "显示控制台";
        label.setTextFormat(new TextFormat(Paths.font('Lang-ZH.ttf'), 12, 0xFFFFFF));
        label.x = 5;
        label.y = 5;
        label.width = 70;
        label.selectable = false;
        addChild(label);
        
        x = openfl.Lib.current.stage.stageWidth - 90;
        y = 20;
        
        addEventListener(MouseEvent.CLICK, function(e) {
            Console.show();
            hide();
        });
    }
    
    public static function show():Void {
        instance.visible = true;
    }
    
    public static function hide():Void {
        instance.visible = false;
    }
}