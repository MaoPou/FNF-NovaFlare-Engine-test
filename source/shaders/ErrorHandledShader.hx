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

	public static function crashSave(shaderName:String, error:Dynamic, onError:Dynamic, ?vertexSource:String, ?fragmentSource:String)
	{
		if (shaderName == null)
			shaderName = 'unnamed';
		var alertTitle:String = 'Error on Shader: "$shaderName"';

		#if !debug
		var errMsg:String = "";
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");

		if (!FileSystem.exists('./logs/'))
			FileSystem.createDirectory('./logs/');

		var crashLogPath:String = './logs/shader_${shaderName}_${dateNow}.txt';
		var fullReport = 'Shader: $shaderName\nError: $error\n\n';
		if (vertexSource != null) {
			fullReport += '--- VERTEX SHADER (Processed) ---\n$vertexSource\n\n';
		}
		if (fragmentSource != null) {
			fullReport += '--- FRAGMENT SHADER (Processed) ---\n$fragmentSource\n';
		}
		File.saveContent(crashLogPath, fullReport);
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
		var vertex:String = null;
		var fragment:String = null;
		try
		{
			@:privateAccess
			var gl = __context.gl;

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

			var compat = ShaderCompatChecker.toES3(glVertexSource, glFragmentSource, isES);
			var needsFragOut:Bool = compat.needsFragOut;

			var vertexHeader = versionPrefix + precisionPrefix;
			var fragmentHeader = versionPrefix + precisionPrefix + (needsFragOut ? "out vec4 output_FragColor;\n" : "");

			vertex = vertexHeader + compat.convertedVertex;
			fragment = fragmentHeader + compat.convertedFragment;

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
			ErrorHandledShader.crashSave(this.shaderName, error, onError, vertex, fragment);
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
			ErrorHandledShader.crashSave(this.shaderName, error, onError, vertexSource, fragmentSource);
			return null;
		}
	}
}

interface IErrorHandler
{
	public var shaderName:String;
	public dynamic function onError(error:Dynamic):Void;
}
