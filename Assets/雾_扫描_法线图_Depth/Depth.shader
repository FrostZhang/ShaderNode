Shader "Unlit/Depth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FogHigh("FogHigh",float)=0.01
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		ZWrite On ZTest LEqual
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float3 frustumDir  : TEXCOORD1;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			sampler2D _CameraDepthNormalsTexture;
			float4x4 _CamToWorld;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = v.uv;
				#if UNITY_UV_STARTS_AT_TOP
					if(_MainTex_TexelSize.y < 0)
						o.uv.w = 1 - o.uv.w;
				#endif
				int ix = (int)o.uv.z;
				int iy = (int)o.uv.w;
				o.frustumDir = ix + 2 * iy;

				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			float _FogHigh;
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv.xy);
				//SAMPLE_DEPTH_TEXTURE = tex2D(_CameraDepthTexture , i.uv).r
				fixed dep = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture , i.uv);
				dep = Linear01Depth(dep);
				
				//输出法线图  一定要配合摄像机  ca.depthTextureMode = DepthTextureMode.DepthNormals;  
				//fixed3 enc = tex2D(_CameraDepthNormalsTexture, i.uv);
				//fixed3 normal = DecodeViewNormalStereo(fixed4(enc,1.));

				//half3 normal;  
				//float depth; 
				//DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal); 
				//// _CamToWorld 是 ca.cameraToWorldMatrix 代码传入
				//normal = mul( (float3x3)_CamToWorld, normal);  

				////全局雾
				//float fogDensity = saturate(dep * 1.8);
				//fixed4 finalColor = lerp(col, fixed4(1,0,0,1), fogDensity);

				//扫描仪
				float v = saturate(abs(frac(_Time.x) - dep) / _FogHigh);
				col = lerp(fixed4(1,0,0,1),col,v);
				return col;

				//垂直雾
				float linearEyeDepth =  LinearEyeDepth(dep);
				 float3 worldPos = _WorldSpaceCameraPos.xyz + i.frustumDir * linearEyeDepth;
				 float fogDensity = (worldPos.y - 0) / (_FogHigh - 0);
				 fogDensity = saturate(fogDensity * .25);
				 col = lerp(fixed4(1,.0,.0,1), col, fogDensity);
				 //apply fog
				UNITY_APPLY_FOG(i.fogCoord, finalColor);
				return col;
			}
			ENDCG
		}
	}

}
