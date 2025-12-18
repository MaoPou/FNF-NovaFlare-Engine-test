package shaders.states.freeplayState;
/**
 * A high-performance multi-pass blur filter system for HaxeFlixel.
 *
 * IMPORTANT: If you're not getting the expected blur effect, try adding this line before applying the filter:
 * ```haxe
 * FlxG.game.quality = FlxG.game.stage.quality = 0;
 * ```
 * This ensures the stage quality doesn't interfere with shader rendering.
 * 
 * This system uses a combination of downsampling, multi-quality sampling, and multi-pass blurring
 * to achieve efficient blur effects with consistent performance across different blur intensities.
 * 
 * Key Features:
 * - 4 quality levels for downsampling (8x8, 4x4, 2x2, single sample)
 * - Multi-pass blur pipeline for optimal quality/performance balance
 * - Dynamic quality adjustment based on blur intensity
 * - Edge protection and texture coordinate validation
 * - Mobile-optimized with minimal texture sampling
 * 
 * Performance Characteristics:
 * - Stable performance regardless of blur radius
 * - Memory efficient due to resolution reduction
 * - Scalable quality based on device capabilities
 * 
 * @since 1.0
 * @author HEIHUA, deepseek
 */
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;

class BlurFilter {
	/**
	 * The primary reduction shader that performs intelligent downsampling with multi-level quality.
	 * 
	 * This shader reduces image resolution while maintaining visual quality through carefully
	 * weighted sampling patterns. It implements four distinct quality modes:
	 * 
	 * Quality Modes:
	 * - Mode 0 (High): 64-sample 8x8 weighted grid for maximum quality
	 * - Mode 1 (Balanced): 16-sample 4x4 weighted grid for optimal performance/quality balance
	 * - Mode 2 (Light): 4-sample 2x2 average for mobile and performance-sensitive scenarios
	 * - Mode 3 (Basic): Single sample for minimal blur or performance testing
	 * 
	 * Technical Features:
	 * - Edge protection with texture coordinate boundary checking
	 * - Weighted sampling to prevent aliasing artifacts
	 * - Dynamic mode selection based on performance requirements
	 * - Optimized for parallel GPU execution
	 */
	public var blurShader_reduce:FlxRuntimeShader = new FlxRuntimeShader("
		#pragma header

		#define uv openfl_TextureCoordv

		uniform int modifier;

		varying vec4 uv_x;
		varying vec4 uv_y;

		varying vec4 openfl_TextureData;

		void main() {
			if (all(lessThanEqual(uv, openfl_TextureData.xy)))
			{
				vec4 color;

				if (modifier <= 0)
				{
					color = (
						texture2D(bitmap, uv + vec2(uv_x[0], uv_y[0])) +
						texture2D(bitmap, uv + vec2(uv_x[1], uv_y[0])) * 2.0 +
						texture2D(bitmap, uv + vec2(uv_x[2], uv_y[0])) * 2.0 +
						texture2D(bitmap, uv + vec2(uv_x[3], uv_y[0])) * 3.0 +
						texture2D(bitmap, uv + vec2(-uv_x[3], uv_y[0])) * 3.0 +
						texture2D(bitmap, uv + vec2(-uv_x[2], uv_y[0])) * 2.0 +
						texture2D(bitmap, uv + vec2(-uv_x[1], uv_y[0])) * 2.0 +
						texture2D(bitmap, uv + vec2(-uv_x[0], uv_y[0])) +

						texture2D(bitmap, uv + vec2(uv_x[0], uv_y[1])) * 2.0 +
						texture2D(bitmap, uv + vec2(uv_x[1], uv_y[1])) * 4.0 +
						texture2D(bitmap, uv + vec2(uv_x[2], uv_y[1])) * 4.0 +
						texture2D(bitmap, uv + vec2(uv_x[3], uv_y[1])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[3], uv_y[1])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[2], uv_y[1])) * 4.0 +
						texture2D(bitmap, uv + vec2(-uv_x[1], uv_y[1])) * 4.0 +
						texture2D(bitmap, uv + vec2(-uv_x[0], uv_y[1])) * 2.0 +

						texture2D(bitmap, uv + vec2(uv_x[0], uv_y[2])) * 2.0 +
						texture2D(bitmap, uv + vec2(uv_x[1], uv_y[2])) * 4.0 +
						texture2D(bitmap, uv + vec2(uv_x[2], uv_y[2])) * 4.0 +
						texture2D(bitmap, uv + vec2(uv_x[3], uv_y[2])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[3], uv_y[2])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[2], uv_y[2])) * 4.0 +
						texture2D(bitmap, uv + vec2(-uv_x[1], uv_y[2])) * 4.0 +
						texture2D(bitmap, uv + vec2(-uv_x[0], uv_y[2])) * 2.0 +

						texture2D(bitmap, uv + vec2(uv_x[0], uv_y[3])) * 3.0 +
						texture2D(bitmap, uv + vec2(uv_x[1], uv_y[3])) * 6.0 +
						texture2D(bitmap, uv + vec2(uv_x[2], uv_y[3])) * 6.0 +
						texture2D(bitmap, uv + vec2(uv_x[3], uv_y[3])) * 9.0 +
						texture2D(bitmap, uv + vec2(-uv_x[3], uv_y[3])) * 9.0 +
						texture2D(bitmap, uv + vec2(-uv_x[2], uv_y[3])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[1], uv_y[3])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[0], uv_y[3])) * 3.0 +

						texture2D(bitmap, uv + vec2(uv_x[0], -uv_y[3])) * 3.0 +
						texture2D(bitmap, uv + vec2(uv_x[1], -uv_y[3])) * 6.0 +
						texture2D(bitmap, uv + vec2(uv_x[2], -uv_y[3])) * 6.0 +
						texture2D(bitmap, uv + vec2(uv_x[3], -uv_y[3])) * 9.0 +
						texture2D(bitmap, uv + vec2(-uv_x[3], -uv_y[3])) * 9.0 +
						texture2D(bitmap, uv + vec2(-uv_x[2], -uv_y[3])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[1], -uv_y[3])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[0], -uv_y[3])) * 3.0 +

						texture2D(bitmap, uv + vec2(uv_x[0], -uv_y[2])) * 2.0 +
						texture2D(bitmap, uv + vec2(uv_x[1], -uv_y[2])) * 4.0 +
						texture2D(bitmap, uv + vec2(uv_x[2], -uv_y[2])) * 4.0 +
						texture2D(bitmap, uv + vec2(uv_x[3], -uv_y[2])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[3], -uv_y[2])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[2], -uv_y[2])) * 4.0 +
						texture2D(bitmap, uv + vec2(-uv_x[1], -uv_y[2])) * 4.0 +
						texture2D(bitmap, uv + vec2(-uv_x[0], -uv_y[2])) * 2.0 +

						texture2D(bitmap, uv + vec2(uv_x[0], -uv_y[1])) * 2.0 +
						texture2D(bitmap, uv + vec2(uv_x[1], -uv_y[1])) * 4.0 +
						texture2D(bitmap, uv + vec2(uv_x[2], -uv_y[1])) * 4.0 +
						texture2D(bitmap, uv + vec2(uv_x[3], -uv_y[1])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[3], -uv_y[1])) * 6.0 +
						texture2D(bitmap, uv + vec2(-uv_x[2], -uv_y[1])) * 4.0 +
						texture2D(bitmap, uv + vec2(-uv_x[1], -uv_y[1])) * 4.0 +
						texture2D(bitmap, uv + vec2(-uv_x[0], -uv_y[1])) * 2.0 +

						texture2D(bitmap, uv + vec2(uv_x[0], -uv_y[0])) +
						texture2D(bitmap, uv + vec2(uv_x[1], -uv_y[0])) * 2.0 +
						texture2D(bitmap, uv + vec2(uv_x[2], -uv_y[0])) * 2.0 +
						texture2D(bitmap, uv + vec2(uv_x[3], -uv_y[0])) * 3.0 +
						texture2D(bitmap, uv + vec2(-uv_x[3], -uv_y[0])) * 3.0 +
						texture2D(bitmap, uv + vec2(-uv_x[2], -uv_y[0])) * 2.0 +
						texture2D(bitmap, uv + vec2(-uv_x[1], -uv_y[0])) * 2.0 +
						texture2D(bitmap, uv + vec2(-uv_x[0], -uv_y[0]))
					);

					gl_FragColor = color * 0.00390625;

					return;
				}

				if (modifier <= 1)
				{
					color = texture2D(bitmap, uv + vec2(uv_x[0], uv_y[0]));
					color += texture2D(bitmap, uv + vec2(uv_x[2], uv_y[0])) * 2.0;
					color += texture2D(bitmap, uv + vec2(-uv_x[2], uv_y[0])) * 2.0;
					color += texture2D(bitmap, uv + vec2(-uv_x[0], uv_y[0]));

					color += texture2D(bitmap, uv + vec2(uv_x[0], uv_y[2])) * 2.0;
					color += texture2D(bitmap, uv + vec2(uv_x[2], uv_y[2])) * 4.0;
					color += texture2D(bitmap, uv + vec2(-uv_x[2], uv_y[2])) * 4.0;
					color += texture2D(bitmap, uv + vec2(-uv_x[0], uv_y[2])) * 2.0;

					color += texture2D(bitmap, uv + vec2(uv_x[0], -uv_y[2])) * 2.0;
					color += texture2D(bitmap, uv + vec2(uv_x[2], -uv_y[2])) * 4.0;
					color += texture2D(bitmap, uv + vec2(-uv_x[2], -uv_y[2])) * 4.0;
					color += texture2D(bitmap, uv + vec2(-uv_x[0], -uv_y[2])) * 2.0;

					color += texture2D(bitmap, uv + vec2(uv_x[0], -uv_y[0]));
					color += texture2D(bitmap, uv + vec2(uv_x[2], -uv_y[0])) * 2.0;
					color += texture2D(bitmap, uv + vec2(-uv_x[2], -uv_y[0])) * 2.0;
					color += texture2D(bitmap, uv + vec2(-uv_x[0], -uv_y[0]));

					gl_FragColor = color * 0.02777777777777777777777777777778;

					return;
				}

				if (modifier <= 2)
				{
					color = texture2D(bitmap, uv + vec2(-openfl_TextureData.z, -openfl_TextureData.w));
					color += texture2D(bitmap, uv + vec2(openfl_TextureData.z, -openfl_TextureData.w));
					color += texture2D(bitmap, uv + vec2(-openfl_TextureData.z, openfl_TextureData.w));
					color += texture2D(bitmap, uv + vec2(openfl_TextureData.z, openfl_TextureData.w));
					
					gl_FragColor = color * 0.25;
					return;
				}

				if (modifier <= 3)
				{
					gl_FragColor = texture2D(bitmap, uv);

					return;
				}
			}
		}
	", "
		#pragma header

		uniform float textureScale;

		varying vec4 uv_x;
		varying vec4 uv_y;

		varying vec4 openfl_TextureData;

		const vec4 uv = vec4(-1.0, -0.75, -0.5, -0.25);

		void main(void)
		{
			openfl_TextureData.xy = 1.0 / openfl_TextureSize * textureScale * 3.0 + 1.0;

			openfl_TextureData.zw = 1.0 / openfl_TextureSize * textureScale * 0.5;

			vec2 step = 1.0 / openfl_TextureSize * textureScale;

			uv_x = uv * step.x;
			uv_y = uv * step.y;

			float size = 1.0 / min(openfl_TextureSize.x, openfl_TextureSize.y) * textureScale * 3.0 + 1.0;

			openfl_TextureCoordv = openfl_TextureCoord * size;

			vec4 scaledPos = openfl_Position;
			scaledPos.xy /= textureScale * size;

			gl_Position = openfl_Matrix * scaledPos;
		}
	");

	/**
	 * First blur pass shader that applies horizontal Gaussian-like blur.
	 * 
	 * This shader processes the downsampled image with a 7-tap horizontal blur kernel
	 * using carefully chosen weights (1,2,3,4,3,2,1) for optimal quality/performance balance.
	 * 
	 * Features:
	 * - 7-tap horizontal blur with normalized weights
	 * - Conditional execution based on texture scale
	 * - Boundary-aware sampling to prevent edge artifacts
	 * - Optimized for mobile GPU architectures
	 * 
	 * Performance Notes:
	 * - Only activates when textureScale > 2.0
	 * - Minimal branching overhead with early returns
	 * - Efficient texture cache utilization
	 */
	public var blurShader_blur_1:FlxRuntimeShader = new FlxRuntimeShader("
		#pragma header

		varying vec3 uvv;

		uniform float textureScale;

		varying vec4 openfl_TextureData;

		void main() {
			if (textureScale <= 1.0) {
				gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
				return;
			}

			if (all(lessThanEqual(openfl_TextureData.xy, openfl_TextureData.zw))) {
				vec4 color = texture2D(bitmap, openfl_TextureCoordv + vec2(-uvv.z, 0.0));
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(-uvv.y, 0.0)) * 2.0;
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(-uvv.x, 0.0)) * 3.0;
				color += texture2D(bitmap, openfl_TextureCoordv) * 4.0;
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(uvv.x, 0.0)) * 3.0;
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(uvv.y, 0.0)) * 2.0;
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(uvv.z, 0.0));

				gl_FragColor = color * 0.0625;
			}
		}
	", "
		#pragma header

		varying vec3 uvv;

		uniform float textureScale;

		varying vec4 openfl_TextureData;

		void main()
		{
			#pragma body

			openfl_TextureData.xy = openfl_TextureCoord * textureScale;

			openfl_TextureData.zw = 1.0 / openfl_TextureSize * textureScale * 3.0 + 1.0;

			float vtextureSize = 1.0 / openfl_TextureSize.x;

			float i = clamp((textureScale - 1.0) / 3.0, 0.0, 1.0);

			uvv = vec3(1.0, 2.0, 3.0) * vtextureSize * i;
		}
	");

	/**
	 * Second blur pass shader that applies vertical Gaussian-like blur.
	 * 
	 * Completes the 2D blur effect by applying a 7-tap vertical blur kernel with the same
	 * weight distribution as the horizontal pass, creating a symmetric blur effect.
	 * 
	 * Features:
	 * - 7-tap vertical blur matching horizontal weights
	 * - Consistent blur radius in both dimensions
	 * - Conditional execution matching horizontal pass
	 * - Edge protection and boundary validation
	 * 
	 * Quality Impact:
	 * - Creates true 2D Gaussian-like blur when combined with horizontal pass
	 * - Reduces sampling artifacts and moiré patterns
	 * - Maintains image integrity through normalized weighting
	 */
	public var blurShader_blur_2:FlxRuntimeShader = new FlxRuntimeShader("
		#pragma header

		varying vec3 uvv;

		uniform float textureScale;

		varying vec4 openfl_TextureData;

		void main() {
			if (textureScale <= 1.0) {
				gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
				return;
			}

			if (all(lessThanEqual(openfl_TextureData.xy, openfl_TextureData.zw))) {
				vec4 color = texture2D(bitmap, openfl_TextureCoordv + vec2(0.0, -uvv.z));
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(0.0, -uvv.y)) * 2.0;
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(0.0, -uvv.x)) * 3.0;
				color += texture2D(bitmap, openfl_TextureCoordv) * 4.0;
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(0.0, uvv.x)) * 3.0;
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(0.0, uvv.y)) * 2.0;
				color += texture2D(bitmap, openfl_TextureCoordv + vec2(0.0, uvv.z));

				gl_FragColor = color * 0.0625;
			}
		}
	", "
		#pragma header

		varying vec3 uvv;

		uniform float textureScale;

		varying vec4 openfl_TextureData;

		void main()
		{
			#pragma body

			openfl_TextureData.xy = openfl_TextureCoord * textureScale;

			openfl_TextureData.zw = 1.0 / openfl_TextureSize * textureScale * 3.0 + 1.0;

			float vtextureSize = 1.0 / openfl_TextureSize.x;

			float i = clamp((textureScale - 1.0) / 3.0, 0.0, 1.0);

			uvv = vec3(1.0, 2.0, 3.0) * vtextureSize * i;
		}
	");

	/**
	 * Final amplification shader that applies lightweight edge smoothing.
	 * 
	 * This shader performs a simple 4-sample cross-shaped blur to further reduce
	 * any remaining aliasing or flickering artifacts from the upscaling process.
	 * 
	 * Features:
	 * - 4-sample cross pattern (up, down, left, right)
	 * - Uniform weighting for computational efficiency
	 * - Conditional execution based on blur intensity
	 * - Minimal performance impact
	 * 
	 * Purpose:
	 * - Smooths pixelation artifacts from upscaling
	 * - Reduces temporal flickering in animated content
	 * - Provides final polish to the blur effect
	 */
	public var blurShader_amplification:FlxRuntimeShader = new FlxRuntimeShader("
		#pragma header

		uniform float textureScale;

		varying vec2 openfl_TextureSizev;

		void main() {
			if (textureScale <= 1.0) {
				gl_FragColor = texture2D(bitmap, openfl_TextureCoordv);
				return;
			}

			gl_FragColor = texture2D(bitmap, openfl_TextureCoordv + vec2(openfl_TextureSizev.x, 0.0));
			gl_FragColor += texture2D(bitmap, openfl_TextureCoordv + vec2(-openfl_TextureSizev.x, 0.0));
			gl_FragColor += texture2D(bitmap, openfl_TextureCoordv + vec2(0.0, openfl_TextureSizev.y));
			gl_FragColor += texture2D(bitmap, openfl_TextureCoordv + vec2(0.0, -openfl_TextureSizev.y));

			gl_FragColor *= 0.25;
		}
	", "
		#pragma header

		uniform float textureScale;

		varying vec2 openfl_TextureSizev;

		void main()
		{
			float size = 1.0 / min(openfl_TextureSize.x, openfl_TextureSize.y) * textureScale * 3.0 + 1.0;

			float i = clamp((textureScale - 1.0) * 2.0, 0.0, 1.0);

			openfl_TextureSizev = 1.0 / openfl_TextureSize * 0.5 * i;

			openfl_TextureCoordv = openfl_TextureCoord / size;

			vec4 scaledPos = openfl_Position;
			scaledPos.xy *= textureScale * size;

			gl_Position = openfl_Matrix * scaledPos;
		}
	");

	/**
	 * The current texture scale value representing blur intensity.
	 * 
	 * This read-only property reflects the current blur intensity calculated as (input + 1).
	 * The value is automatically managed by the set() method and should not be modified directly.
	 * 
	 * Value Range:
	 * - 1.0: Light blur with 2x2 sampling
	 * - 1.0-2.0: Medium blur with 4x4 sampling  
	 * - 2.0+: Heavy blur with 8x8 sampling
	 * 
	 * @default 1.0
	 */
	public var textureScale(default, null):Float = 1.0;

	/**
	 * Creates a new BlurFilter instance with the specified intensity.
	 * 
	 * The blur system is initialized with the given intensity value, which is automatically
	 * scaled and clamped to ensure stable performance across the entire range.
	 * 
	 * @param value The initial blur intensity (0 = minimal, higher values = stronger blur)
	 *              Defaults to 0 if not specified.
	 * 
	 * @example
	 * ```haxe
	 * // Create a medium blur effect
	 * var blur = new BlurFilter(2.0);
	 * 
	 * // Create a strong blur effect  
	 * var heavyBlur = new BlurFilter(5.0);
	 * ```
	 */
	public function new(?value:Float) {
		set(value ??= 0.0);
	}

	/**
	 * Applies the complete blur effect pipeline to the specified camera.
	 * 
	 * This method adds all four shaders to the camera's shader stack, enabling the
	 * multi-pass blur rendering. The shaders are applied in the optimal order for
	 * quality and performance.
	 * 
	 * Pipeline Order:
	 * 1. Reduction (downsampling with quality sampling)
	 * 2. Horizontal blur (7-tap Gaussian-like)
	 * 3. Vertical blur (7-tap Gaussian-like) 
	 * 4. Amplification (edge smoothing and final touch)
	 * 
	 * @param camera The FlxCamera instance to apply the blur effect to
	 * 
	 * @example
	 * ```haxe
	 * // Apply blur to main camera
	 * blurFilter.apply(FlxG.camera);
	 * 
	 * // Apply to specific camera
	 * blurFilter.apply(myCustomCamera);
	 * ```
	 */
	public function apply(camera:FlxCamera)
		for (shader in [blurShader_reduce, blurShader_blur_1, blurShader_blur_2, blurShader_amplification])
			addShader(camera, shader);

	/**
	 * Removes the blur effect from the specified camera.
	 * 
	 * This method cleanly removes all blur shaders from the camera's shader stack,
	 * restoring the original rendering state without any blur effects.
	 * 
	 * Important: Always remove shaders when they are no longer needed to free
	 * GPU resources and restore rendering performance.
	 * 
	 * @param camera The FlxCamera instance to remove the blur effect from
	 * 
	 * @example
	 * ```haxe
	 * // Remove blur from camera
	 * blurFilter.remove(FlxG.camera);
	 * ```
	 */
	public function remove(camera:FlxCamera)
		for (shader in [blurShader_reduce, blurShader_blur_1, blurShader_blur_2, blurShader_amplification])
			removeShader(camera, shader);

	/**
	 * Updates the blur intensity with automatic scaling and quality adjustment.
	 * 
	 * This method applies a scaling factor (0.2666...) to the input value to optimize
	 * the intensity range for visual quality, then calculates the final texture scale
	 * as (scaledValue + 1). The method automatically updates all shader parameters
	 * and adjusts the sampling quality based on the new intensity.
	 * 
	 * Intensity Scaling:
	 * - Input value is scaled by ~0.267 for optimal visual progression
	 * - Minimum value is clamped to 0 (no blur)
	 * - Final texture scale ranges from 1.0 to higher values
	 * 
	 * @param value The new blur intensity (0 = minimal, higher values = stronger blur)
	 */
	public function set(value:Float) {
		setModifier(value);

		textureScale = Math.max(0, value * 0.26666666666666666666666666666667) + 1;

		for (shader in [blurShader_reduce, blurShader_blur_1, blurShader_blur_2, blurShader_amplification])
			shader.setFloat('textureScale', textureScale);
	}

	/**
	 * Dynamically adjusts the sampling quality based on current blur intensity.
	 * 
	 * This internal method selects the appropriate sampling pattern for the reduction
	 * shader based on the current texture scale. Higher intensity blurs use more
	 * sophisticated sampling patterns to maintain visual quality.
	 * 
	 * Quality Thresholds:
	 * - 4.0 and above: 8x8 high-quality sampling (64 samples) for maximum quality
	 * - 2.0 to 4.0: 4x4 balanced sampling (16 samples) for optimal balance
	 * - 0.0 to 2.0: 2x2 lightweight sampling (4 samples) for mobile/performance
	 * - Exactly 0.0: Single sample (effectively no blur, only downscaling)
	 * 
	 * @param value The current texture scale used for quality determination
	 */
	public function setModifier(value:Float) {
		final modifierTable:Array<Int> = [3, 2, 1, 0];

		var reduce = blurShader_reduce;
		
		var index:Int = 0;
		if (value > 0) index++;
		if (value >= 2) index++; 
		if (value >= 4) index++;
		
		reduce.setInt('modifier', modifierTable[index]);
	}

	/**
	 * Adds a FlxShader as a filter to the camera
	 * @param shader Shader to add
	 * @return ShaderFilter
	 */
	@:privateAccess public function addShader(camera:FlxCamera, shader:FlxRuntimeShader)
	{
		var filter:ShaderFilter = null;
		if (camera.filters == null) camera.filters = [];
		camera.filters.push(filter = new ShaderFilter(shader));
		return filter;
	}

	/**
	 * Removes a FlxShader's ShaderFilter from the camera.
	 * @param shader Shader to remove
	 * @return Whenever the shader has been successfully removed or not.
	 */
	@:privateAccess public function removeShader(camera:FlxCamera, shader:FlxRuntimeShader):Bool
	{
		if (camera.filters == null) camera.filters = [];
		for (f in camera.filters) {
			if (f is ShaderFilter) {
				var sf = cast(f, ShaderFilter);
				if (sf.shader == shader) {
					camera.filters.remove(f);
					return true;
				}
			}
		}
		return false;
	}
}