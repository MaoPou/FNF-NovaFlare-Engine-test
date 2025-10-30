package shaders;

import flixel.addons.display.FlxRuntimeShader;
import lime.graphics.opengl.GLProgram;
import lime.app.Application;

class ErrorHandledShader extends FlxShader implements IErrorHandler
{
	public var shaderName:String = '';

	public dynamic function onError(error:Dynamic):Void
	{
	}

	public function new(?shaderName:String)
	{
		this.shaderName = shaderName;
		super();
	}

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
	{
		try
		{
			final res = super.__createGLProgram(vertexSource, fragmentSource);
			return res;
		}
		catch (error)
		{
			ErrorHandledShader.crashSave(this.shaderName, error, onError);
			return null;
		}
	}

	public static function crashSave(shaderName:String, error:Dynamic, onError:Dynamic) // prevent the app from dying immediately
	{
		if (shaderName == null)
			shaderName = 'unnamed';
		var alertTitle:String = 'Error on Shader: "$shaderName"';

		trace(error);

		#if !debug
		// Save a crash log on Release builds
		var errMsg:String = "";
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");

		if (!FileSystem.exists('./logs/'))
			FileSystem.createDirectory('./logs/');

		var crashLogPath:String = './logs/shader_${shaderName}_${dateNow}.txt';
		File.saveContent(crashLogPath, error);
		Application.current.window.alert('Error log saved at: $crashLogPath', alertTitle);
		#else
		Application.current.window.alert('Error logs aren\'t created on debug builds, check the trace log instead.', alertTitle);
		#end

		onError(error);
	}
}

class ErrorHandledRuntimeShader extends FlxRuntimeShader implements IErrorHandler
{
	public var shaderName:String = '';
	public var custom:Bool = false;
	public var save:Bool = true;

	public dynamic function onError(error:Dynamic):Void
	{
	}

	public function new(?shaderName:String, ?fragmentSource:String, ?vertexSource:String, ?save:Bool)
	{
		this.shaderName = shaderName;
		if (save != null)
			this.save = save;
		super(fragmentSource, vertexSource);
	}

	@:noCompletion private override function __initGL():Void
	{
		if (__glSourceDirty || __paramBool == null)
		{
			__glSourceDirty = false;
			program = null;

			__inputBitmapData = new Array();
			__paramBool = new Array();
			__paramFloat = new Array();
			__paramInt = new Array();

			__processGLData(glVertexSource, "attribute");
			__processGLData(glVertexSource, "uniform");
			__processGLData(glFragmentSource, "uniform");
		}

		if (__context != null && program == null)
			initGLforce();
	}

	public function initGLforce()
	{
		if (!custom)
			initGood(glFragmentSource, glVertexSource);
	}

	public function initGood(glFragmentSource:String, glVertexSource:String)
	{
		try
		{
			@:privateAccess
			var gl = __context.gl;

			// 生成版本前缀
			#if lime_opengles
			var versionPrefix = "#version 300 es\n";
			var isES = true;
			#else
			var versionPrefix = "#version 400 core\n";
			var isES = false;
			#end

			var precisionPrefix = "#ifdef GL_ES\n"
				+ (precisionHint == FULL ? "#ifdef GL_FRAGMENT_PRECISION_HIGH\n"
					+ "precision highp float;\n"
					+ "#else\n"
					+ "precision mediump float;\n"
					+ "#endif\n" : "precision lowp float;\n")
				+ "#endif\n\n";

			// 局部转换函数：统一升级到现代 GLSL 语法
			function upgradeCommon(source:String):String
			{
				var s = source;
				// 纹理采样 API 统一至现代版本
				s = s.replace("texture2DProj", "textureProj");
				s = s.replace("texture2DLod", "textureLod");
				s = s.replace("textureCubeLod", "textureLod");
				s = s.replace("texture3D", "texture");
				s = s.replace("textureCube", "texture");
				s = s.replace("texture2D", "texture");
				// 移除 ES3 已内建的派生扩展声明
				s = s.replace("#extension GL_OES_standard_derivatives : enable", "");
				return s;
			}

			function upgradeVertex(source:String):String
			{
				var s = source;
				// attribute/varying 升级为 in/out（顶点着色器为 out）
				s = s.replace("attribute", "in");
				s = s.replace("varying", "out");
				s = upgradeCommon(s);
				return s;
			}

			function upgradeFragment(source:String):String
			{
				var s = source;
				// attribute 不应出现在片段着色器，但若出现仍统一
				s = s.replace("attribute", "in");
				// varying 在片段着色器为 in
				s = s.replace("varying", "in");
				s = upgradeCommon(s);
				// gl_FragData/gl_FragColor 迁移到用户定义输出
				// 简化处理：统一写到单一输出 output_FragColor
				s = s.replace("gl_FragData[0]", "output_FragColor");
				s = s.replace("gl_FragColor", "output_FragColor");
				return s;
			}

			var needsFragOut:Bool = (glFragmentSource.indexOf("gl_FragColor") >= 0) || (glFragmentSource.indexOf("gl_FragData") >= 0);

			// 构建顶点/片段源码（在片段中按需声明输出）
			var vertexHeader = versionPrefix + precisionPrefix;
			var fragmentHeader = versionPrefix + precisionPrefix + (needsFragOut ? "out vec4 output_FragColor;\n" : "");

			var vertex = vertexHeader + upgradeVertex(glVertexSource);
			var fragment = fragmentHeader + upgradeFragment(glFragmentSource);

			var id = vertex + fragment;
			@:privateAccess
			if (__context.__programs.exists(id) && save)
			{
				@:privateAccess
				program = __context.__programs.get(id);
			}
			else
			{
				program = __context.createProgram(GLSL);

				@:privateAccess
				program.__glProgram = __createGLProgram(vertex, fragment);
				@:privateAccess
				if (save)
					__context.__programs.set(id, program);
			}

			if (program != null)
			{
				@:privateAccess
				glProgram = program.__glProgram;

				// Set up input bitmap data
				for (input in __inputBitmapData)
				{
					@:privateAccess
					if (input.__isUniform)
					{
						@:privateAccess
						input.index = gl.getUniformLocation(glProgram, input.name);
					}
					else
					{
						@:privateAccess
						input.index = gl.getAttribLocation(glProgram, input.name);
					}
				}

				// Set up boolean parameters
				for (parameter in __paramBool)
				{
					@:privateAccess
					if (parameter.__isUniform)
					{
						@:privateAccess
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						@:privateAccess
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				// Set up float parameters
				for (parameter in __paramFloat)
				{
					@:privateAccess
					if (parameter.__isUniform)
					{
						@:privateAccess
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						@:privateAccess
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}

				// Set up integer parameters
				for (parameter in __paramInt)
				{
					@:privateAccess
					if (parameter.__isUniform)
					{
						@:privateAccess
						parameter.index = gl.getUniformLocation(glProgram, parameter.name);
					}
					else
					{
						@:privateAccess
						parameter.index = gl.getAttribLocation(glProgram, parameter.name);
					}
				}
			}
		}
		catch (error)
		{
			ErrorHandledShader.crashSave(this.shaderName, error, onError);
		}
	}

	override function __createGLProgram(vertexSource:String, fragmentSource:String):GLProgram
	{
		try
		{
			final res = super.__createGLProgram(vertexSource, fragmentSource);
			return res;
		}
		catch (error)
		{
			ErrorHandledShader.crashSave(this.shaderName, error, onError);
			return null;
		}
	}
}

interface IErrorHandler
{
	public var shaderName:String;
	public dynamic function onError(error:Dynamic):Void;
}
