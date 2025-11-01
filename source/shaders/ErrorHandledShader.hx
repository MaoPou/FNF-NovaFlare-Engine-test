package shaders;

import flixel.addons.display.FlxRuntimeShader;
import lime.graphics.opengl.GLProgram;
import lime.app.Application;
import shaders.backend.ShaderCompatChecker;

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
				+ "#ifdef GL_FRAGMENT_PRECISION_HIGH\n"
				+ "precision highp float;\n"
				+ "#else\n"
				+ "precision mediump float;\n"
				+ "#endif\n"
				+ "#endif\n\n";

			// 使用后端兼容检查器完成 ES3 预转换
			var compat = ShaderCompatChecker.toES3(glVertexSource, glFragmentSource, isES);
			var needsFragOut:Bool = compat.needsFragOut;

			// 构建顶点/片段源码（在片段中按需声明输出）
			var vertexHeader = versionPrefix + precisionPrefix;
			var fragmentHeader = versionPrefix + precisionPrefix + (needsFragOut ? "out vec4 output_FragColor;\n" : "");

			var vertex = vertexHeader + compat.convertedVertex;
			var fragment = fragmentHeader + compat.convertedFragment;

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
