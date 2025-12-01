package scripts.hscript;

import flixel.FlxBasic;
import objects.Character;
import scripts.lua.LuaUtils;
import scripts.lua.CustomSubstate;
#if LUA_ALLOWED
import scripts.lua.FunkinLua;
#end
#if HSCRIPT_ALLOWED
import crowplexus.hscript.Interp;
import crowplexus.hscript.Expr;
import crowplexus.hscript.Parser;
import scripts.hscript.HScriptTypeUtils;
import haxe.Exception;
import haxe.ValueException;

class HScriptBase
{
    public static var parser:Parser = new Parser();

    public var interp:Interp;
    var codeExprCache:Map<String, Expr> = new Map<String, Expr>();

	public var variables(get, never):Map<String, Dynamic>;
	public var parentLua:FunkinLua;

	public function get_variables()
	{
		return interp.variables;
	}

	public static function initHaxeModule(parent:FunkinLua)
	{
		#if HSCRIPT_ALLOWED
		if (parent.hscriptBase == null)
		{
			// trace('initializing haxe interp for: $scriptName');
			parent.hscriptBase = new HScriptBase(parent); // TO DO: Fix issue with 2 scripts not being able to use the same variable names
		}
		#end
	}

	public function new(parent:FunkinLua)
	{
		interp = new Interp();
		parentLua = parent;
		interp.variables.set('FlxG', flixel.FlxG);
		interp.variables.set('FlxSprite', flixel.FlxSprite);
		interp.variables.set('FlxCamera', flixel.FlxCamera);
		interp.variables.set('FlxTimer', flixel.util.FlxTimer);
		interp.variables.set('FlxTween', flixel.tweens.FlxTween);
		interp.variables.set('FlxEase', flixel.tweens.FlxEase);
		interp.variables.set('PlayState', PlayState);
		interp.variables.set('game', PlayState.instance);
		interp.variables.set('Paths', Paths);
		interp.variables.set('Conductor', Conductor);
		interp.variables.set('ClientPrefs', ClientPrefs);
		interp.variables.set('Character', Character);
		interp.variables.set('Alphabet', Alphabet);
		interp.variables.set('CustomSubstate', scripts.lua.CustomSubstate);
		#if (!flash && sys)
		interp.variables.set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		interp.variables.set('ShaderFilter', openfl.filters.ShaderFilter);
		interp.variables.set('StringTools', StringTools);

		interp.variables.set('setVar', function(name:String, value:Dynamic)
		{
			PlayState.instance.variables.set(name, value);
		});
		interp.variables.set('getVar', function(name:String)
		{
			var result:Dynamic = null;
			if (PlayState.instance.variables.exists(name))
				result = PlayState.instance.variables.get(name);
			return result;
		});
		interp.variables.set('removeVar', function(name:String)
		{
			if (PlayState.instance.variables.exists(name))
			{
				PlayState.instance.variables.remove(name);
				return true;
			}
			return false;
		});
		interp.variables.set('debugPrint', function(text:String, ?color:FlxColor = null)
		{
			if (color == null)
				color = FlxColor.WHITE;
			FunkinLua.luaTrace(text, true, false, color);
		});

		// For adding your own callbacks

		// not very tested but should work
		interp.variables.set('createGlobalCallback', function(name:String, func:Dynamic)
		{
			#if LUA_ALLOWED
			for (script in PlayState.instance.luaArray)
				if (script != null && script.lua != null && !script.closed)
					Lua_helper.add_callback(script.lua, name, func);
			#end
			FunkinLua.customFunctions.set(name, func);
		});

		// tested
		interp.variables.set('createCallback', function(name:String, func:Dynamic, ?funk:FunkinLua = null)
		{
			if (funk == null)
				funk = parentLua;
			funk.addLocalCallback(name, func);
		});

		interp.variables.set('addHaxeLibrary', function(libName:String, ?libPackage:String = '')
		{
			try
			{
				var str:String = '';
				if (libPackage.length > 0)
					str = libPackage + '.';

				interp.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic)
			{
				FunkinLua.lastCalledScript = parent;
				FunkinLua.luaTrace(parentLua.scriptName + ":" + parentLua.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
		});
		interp.variables.set('parentLua', parentLua);
	}

    public function execute(codeToRun:String, ?funcToRun:String = null, ?funcArgs:Array<Dynamic>):Dynamic
    {
        @:privateAccess
        HScriptBase.parser.line = 1;
        HScriptBase.parser.allowTypes = true;
        HScriptBase.parser.allowMetadata = true;
        HScriptBase.parser.allowInterpolation = true;
        HScriptBase.parser.allowJSON = true;
        var expr:Expr = null;
        if (codeExprCache.exists(codeToRun)) {
            expr = codeExprCache.get(codeToRun);
        } else {
            expr = HScriptBase.parser.parseString(codeToRun);
            if (HScriptTypeUtils.enabled) {
                HScriptTypeUtils.detectTypes(expr, HScriptTypeUtils.collectImports(expr));
            }
            codeExprCache.set(codeToRun, expr);
        }
        try
        {
            var value:Dynamic = interp.execute(expr);
            return (funcToRun != null) ? executeFunction(funcToRun, funcArgs) : value;
        }
        catch (e:Exception)
        {
            trace(e);
            return null;
        }
    }

    public static function setTypeDetectEnabled(v:Bool):Void {
        HScriptTypeUtils.setEnabled(v);
    }

    @:finalize function finalize():Void {
        codeExprCache = null;
    }

	public function executeFunction(funcToRun:String = null, funcArgs:Array<Dynamic>)
	{
		if (funcToRun != null)
		{
			// trace('Executing $funcToRun');
			if (interp.variables.exists(funcToRun))
			{
				// trace('$funcToRun exists, executing...');
				if (funcArgs == null)
					funcArgs = [];
				return Reflect.callMethod(null, interp.variables.get(funcToRun), funcArgs);
			}
		}
		return null;
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		var lua:State = funk.lua;
		Lua_helper.add_callback(lua, "runHaxeCode",
			function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null)
			{
				var retVal:Dynamic = null;

				#if HSCRIPT_ALLOWED
				HScriptBase.initHaxeModule(funk);
				try
				{
					if (varsToBring != null)
					{
						for (key in Reflect.fields(varsToBring))
						{
							// trace('Key $key: ' + Reflect.field(varsToBring, key));
							funk.hscriptBase.interp.variables.set(key, Reflect.field(varsToBring, key));
						}
					}
					retVal = funk.hscriptBase.execute(codeToRun, funcToRun, funcArgs);
				}
				catch (e:Dynamic)
				{
					FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
				}
				#else
				FunkinLua.luaTrace("runHaxeCode: HScript isn't supported on this platform!", false, false, FlxColor.RED);
				#end

				if (retVal != null && !LuaUtils.isOfTypes(retVal, [Bool, Int, Float, String, Array]))
					retVal = null;
				return retVal;
			});

		Lua_helper.add_callback(lua, "runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null)
		{
			try
			{
				return funk.hscriptBase.executeFunction(funcToRun, funcArgs);
			}
			catch (e:Exception)
			{
				FunkinLua.luaTrace(Std.string(e));
				return null;
			}
		});

		Lua_helper.add_callback(lua, "addHaxeLibrary", function(libName:String, ?libPackage:String = '')
		{
			#if HSCRIPT_ALLOWED
			HScriptBase.initHaxeModule(funk);
			try
			{
				var str:String = '';
				if (libPackage.length > 0)
					str = libPackage + '.';

				funk.hscriptBase.variables.set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic)
			{
				FunkinLua.luaTrace(funk.scriptName + ":" + funk.lastCalledFunction + " - " + e, false, false, FlxColor.RED);
			}
			#end
		});
	}
	#end
}
#else
class HScriptBase
{
	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua)
	{
		funk.addLocalCallback("runHaxeCode",
			function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic
			{
				PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
				return null;
			});
		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null)
		{
			PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
			return null;
		});
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '')
		{
			PlayState.instance.addTextToDebug('HScript is not supported on this platform!', FlxColor.RED);
			return null;
		});
	}
	#end
}
#end
