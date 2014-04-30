#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;
float h(float n){return fract(cos(n)*43758.5453);}

void main( void ) {
	vec2 q=-1.+2.*gl_FragCoord.xy/vec2(resolution.x,resolution.y);
	gl_FragColor = vec4(h(sin(q.y)+time/100000.));
}