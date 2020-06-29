Shader "Hidden/CusMath"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite on ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			//#define USING_TEXLOD_NOISE 1
			#include "Thrid/FishManShaderTutorial/Shaders/ShaderLibs/Noise.cginc"

			#define DrawInGrid(uv,DRAW_FUNC)\
			{\
				float2 pFloor = floor(uv);\
				if(length(pFloor-float2(j,i))<0.1){\
					col = DRAW_FUNC(frac(uv)-0.5);\
				}\
				num = num + 1.000;\
				i=floor(num / gridSize); j=fmod(num,gridSize);\
			}\

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float3 DrawSmoothstep(float2 uv){
				uv+=0.5;
				float val = smoothstep(0.0,1.0,uv.x);
				val = step(abs(val-uv.y),0.01); 
				return float3(val,val,val);
			}
			float3 DrawCircle(float2 uv){
			    fixed len =	length(uv);
				fixed r = smoothstep(len-0.01,len+0.01,0.25);
				return fixed3 (r,r,r);
			}
			float3 DrawChessboard (float2 uv){
				uv = floor((uv-0.5)*5)/2;
				fixed c = frac(uv.x+uv.y);
				return fixed3 (c,c,c);
			}
			float3 DrawLine(float2 uv){
				fixed3 val ;
				const fixed3 wi = fixed3(1,1,1);
				fixed width  = 0.01;
				fixed _offset = uv.x - 0.25;
				float c = step(0,_offset)*(1-step(width,_offset));
				val = c*wi;
				 _offset = uv.x + 0.1;
				 c = step(0,_offset)*(1-step(width,_offset));
				val += c*wi;
				 _offset = uv.y + 0.3;
				 c = step(0,_offset)*(1-step(width,_offset));
				val += c*wi;
				return val;
			}
			float3 DrawYuanJiao(float2 uv)
			{
				float r = 0.15;
				fixed2 m = step(abs(uv),0.5-r);
				fixed len =length(fmod(uv,0.5-r)); 
				float c = smoothstep(len-0.01,len+0.01,r);
				return c*fixed3(1,1,1)+(m.x+m.y)*fixed3(0,1,0);
			}
			float3 DrawSines(float2 uv)
			{
				uv *=5;
				float c;
				float c2;
				uv.x -=_Time.y;
				sincos(uv.x,c,c2);
				c = step(abs(c-uv.y),0.02); 
				c2 = step(abs(c2-uv.y),0.02); 
				return fixed3(c,c,c)+fixed3(c2,c2,c2);
			}
			float3 DrawFlower(float2 uv){
				float deg = atan2(uv.y,uv.x) + _Time.y * -0.1;
				float len = length(uv)*3.0;
				float offs = abs(sin(deg*3.))*0.35;
				return smoothstep(1.+offs,1.+offs-0.05,len);
			}
			float3 DrawRainNoise(fixed2 uv)
			{
				uv *=2;
				float DF = 0.0;
				float a = 0.0;
				fixed2 vel = fixed2(0,-_Time.x);
				DF += RainNoise(uv+vel)*.25+.25;
				a = RainNoise(uv*fixed2(cos( _Time.y * 0.15),sin( _Time.y * 0.1))*0.1)*3.1415;

				vel = fixed2(cos(a),sin(a));
				DF += RainNoise(uv+vel)*.25+.25;
				return fixed( smoothstep(.7,.75,frac(DF)) );
			}

			sampler2D _MainTex;
			fixed4 frag (v2f input) : SV_Target
			{
				fixed3 col= fixed3(0,0,0);
				float num = 0.;
				float gridSize = 3.;
				float i =0.,j=0.;
				fixed2 uv = input.uv * gridSize ;
				fixed2 c =1/2.;

				DrawInGrid(uv,DrawSmoothstep);
				DrawInGrid(uv,DrawCircle);
				DrawInGrid(uv,DrawChessboard);
				DrawInGrid(uv,DrawLine);
				DrawInGrid(uv,DrawYuanJiao);
				DrawInGrid(uv,DrawSines);
				DrawInGrid(uv,DrawRainNoise);
				return fixed4( col,1.);
			}
			ENDCG
		}
	}
}
