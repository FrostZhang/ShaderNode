Shader "Hidden/RainDepth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Rain ("Texture", 2D) = "white" {}
		_RainColor ("rain Color", color) = (1,0,0,1)
		_Rainscale("scale",Range(0,1))=1
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
			#include "Thrid/FishManShaderTutorial/Shaders/ShaderLibs/Noise.cginc"
			 
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
			sampler2D _CameraDepthTexture;
			sampler2D _CameraDepthNormalsTexture;
			float4x4 _CamToWorld;
			sampler2D _Rain;
			fixed4 _RainColor;
			float _Rainscale;

			float3 DrawRainNoise(fixed2 uv)
			{
				float DF = 0.;
				float a = 0.;
				fixed2 vel = fixed2(0,_Time.x*.1);
				DF += RainNoise(uv+vel)*.25+.25;
				a = RainNoise(uv*fixed2(cos( _Time.x * .1),sin( _Time.x * .1))*0.1)*3.1415;

				vel = fixed2(cos(a),sin(a));
				DF += RainNoise(uv+vel)*.25+.25;
				return fixed( smoothstep(.7,.75,frac(DF)) );
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				
				half3 normal;  
				float depth; 
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal); 
				// _CamToWorld 是 ca.cameraToWorldMatrix 代码传入
				normal = mul( (float3x3)_CamToWorld, normal);  

				//将法线 红x 绿y 作为上色的条件
				half snowAmount =max( normal.g,normal.r);  
				snowAmount = saturate(snowAmount * _Rainscale);  

				float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);  
				//VPOS 视口坐标
				float3 vpos = float3( (i.uv * 2 - 1) / p11_22, -1) * depth;  
				//wpos 通过视口与摄像机  可以得到其世界坐标
				float3 wpos = mul(_CamToWorld,fixed4(vpos,1));  
				wpos  *=  _ProjectionParams.z * _Rainscale;  
				
				//half3 snowColor = tex2D(_Rain, wpos.xz)* _RainColor;
				half3 snowColor = DrawRainNoise(wpos.xz)* _RainColor *normal.g;  
				snowColor += DrawRainNoise(wpos.yz)* _RainColor*normal.r ;  
				return lerp(col, half4 (snowColor,_RainColor.a),snowAmount);  
				//return col +fixed4( snowColor,_RainColor.a)*snowAmount;
				//return half4(normal, 1);  

				//col.rgb = 1 - col.rgb;
				//return col;
			}
			ENDCG
		}
	}
}
