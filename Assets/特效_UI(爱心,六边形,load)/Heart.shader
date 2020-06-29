Shader "Hidden/Heart"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

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
			
			sampler2D _MainTex;

			float mod(float x, float y)
			{
				return x- y *floor(x/y);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 uv = (i.uv-0.5)*2;
				fixed3 bg = fixed3(1.0,0.8,0.7-0.07*uv.y)*(1.0-0.25*length(uv));

				// animate
				float tt = mod(_Time.y,1.5)/1.5;
				float ss = pow(tt,.2)*0.5 + 0.5;
				ss = 1.0 + ss*0.5*sin(tt*6.2831*3.0 + uv.y*0.5)*exp(-tt*4.0);
				uv *= fixed2(0.5,1.5) + ss*fixed2(0.5,-0.5);

				    // shape
				#if 0
					uv *= 0.8;
					uv.y = -0.1 - uv.y*1.2 + abs(uv.x)*(1.0-abs(uv.x));
					float r = length(uv);
					float d = 0.5;
				#else
					uv.y -= 0.25;
					float a = atan2(uv.x,uv.y)/3.141593;
					float r = length(uv);
					float h = abs(a);
					float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);
				#endif

					// color
					float s = 0.75 + 0.75*uv.x;
					s *= 1.0-0.4*r;
					s = 0.3 + 0.7*s;
					s *= 0.5+0.5*pow( 1.0-clamp(r/d, 0.0, 1.0 ), 0.1 );
					fixed3 hcol = fixed3(1.0,0.5*r,0.3)*s;
	
					fixed3 col = lerp( bg, hcol, smoothstep( -0.01, 0.01, d-r) );

				return fixed4( col,1);
			}
			ENDCG
		}
	}
}