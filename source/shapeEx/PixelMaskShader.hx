package shapeEx;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;

class PixelMaskShader extends FlxShader
{
	@:glFragmentHeader('
		#pragma header
		uniform sampler2D uMask;
		uniform vec2 uMaskPos;
		uniform vec2 uMaskSize;
		uniform vec2 uTargetPos;
		uniform vec2 uTargetSize;
		uniform float uMultiplyAlpha;

		vec4 sampleWithMask(sampler2D baseTex, vec2 uv) {
			vec4 base = flixel_texture2D(baseTex, uv);
			if (base.a <= 0.0) return base;

			// world position of this fragment relative to target top-left
			vec2 worldPos = uTargetPos + uv * uTargetSize;
			// mask uv
			vec2 mUV = (worldPos - uMaskPos) / uMaskSize;

			// outside mask -> transparent
			if (mUV.x < 0.0 || mUV.y < 0.0 || mUV.x > 1.0 || mUV.y > 1.0) {
				return vec4(0.0, 0.0, 0.0, 0.0);
			}

			vec4 m = flixel_texture2D(uMask, mUV);
			float ma = m.a;
			// 默认使用乘法以避免透明区域被“填色”
			if (uMultiplyAlpha > 0.5) {
				base.rgb *= ma;
				base.a *= ma;
			} else {
				base.a = ma;
			}
			return base;
		}
	')
	@:glFragmentSource('
		#pragma header
		void main() {
			gl_FragColor = sampleWithMask(bitmap, openfl_TextureCoordv);
		}
	')
	public function new()
	{
		super();
	}

	public function setMaskBitmap(bmp:BitmapData)
	{
		if (bmp == null) return;
		this.uMask.input = bmp;
	}
}
