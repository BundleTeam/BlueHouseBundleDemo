package funkin.fx.shaders;

import funkin.fx.shaders.shadertoy.FlxShaderToyHack;

class GaussianBlur extends FlxShaderToyHack
{
	// see https://www.shadertoy.com/view/ltScRG
	public function new()
	{
		super('// 16x acceleration of https://www.shadertoy.com/view/4tSyzy
        // by applying gaussian at intermediate MIPmap level.
        #extension GL_EXT_gpu_shader4 : enable
        const int samples = 35,
                  LOD = 2,         // gaussian done on MIPmap at scale LOD
                  sLOD = 1 << LOD; // tile size = 2^LOD
        const float sigma = float(samples) * .25;
        
        float gaussian(vec2 i) {
            return exp( -.5* dot(i/=sigma,i) ) / ( 6.28 * sigma*sigma );
        }
        
        vec4 blur(sampler2D sp, vec2 U, vec2 scale) {
            vec4 O = vec4(0);  
            int s = samples/sLOD;
            
            for ( int i = 0; i < s*s; i++ ) {
                vec2 d = vec2(i%s, i/s)*float(sLOD) - float(samples)/2.;
                O += gaussian(d) * textureLod( sp, U + scale * d , float(LOD) );
            }
            
            return O / O.a;
        }
        
        void mainImage(out vec4 O, vec2 U) {
            O = blur( bitmap, U/iResolution.xy, .5/iResolution.xy );
        }');

	}
}
