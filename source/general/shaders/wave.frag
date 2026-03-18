#pragma header

uniform float wave; // 0 - 1
uniform vec3 size;  // [10, 0.8, 0.1]
uniform vec2 point; // [0.5, 0.5]

void main() {
	float currentTime = fract(wave);
	
	float ratio = openfl_TextureSize.y / openfl_TextureSize.x;
	vec2 aspectCorrection = vec2(1.0, ratio);
	
	vec2 texCoord = openfl_TextureCoordv;
	vec2 waveCentre = point * aspectCorrection;
	vec2 adjustedCoord = texCoord * aspectCorrection;
	
	float dist = distance(adjustedCoord, waveCentre);
	
	float minDist = currentTime - size.z;
	float maxDist = currentTime + size.z;
	
	if (dist >= minDist && dist <= maxDist) {
		float diff = dist - currentTime;
		float absDiff = abs(diff);
		
		float powDiff = pow(absDiff * size.x, size.y);
		float scaleDiff = 1.0 - powDiff;
		
		float diffTime = diff * scaleDiff;
		
		vec2 dirVec = normalize(texCoord - point);
		
		float timeDistFactor = currentTime * dist;
		float distortionFactor = diffTime / (timeDistFactor * 40.0 + 1e-5);
		texCoord += dirVec * distortionFactor;
		
		vec4 color = texture2D(bitmap, texCoord);
		
		float colorEnhance = scaleDiff / (timeDistFactor * 40.0 + 1e-5);
		gl_FragColor = color + color * colorEnhance;
	} else {
		gl_FragColor = texture2D(bitmap, texCoord);
	}
}