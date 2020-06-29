shader "Scene/Alpha Blend " {
	Properties{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "white" {}
	_AlphaScale("Alpha Scale", Range(0, 1)) = 1
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5

		_Metallic("_Metallic",Range(0,1)) = 0
		_Smoothness("Smoothness",Range(0,1)) = 0
	}
		SubShader{
		Tags {"Queue" = "Transparent"/* "IgnoreProjector" = "True"*/ "RenderType" = "Transparent"}
		//"RenderType"="TransparentCutout"            //第一个Pass，关闭深度写入，处理AlphaTest部分       
		Pass {
		Tags { "LightMode" = "ForwardBase" }
		Cull off
		ZWrite On
		ZTest On           
		Blend SrcAlpha OneMinusSrcAlpha
		CGPROGRAM
		#pragma multi_compile_fwdbase      
		#pragma vertex vert           
		#pragma fragment frag           
		#include"UnityStandardUtils.cginc"
				#include"AutoLight.cginc"
				#include "UnityCG.cginc"
				#include "UnityPBSLighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;
			float _Cutoff;
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				float lengthInCamera : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				float4 wpos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.lengthInCamera = length(_WorldSpaceCameraPos - wpos.xyz);
				// Pass shadow coordinates to pixel shader         
				TRANSFER_SHADOW(o);
				return o;
			}

			float _Metallic;
			float _Smoothness;
			fixed3 _DiffuseColor;

			fixed4 frag(v2f i) : SV_Target {

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);
				clip(texColor.a - _Cutoff);
				fixed3 albedo = texColor.rgb * _Color.rgb;
				//fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				// UNITY_LIGHT_ATTENUATION not only compute attenuation, but also shadow infos     
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);


				half3 specColor;
				half oneMinusReflectivity;
				albedo = DiffuseAndSpecularFromMetallic(albedo, _Metallic, specColor, oneMinusReflectivity);

				UnityLight DirectLight;
				DirectLight.dir = worldLightDir;
				DirectLight.color = _LightColor0.xyz;
				DirectLight.ndotl = DotClamped(worldNormal, worldLightDir);

				UnityIndirect InDirectLight;
				InDirectLight.diffuse = 1;
				InDirectLight.specular = 0.2;

				texColor = UNITY_BRDF_PBS(albedo, specColor, oneMinusReflectivity,
					_Smoothness, worldNormal, worldViewDir,
					DirectLight, InDirectLight);


				float Start = 1.5;//设定开始值         
				float End = 0.4;//设定结束值                   
				texColor.a = saturate((Start - i.lengthInCamera) / (End - Start));
				//return fixed4(ambient + diffuse * atten, texColor.a * _AlphaScale);
				return texColor;
			}
			ENDCG
		}
	}
		FallBack "Diffuse"
}