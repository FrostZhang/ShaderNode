
Shader "Cus/Catoon"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RampThreshold("RampThreshold",float )=0.5
		_RampSmooth("RampSmooth",float )=0.2
		_SColor("SColor",Color)=(1,1,1,1)
		_HColor("HColor",Color)=(1,1,1,1)
		_Gloss("Gloss",float )= 32
		_ToonStep("ToonStep",float )= 0.5
		_ToonEff("ToonEff",float )= 0.5
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
			Cull Front
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 catooncolor:TEXCOORD1;
				float3 specular:TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _RampThreshold;
			float _RampSmooth;
			fixed4 _SColor;
			fixed4 _HColor;
			float _Gloss;
			float _ToonStep;
			float _ToonEff;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			    float3 lightdir =normalize( ObjSpaceLightDir(v.vertex));
				float3 nor=normalize( v.normal);
				float ndl = saturate(dot(nor,lightdir));
				ndl=(ndl+1)/2;
				float diff = smoothstep(_RampThreshold - _RampSmooth * 0.5, _RampThreshold + _RampSmooth * 0.5, ndl);
				float toon = floor(diff *  _ToonStep) /  _ToonStep;  //离散
				diff = lerp(diff,toon,_ToonEff);
				o.catooncolor = lerp(_SColor.rgb, _HColor.rgb, diff);
				
				//float3 viewdir = normalize( _WorldSpaceCameraPos.xyz-mul(unity_ObjectToWorld,v.vertex));

				float3 viewdir =normalize( ObjSpaceViewDir(v.vertex));
			    fixed3 halfdir = normalize(lightdir + viewdir);
				float ndh = saturate(dot(ndl,halfdir));
				float spec = pow(ndh,_Gloss);
				float spectoon = floor(spec*2)/2;	//离散高光
				o.specular = lerp(spec,spectoon,_ToonStep) ;

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}


			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rbg*= _LightColor0.xyz*LIGHT_ATTENUATION(i)* (i.specular+i.catooncolor);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
