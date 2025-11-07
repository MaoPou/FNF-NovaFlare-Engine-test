#pragma header
#pragma format R8G8B8A8_SRGB

uniform float color_radius;
uniform float resolution_ratio;

/*
	Hello, this is HEIHUA.
	This shader collection creates a retro/vintage visual effect with:
	* Color reduction and quantization
	* Resolution downscaling
	* YUV 4:2:0 chroma subsampling simulation
	* Aged color palette emulation
	* Edge sharpening for that "crunchy" retro look
	* Performance optimization through resolution control

	This effect pipeline consists of 5 specialized shaders:
	* lowquality_0_reduce.frag: Core processing - color reduction & YUV conversion
	* lowquality_1_rgb.frag: YUV to RGB conversion with color adjustment
	* lowquality_2_sharpen.frag: Edge enhancement and detail sharpening
	* lowquality_3_blockEffect.frag: Compression artifact simulation
	* lowquality_4_amplification.frag: Final output scaling

	You can experiment by disabling individual shaders (except the core reduce and amplification stages)
	to see how each contributes to the overall retro aesthetic.

	Note: The blockEffect shader intentionally creates subtle compression artifacts
	to mimic the "chunkiness" of heavily compressed vintage video.

	PS: Please preserve these notes for future reference --- HEIHUA.
*/

const mat3 RGBFromYUV = mat3(
	1.0, 1.0, 1.0,
	0.0, -0.39465, 2.03211,
	1.13983, -0.58060, 0.0
);

void main() {
	float textureScale = openfl_TextureSize.y / resolution_ratio;

	vec2 uv = openfl_TextureCoordv * textureScale;

	if (all(lessThanEqual(uv, vec2(1.0))))
	{
		vec2 uv_color = openfl_TextureCoordv / color_radius;

		vec4 color = texture2D(bitmap, openfl_TextureCoordv);
		color.gb = texture2D(bitmap, uv_color - vec2(0.001 / textureScale, 0.0)).gb - 0.5;
		color.rgb = RGBFromYUV * color.rgb;

		gl_FragColor = color;
	}
}