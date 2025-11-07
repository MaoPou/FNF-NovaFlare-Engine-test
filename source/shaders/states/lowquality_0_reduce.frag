#pragma header
#pragma format R8G8B8A8_SRGB

uniform float blur_radius;
uniform float color_radius;
uniform float color_radius_radius;
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

void main() {
	float textureScale = openfl_TextureSize.y / resolution_ratio;
	vec2 scale = openfl_TextureSize / textureScale / blur_radius;
	vec2 scale_color = scale * color_radius / color_radius_radius;

	vec2 uv = openfl_TextureCoordv * textureScale;

	if (all(lessThanEqual(uv, vec2(1.0))))
	{
		vec2 uv_color = uv * color_radius;

		vec4 color_l = (
			texture2D(bitmap, uv + vec2(-0.75, -0.75) / scale) +
			texture2D(bitmap, uv + vec2(-0.25, -0.75) / scale) * 2.0 +
			texture2D(bitmap, uv + vec2(0.25, -0.75) / scale) * 2.0 +
			texture2D(bitmap, uv + vec2(0.75, -0.75) / scale) +

			texture2D(bitmap, uv + vec2(-0.75, -0.25) / scale) * 2.0 +
			texture2D(bitmap, uv + vec2(-0.25, -0.25) / scale) * 4.0 +
			texture2D(bitmap, uv + vec2(0.25, -0.25) / scale) * 4.0 +
			texture2D(bitmap, uv + vec2(0.75, -0.25) / scale) * 2.0 +

			texture2D(bitmap, uv + vec2(-0.75, 0.25) / scale) * 2.0 +
			texture2D(bitmap, uv + vec2(-0.25, 0.25) / scale) * 4.0 +
			texture2D(bitmap, uv + vec2(0.25, 0.25) / scale) * 4.0 +
			texture2D(bitmap, uv + vec2(0.75, 0.25) / scale) * 2.0 +

			texture2D(bitmap, uv + vec2(-0.75, 0.75) / scale) +
			texture2D(bitmap, uv + vec2(-0.25, 0.75) / scale) * 2.0 +
			texture2D(bitmap, uv + vec2(0.25, 0.75) / scale) * 2.0 +
			texture2D(bitmap, uv + vec2(0.75, 0.75) / scale)
		) / 36.0;
	
		vec3 color = vec3(0.0);
		if (all(lessThanEqual(uv_color, vec2(1.0))))
			color = (
				texture2D(bitmap, uv_color + vec2(-0.75, -0.75) / scale_color).rgb +
				texture2D(bitmap, uv_color + vec2(-0.25, -0.75) / scale_color).rgb * 2.0 +
				texture2D(bitmap, uv_color + vec2(0.25, -0.75) / scale_color).rgb * 2.0 +
				texture2D(bitmap, uv_color + vec2(0.75, -0.75) / scale_color).rgb +

				texture2D(bitmap, uv_color + vec2(-0.75, -0.25) / scale_color).rgb * 2.0 +
				texture2D(bitmap, uv_color + vec2(-0.25, -0.25) / scale_color).rgb * 4.0 +
				texture2D(bitmap, uv_color + vec2(0.25, -0.25) / scale_color).rgb * 4.0 +
				texture2D(bitmap, uv_color + vec2(0.75, -0.25) / scale_color).rgb * 2.0 +

				texture2D(bitmap, uv_color + vec2(-0.75, 0.25) / scale_color).rgb * 2.0 +
				texture2D(bitmap, uv_color + vec2(-0.25, 0.25) / scale_color).rgb * 4.0 +
				texture2D(bitmap, uv_color + vec2(0.25, 0.25) / scale_color).rgb * 4.0 +
				texture2D(bitmap, uv_color + vec2(0.75, 0.25) / scale_color).rgb * 2.0 +

				texture2D(bitmap, uv_color + vec2(-0.75, 0.75) / scale_color).rgb +
				texture2D(bitmap, uv_color + vec2(-0.25, 0.75) / scale_color).rgb * 2.0 +
				texture2D(bitmap, uv_color + vec2(0.25, 0.75) / scale_color).rgb * 2.0 +
				texture2D(bitmap, uv_color + vec2(0.75, 0.75) / scale_color).rgb
			) / 36.0;

		float color_y = dot(color_l.rgb, vec3(0.299, 0.587, 0.114));
		float color_u = dot(color, vec3(-0.14713, -0.28886, 0.436));
		float color_v = dot(color, vec3(0.615, -0.51499, -0.10001));

		gl_FragColor = vec4(color_y, color_u, color_v, color_l.a);
		gl_FragColor.gb += 0.5;
	}
}