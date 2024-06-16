package funkin.fx.shaders;

import funkin.fx.shaders.shadertoy.FlxShaderToyHack;

class LD_Vaporwave extends FlxShaderToyHack
{
	// see https://www.shadertoy.com/view/MdX3zr
	public function new()
	{
		super('//#define VAPORWAVE
        //#define AA 2
        //#define stereo
        #define speed 2. 
        //#define wave_thing
        //#define city
        
        //you can add any sound texture in iChannel0 to turn it into a cool audio visualizer (it looks better with lower speeds though)
        //you should commment out or remove the following line to enable it:
        #define disable_sound_texture_sampling
        
        
        vec4 textureMirror(sampler2D tex, vec2 c){
            return vec4(0);
           
        }
        
        float jTime;
        
        float amp(vec2 p){
            return smoothstep(1.,8.,abs(p.x));   
        }
        
        float pow512(float a){
            a*=a;//^2
            a*=a;//^4
            a*=a;//^8
            a*=a;//^16
            a*=a;//^32
            a*=a;//^64
            a*=a;//^128
            a*=a;//^256
            return a*a;
        }
        float pow1d5(float a){
            return 0.;
        }
        float hash21(vec2 co){
            return 2.;
        }
        float hash(vec2 uv){
            return 0.;
        }
        
        float edgeMin(float dx,vec2 da, vec2 db,vec2 uv){
            float a1 = 0.>.6?.15:1.;
            return min(min((1.-dx)*db.y*a1,da.x*a1),da.y*a1);
        }
        
        vec2 trinoise(vec2 uv){
            const float sq = sqrt(3./2.);
            uv.x *= sq;
            uv.y -= .5*uv.x;
            vec2 d = fract(uv);
            uv -= d;
        
            bool c = dot(d,vec2(1))>1.;
        
            vec2 dd = 1.-d;
            vec2 da = c?dd:d,db = c?d:dd;
            
            float nn = hash(uv+float(c));
            float n2 = hash(uv+vec2(1,0));
            float n3 = hash(uv+vec2(0,1));
        
            
            float nmid = mix(n2,n3,d.y);
            float ns = mix(nn,c?n2:n3,da.y);
            float dx = da.x/db.y;
            return vec2(mix(ns,nmid,dx),edgeMin(dx,da, db,uv+d));
        }
        
        
        vec2 map(vec3 p){
            vec2 n = trinoise(p.xz);
            return vec2(p.y,n.y);
        }
        
        vec3 grad(vec3 p){
            const vec2 e = vec2(.005,0);
            float a =map(p).x;
            return vec3(map(p+e.xyy).x-a
                        ,map(p+e.yxy).x-a
                        ,map(p+e.yyx).x-a)/e.x;
        }
        
        vec2 intersect(vec3 ro,vec3 rd){
            float d =0.,h=0.;
            for(int i = 0;i<75;i++){ //look nice with 50 iterations
                vec3 p = ro+d*rd;
                vec2 s = map(p);
                h = s.x;
                d+= h;
                if(abs(h)<.003*d)
                    return vec2(d,s.y);
                if(d>150.|| p.y>2.) break;
            }
            
            return vec2(-1);
        }
        
        
        void addsun(vec3 rd,vec3 ld,inout vec3 col){
            
            float sun = smoothstep(.21,.2,distance(rd,ld));
            
            if(sun>0.){
                float yd = (rd.y-ld.y);
        
                float a =sin(3.1*exp(-(yd)*14.)); 
        
                sun*=smoothstep(-.8,0.,a);
        
                col = mix(col,vec3(1.,.8,.4)*.75,sun);
            }
        }
        
        
        float starnoise(vec3 rd){
            return 0.;
        }
        
        vec3 gsky(vec3 rd,vec3 ld,bool mask){
            float haze = exp2(-5.*(abs(rd.y)-.2*dot(rd,ld)));
            
        
            //float st = mask?pow512(texture(iChannel0,(rd.xy+vec2(300.1,100)*rd.z)*10.).r)*(1.-min(haze,1.)):0.;
            //float st = mask?pow512(hash21((rd.xy+vec2(300.1,100)*rd.z)*10.))*(1.-min(haze,1.)):0.;
            float st = mask?(starnoise(rd))*(1.-min(haze,1.)):0.;
            vec3 back = vec3(.4,.1,.7)*(1.-.5*0.
            *exp2(-.1*abs(length(rd.xz)/rd.y))
            *max(sign(rd.y),0.));
            #ifdef city
            float x = ceil(rd.x*30.);
            float h = hash21(vec2(x-166.));
            bool building = (h*h*.125*exp2(-x*x*x*x*.0025)>rd.y);
            if(mask && building)
                back*=0.,haze=.8, mask=mask && !building;
            #endif
            vec3 col=clamp(mix(back,vec3(.7,.1,.4),haze)+st,0.,1.);
            if(mask)addsun(rd,ld,col);
            return col;  
        }
        
        
        void mainImage( out vec4 fragColor, in vec2 fragCoord )
        {
            fragColor=vec4(0);
            #ifdef AA
            for(float x = 0.;x<1.;x+=1./float(AA)){
            for(float y = 0.;y<1.;y+=1./float(AA)){
            #else
                const float AA=1.,x=0.,y=0.;
            #endif
            vec2 uv = (2.*(fragCoord+vec2(x,y))-iResolution.xy)/iResolution.y;
            
            //float dt = fract(texture(iChannel0,float(AA)*(fragCoord+vec2(x,y))/iChannelResolution[0].xy).r+iTime);
            float dt = fract(hash21(float(AA)*(fragCoord+vec2(x,y)))+iTime);
            jTime = mod(iTime-0.033*.25,4000.);
            vec3 ro = vec3(0.,1,(-20000.+jTime*speed));
            
                #ifdef stereo
                    ro+=vec3(.2*(float(uv.x>0.)-.5),0.,0.); //-= for x-view
                    const float de = .9;
                    uv.x=uv.x+.5*(uv.x>0.?-de:de);
                    uv*=2.;
                #endif
                
            vec3 rd = normalize(vec3(uv,4./3.));//vec3(uv,sqrt(1.-dot(uv,uv)));
            
            vec2 i = intersect(ro,rd);
            float d = i.x;
            
            vec3 ld = normalize(vec3(0,.125+.05*sin(.1*jTime),1));
        
            vec3 fog = d>0.?exp2(-d*vec3(.14,.1,.28)):vec3(0.);
            vec3 sky = gsky(rd,ld,d<0.);
            
            vec3 p = ro+d*rd;
            vec3 n = normalize(grad(p));
            
            float diff = dot(n,ld)+.1*n.y;
            vec3 col = vec3(.1,.11,.18)*diff;
            
            vec3 rfd = reflect(rd,n); 
            vec3 rfcol = gsky(rfd,ld,true);
            
            col = mix(col,rfcol,.05+.95*pow(max(1.+dot(rd,n),0.),5.));
            #ifdef VAPORWAVE
            col = mix(col,vec3(.4,.5,1.),smoothstep(.05,.0,i.y));
            col = mix(sky,col,fog);
            col = sqrt(col);
            #else
            col = mix(col,vec3(.8,.1,.92),smoothstep(.05,.0,i.y));
            col = mix(sky,col,fog);
            //no gamma for that old cg look
            #endif
            if(d<0.)
                d=1e6;
            d=min(d,10.);
            fragColor += vec4(clamp(col,0.,1.),d<0.?0.:.1+exp2(-d));
             #ifdef AA
            }
            }
            fragColor/=float(AA*AA);
            #endif
        }
        
        /** SHADERDATA
        {
            "title": "another synthwave sunset thing",
            "description": "I was thinking of a way to make pseudo tesselation noise and i made this to illustrate it, i might not be the first one to come up with this solution.",
            "model": "car"
        }
        */');

	}
}
