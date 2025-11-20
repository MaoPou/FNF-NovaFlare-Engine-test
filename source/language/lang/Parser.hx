package language.lang;

import haxe.ds.List;
import haxe.ds.Vector;
import sys.io.FileInput;

/**
 * 解析lang文件并把结果输入到`LangState`中
 */
@:allow(language.lang.Lexer)
@:access(language.lang.LangState)
class Parser
{
	#if sys
	/**
	 * 解析指定路径的文件
	 * @param ls				 我不知道
	 * @param path			 解析路径
	 * @return					 返回检验是否报错的布尔值，如果报错请使用`ls.errorMessage()`获取报错信息
	 */
	public static function parseFile(ls:LangState, path:String):Bool
	{
		ls.dic = new Map();
		ls.thrown = null;
		try
		{
			try
			{
				var input:FileInput = sys.io.File.read(path, false);
				var bs:haxe.io.Bytes = input.readAll();
				input.close();
				var lexes:List<Lex> = new Lexer(bs).doLex();
				_doParse(ls, lexes);
			} catch(e:LangException)
				throw e
			catch(e)
			{
				error(Std.string(e), ls.forceLex);
			}
		} catch(e:LangException)
		{
			ls.thrown = '"$path": ' + e.toString();
			ls.dic = null;
			return false;
		}

		return true;
	}
	#end

	/**
	 * 解析字符串
	 * @param ls				 我不知道
	 * @param text			 解析字符串
	 * @return						 返回检验是否报错的布尔值，如果报错请使用`ls.errorMessage()`获取报错信息
	 */
	public static function parse(ls:LangState, text:String):Bool
	{
		ls.dic = new Map();
		ls.thrown = null;

		try
		{
			try
			{
				var lexes:List<Lex> = new Lexer(text).doLex();
				_doParse(ls, lexes);
			} catch(e:LangException)
				throw e
			catch(e)
				error(Std.string(e), ls.forceLex);
		} catch(e:LangException)
		{
			ls.thrown = e.toString();
			ls.dic = null;
			return false;
		}

		return true;
	}

	private static function _doParse(ls:LangState, lexes:List<Lex>)
	{
		while(!lexes.isEmpty())
		{
			var lex = nextLex(ls, lexes);
			_parseExpr(ls, lex, lexes);
		}
	}

	private static function _parseExpr(ls:LangState, lex:Lex, lexes:List<Lex>)
	{
		switch(lex.def)
		{
			case LIdentifier(id):
				var next = nextLex(ls, lexes);

				switch(next.def)
				{
					case LPointer(arr, _):
						if(ls.condCompilation && arr.length > 0)
						{
							var vector:Vector<String> = new Vector(arr.length);
							for(k=>i in arr)
							{
								var buf = new StringBuf();

								while(ls.emregex.match(i))
								{
									var result:String = ls.emregex.matched(3);
									if(result == null) result = ls.emregex.matched(2);

									buf.add(ls.emregex.matchedLeft());
									if(ls.emregex.matched(1) != '@')
									{
										if(ls.embeddedVariables.exists(result))
											buf.add(Std.string(ls.embeddedVariables.get(result)));
										else if(ls.dic.exists(result))
											buf.add(ls.dic.get(result)[0]);
									} else
									{
										buf.add(ls.emregex.matched(0).substr(1));
									}
									i = ls.emregex.matchedRight();
								}
								buf.add(i);
								vector.set(k, buf.toString());
							}
							ls.dic.set(id, vector);
						}
					default:
						unexpectedLex(ls, LPointer(null, false));
				}
			case LPreFork(cp):
				switch(cp)
				{
					case CIf:
						var next = nextLex(ls, lexes);

						switch(next.def)
						{
							case LIdentifier(id):
								final last = ls.condCompilation;
								ls.condCompilation = (last && ls.preprocesorDefines.contains(id));

								var oneShot:Bool = true;
								while(true)
								{
									next = nextLex(ls, lexes);
									if(next.def.match(LPreFork(CEnd))) break;
									if(oneShot && next.def.match(LPreFork(CElse)))
									{
										oneShot = false;
										ls.condCompilation = !ls.condCompilation;
									} else _parseExpr(ls, next, lexes);
								}
								ls.condCompilation = last;
							default:
								unexpectedLex(ls);
						}
					default:
						unexpectedLex(ls, LPreFork(CIf));
				}
			default:
				unexpectedLex(ls);
		}
	}

	static function nextLex(ls:LangState, lexes:List<Lex>):Null<Lex>
	{
		var next = lexes.pop();
		if(next == null) unexpectedTerminal(ls);
		ls.forceLex = next;
		return next;
	}

	static function unexpectedTerminal(ls:LangState)
	{
		error("The retrieval location is at the terminal", ls.forceLex);
	}

	static function unexpectedLex(ls:LangState, ?expect:LexDef)
	{
		final msg:String = if(expect != null) "Expected syntax '" + toLexString(expect) + "', but it is '" + toLexString(ls.forceLex.def) + "' actually" else "Unexpected syntax '" + toLexString(ls.forceLex.def) + "'";
		error(msg, ls.forceLex);
	}

	public static function toLexString(lex:LexDef):String
	{
		return switch(lex)
		{
			case LPointer(_, td): '[' + (td ? ':' : "") + "=> *]";
			case LTypeDecl(tc): "[type: " + (switch(tc)
			{
				case TUnknown: "(unknown)";
				case TInt: "(int)";
				case TFloat: "(float)";
				case TString: "(string)";
			}) + "]";
			case LIdentifier(id): id;
			case LPreFork(cp): '#' + (switch(cp)
			{
				case CIf: "if";
				case CElse: "else";
				case CEnd: "end";
			});
		}
	}

	static inline function error(msg:String, lex:Null<Lex>)
	{
		throw if(lex != null) new LangException(msg, lex.line, lex.tmin, lex.tmax) else new LangException(msg, 1, 0, 0);
	}

	inline static function inLetter(char:Int):Bool {
		return (char >= 65 && char <= 90) || (char >= 97 && char <= 122) || inDownLine(char);
	}

	inline static function inNumber(char:Int):Bool {
		return char >= 48 && char <= 57;
	}

	inline static function inDownLine(char:Int):Bool {
		return char == 95;
	}

	public inline static function inLu(char:Int):Bool {
		return inNumber(char) || inLetter(char);
	}

	inline static function inSex(char:Int):Bool {
		return inNumber(char) || (char >= 97 && char <= 102) || (char >= 65 && char <= 70);
	}
}

/**
 * 我也不知道这该叫什么
 * 反正就是跟`Xml`差不多吧
 */
class LangState
{
	/**
	 * 预设lang可被允许使用的嵌入值
	 */
	public var embeddedVariables:Map<String, Dynamic>;

	private var thrown:Null<String>;

	var forceLex:Null<Lex>;
	var dic:Map<String, Vector<String>>;
	var condCompilation:Bool = true;
	private var emregex = ~/(.?)@([a-zA-Z_][a-zA-Z_0-9]*|\{([a-zA-Z_][a-zA-Z_0-9]*(?:(\.|:)[a-zA-Z_][a-zA-Z_0-9]*)*)\})/;

	var preprocesorDefines:Array<String>;

	/**
	 * 我不知道
	 */
	public function new()
	{
		preprocesorDefines = [];
		embeddedVariables = new Map();
	}

	/**
	 * 添加编译定义的值，可以使`#if define`来控制执行的操作
	 * @param define		 u m3
	 */
	public inline function addDefine(define:String)
	{
		preprocesorDefines.push(define);
	}

	private var forceKey:Null<String>;
	/**
	 * 锁定一个lang中的键，需要在`Parser.parse`或`Parser.parseFile`后使用
	 * 如果lang本身出现语法错误，可能使用也会出错
	 * @param key			 一个键
	 * @return 					 返回检测是否存在此键的布尔值
	 */
	public function forceAtKey(key:String):Bool
	{
		forceKey = null;

		final cond = dic.exists(key);
		if(cond) forceKey = key;
		return cond;
	}

	/**
	 * 需要锁定一个lang的键后使用，用于获取键对应的元组中的一个值
	 * 如果lang本身出现语法错误，可能使用也会出错
	 * @param i					 元组的层数
	 * @return 					 如果不存在，（通常）返回`null`
	 */
	public function getAtIndex(i:Int):Null<String>
	{
		if(forceKey != null)
		{
			return dic.get(forceKey)[i];
		}

		return null;
	}

	/**
	 * 需要锁定一个lang的键后使用，获取此键的元组
	 * 如果lang本身出现语法错误，可能使用也会出错
	 * @return 					 u m3
	 */
	public function getAtArray():Array<String>
	{
		if(forceKey != null)
		{
			return dic.get(forceKey).toArray();
		}

		return null;
	}

	/**
	 * 获取所有的键
	 * 如果lang本身出现语法错误，可能使用也会出错
	 * @return 					 自己看
	 */
	public function keys():Iterator<String>
	{
		return dic.keys();
	}

	/**
	 * 需要锁定一个lang的键后使用，用于获取键对应的元组中的第一个元素
	 * 如果lang本身出现语法错误，可能使用也会出错
	 * @return 					 如果不存在，（通常）返回`null`
	 */
	public function getAtFirst():Null<String>
	{
		if(forceKey != null)
		{
			return dic.get(forceKey)[0];
		}

		return null;
	}

	/**
	 * 需要锁定一个lang的键后使用，用于获取键对应的元组中的最后一个元素
	 * 如果lang本身出现语法错误，可能使用也会出错
	 * @return 					 如果不存在，（通常）返回`null`
	 */
	public function getAtLast():Null<String>
	{
		if(forceKey != null)
		{
			final a = dic.get(forceKey);
			return a[a.length - 1];
		}

		return null;
	}

	/**
	 * 取消锁定的键
	 */
	public function putAtKey()
	{
		forceKey = null;
	}

	/**
	 * 获取lang的报错信息，需要搭配`Parser.parse`或`Parser.parseFile`使用
	 * @return 					 如果本身未报错，会返回值
	 */
	public function errorMessage():Null<String>
	{
		return thrown;
	}
}

@:structInit
private class Lex
{
	public var tmin:Int;
	public var tmax:Int;
	public var line:Int;
	public var def:LexDef;

	public function toString():String
	{
		return '[$def($line, $tmin, $tmax)';
	}
}

class LangException
{
	var tmin:Int;
	var tmax:Int;
	var line:Int;
	var msg:String;

	public function new(msg:String, line:Int, tmin:Int, tmax:Int)
	{
		this.msg = msg;
		this.line = line;
		this.tmin = tmin;
		this.tmax = tmax;
	}

	public function toString():String
	{
		return 'in line $line($tmin-$tmax): $msg';
	}
}

private enum LexDef
{
	LTypeDecl(tc:TypeChecker);
	LPointer(meta:Array<String>, typeDeclaration:Bool);
	LIdentifier(id:String);
	LPreFork(cp:CompilerPointer);
}

private enum abstract TypeChecker(NativeUInt)
{
	var TUnknown:TypeChecker;
	var TInt:TypeChecker;
	var TFloat:TypeChecker;
	var TString:TypeChecker;
}

private enum abstract CompilerPointer(NativeUInt)
{
	var CIf:CompilerPointer;
	var CElse:CompilerPointer;
	var CEnd:CompilerPointer;
}

private class Lexer
{
	var pos:Int;
	var line:Int;
	var char:Null<Int> = null;
	var ret:List<Lex>;

	var input:String;

	public function new(content:Dynamic)
	{
		if(content is haxe.io.Bytes)
			input = (content : haxe.io.Bytes).toString();
		else if(content is String)
			input = cast content;
		else
			input = Std.string(content);

		pos = 0;
		line = 1;
	}

	var linePos:Int = 0;
	private inline function getChar():Int
	{
		linePos++;
		return StringTools.fastCodeAt(input, pos++);
	}

	var tokenMin:Int;
	public function doLex():List<Lex>
	{
		ret = new List();

		while(true)
		{
			var char:Int = this.char != null ? this.char : getChar();
			this.char = null;

			tokenMin = linePos;
			switch(char)
			{
				case 32 | 13 | 9: // skip
				case 10:
					line++;
					linePos = 0;
				case '#'.code:
					char = getChar();
					if(char == '>'.code)
					{
						while(true)
						{
							char = getChar();
							if(char == 10 || StringTools.isEof(char))
							{
								this.char = char;
								break;
							}
						}
					} else if(Parser.inLetter(char))
					{
						var id:String = String.fromCharCode(char);
						while(true)
						{
							char = getChar();
							if(!Parser.inLu(char))
							{
								this.char = char;
								break;
							}
							id += String.fromCharCode(char);
						}
						tprefork(id);
					} else this.char = char;
				case '('.code:
					char = getChar();
					switch(char)
					{
						case _ if(Parser.inLetter(char)):
							var id:String = String.fromCharCode(char);
							while(true)
							{
								char = getChar();
								if(!Parser.inLu(char))
								{
									if(char != ')'.code) terror("Request ')' at the end of the type identifier");
									break;
								}
								id += String.fromCharCode(char);
							}

							tpush(LTypeDecl(switch(id)
							{
								case "int": TInt;
								case "float": TFloat;
								case "string": TString;
								case _:
									terror("Invalid type declaration '" + id + "'");
									TUnknown;
							}));
						default:
							terror("Request identifier at the '(' declaring type");
					}
				case ':'.code:
					if((char = getChar()) == '='.code && (char = getChar()) == '>'.code)
					{
						var value:Array<String> = [];
						var buf:StringBuf = null;
						while(true)
						{
							char = getChar();
							switch(char)
							{
								case 32 | 13 | 9:
									if(buf != null)
									{
										value.push(buf.toString());
										buf = null;
									}
								case 10:
									this.char = char;
									break;
								case _ if(StringTools.isEof(char)):
									this.char = char;
									break;
								default:
									if(buf == null) buf = new StringBuf();
									if(char == '"'.code || char == '\''.code) buf.add(tstring(char));
									else buf.addChar(char);
							}
						}
						if(buf != null)
						{
							value.push(buf.toString());
							buf = null;
						}

						tpush(LPointer(value, true));
					} else this.char = char;
				case '='.code:
					char = getChar();
					if(char == '>'.code)
					{
						var value:Array<String> = [];
						var buf:StringBuf = null;
						while(true)
						{
							char = getChar();
							switch(char)
							{
								case 32 | 13 | 9:
									if(buf != null)
									{
										value.push(buf.toString());
										buf = null;
									}
								case 10:
									this.char = char;
									break;
								case _ if(StringTools.isEof(char)):
									this.char = char;
									break;
								default:
									if(buf == null) buf = new StringBuf();
									if(char == '"'.code || char == '\''.code) buf.add(tstring(char));
									else buf.addChar(char);
							}
						}
						if(buf != null)
						{
							value.push(buf.toString());
							buf = null;
						}

						tpush(LPointer(value, false));
					} else this.char = char;
				case _ if(Parser.inLetter(char)):
					var id:String = String.fromCharCode(char);
					while(true)
					{
						char = getChar();
						if(!Parser.inLu(char))
						{
							this.char = char;
							break;
						}
						id += String.fromCharCode(char);
					}
					tpush(LIdentifier(id));
				case _ if(StringTools.isEof(char)):
					break;
				case _:
					terror("Invalid Character '" + (isSpace(char) || StringTools.isEof(char) ? '<\\$char>' : String.fromCharCode(char)) + '\'');
			}
		}

		return ret;
	}

	private function tprefork(s:String)
	{
		switch(s)
		{
			case "if":
				tpush(LPreFork(CIf));
			case "else":
				tpush(LPreFork(CElse));
			case "end":
				tpush(LPreFork(CEnd));
			default:
				terror("Invalid compilation instruction '" + s + "'");
		}
	}

	private function tstring(until:Int):String
	{
		var buf = new StringBuf();
		var esc:Bool = false;
		while(true)
		{
			final rp = linePos;
			var char = getChar();
			if(esc)
			{
				switch(char)
				{
					case 'n'.code:
						buf.add('\n');
					case 't'.code:
						buf.add('\t');
					case 'r'.code:
						buf.add('\r');
					case '\\'.code:
						buf.add('\\');
					case '\''.code, '"'.code:
						buf.addChar(char);
					case _:
						terror("Incomplete escape sequence", null, rp - 1);
				}
				esc = false;
			} else
			{
				switch(char)
				{
					case '\\'.code:
						esc = true;
					case _ if(char == until):
						break;
					case 13, 10:
						terror("missing ending-string quote", null, rp);
					case _ if(StringTools.isEof(char)):
						terror("missing ending-string quote", null, rp);
					default:
						buf.addChar(char);
				}
			}
		}

		return buf.toString();
	}

	inline static function isSpace(c:Int)
	{
		return (c > 8 && c < 14) || c == 32;
	}

	inline function terror(msg:String, ?line:Int, ?tmin:Int, ?tmax:Int)
	{
		throw new LangException(msg, line ?? this.line, tmin ?? (this.tokenMin - 1), tmax ?? linePos);
	}

	inline function tpush(def:LexDef, ?line:Int, ?tmin:Int, ?tmax:Int)
	{
		ret.add({def: def, line: line ?? this.line, tmin: tmin ?? (tokenMin - 1), tmax: tmax ?? linePos});
	}
}

private typedef NativeUInt = #if cpp cpp.UInt8 #elseif cs cpp.types.UInt8 #else UInt #end
