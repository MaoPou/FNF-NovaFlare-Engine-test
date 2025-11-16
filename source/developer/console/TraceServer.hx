package developer.console;

import sys.net.Host;
import sys.net.Socket;

class TraceServer {
    private static var server:Socket;
    private static var clients:Array<Socket> = [];
    private static var isRunning:Bool = false;
    
    public static function start(port:Int = 1145):Void {
        if (isRunning) return;
        
        try {
            server = new Socket();
            server.bind(new Host("0.0.0.0"), port);
            server.listen(5);
            isRunning = true;
            
            trace('Trace服务器启动在端口: $port');
            
            sys.thread.Thread.create(() ->
            {
                acceptConnections();
            });
            
        } catch (e:Dynamic) {
            trace('启动服务器失败: $e');
        }
    }
    
    public static function stop():Void {
        isRunning = false;
        if (server != null) {
            try {
                server.close();
            } catch (e:Dynamic) {}
            server = null;
        }
        
        for (client in clients) {
            try {
                client.close();
            } catch (e:Dynamic) {}
        }
        clients = [];
    }
    
    private static function acceptConnections():Void {
        while (isRunning) {
            try {
                var client = server.accept();
                clients.push(client);
                trace('新的客户端连接');
                
                sys.thread.Thread.create(() ->
		        {
		            handleClient(client);
                });
                
            } catch (e:Dynamic) {
                if (isRunning) {
                    trace('接受连接时出错: $e');
                }
            }
        }
    }
    
    private static function handleClient(client:Socket):Void {
        try {
            sendFormattedMessage(client, "INFO", "连接到Trace服务器成功", 0x4CAF50);
            
        } catch (e:Dynamic) {
            trace('处理客户端时出错: $e');
            try {
                client.close();
                clients.remove(client);
            } catch (e:Dynamic) {}
        }
    }
    
    public static function sendTraceMessage(level:String, message:String, color:Int):Void {
        if (!isRunning || clients.length == 0) return;
        
        var deadClients:Array<Socket> = [];
        
        for (client in clients) {
            try {
                sendFormattedMessage(client, level, message, color);
            } catch (e:Dynamic) {
                deadClients.push(client);
            }
        }
        
        for (deadClient in deadClients) {
            clients.remove(deadClient);
            try {
                deadClient.close();
            } catch (e:Dynamic) {}
        }
    }
    
    private static function sendFormattedMessage(client:Socket, level:String, message:String, color:Int):Void {
        var formatted = '$level|${StringTools.hex(color, 6)}|$message\n';
        client.write(formatted);
        client.output.flush();
    }
}