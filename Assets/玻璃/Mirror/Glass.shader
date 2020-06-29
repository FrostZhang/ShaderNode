Shader"Cus/Glass"
{
	Properties
	{
		_Color("Color", color) = (1, 1, 1, 1)
		_SpecColor("SpecularColor", color) = (1, 1, 1, 1)
		_Fresnel("Fresnel", Range(0, 1)) = 0.5
		_Smoothness("Smoothness", Range(0.05, 1)) = 0.5
		_MainTex("Texture", 2D) = "white"{}
		_NormalTex("Normal", 2D) = "bump"{}
		_Reflect("Reflect", cube) = ""{}
	}

	SubShader
	{
		Tags{"RenderType" = "Transparent" "Queue" = "Transparent"}

		Pass
		{
				Zwrite Off
				Blend SrcAlpha OneMinusSrcAlpha
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include"UnityCG.cginc"  

			struct appdata
			{
				float4 vertex: POSITION;
				float2 uv:TEXCOORD0;
				float3 normal:NORMAL;
			};
			struct v2f
			{
				float4 vertex: SV_POSITION;
				UNITY_FOG_COORDS(0)
				float2 uv[2]:TEXCOORD1;
				float3 normal:TEXCOORD3;
				float4 wPos:TEXCOORD4;
			};
				fixed4 _Color;
				fixed4 _SpecColor;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _NormalTex;
				float4 _NormalTex_ST;
				float _Fresnel;
				samplerCUBE _Reflect;
				float _Smoothness;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv[0] = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv[1] = TRANSFORM_TEX(v.uv, _NormalTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}
			fixed4 frag(v2f i) :SV_Target
			{
				float4 tex = tex2D(_MainTex, i.uv[0]);
				float3 nor = UnpackNormal(tex2D(_NormalTex, i.uv[1]));
				nor = normalize(i.normal + nor.xxy);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.wPos);
				float3 lightDir = normalize(UnityWorldSpaceLightDir(i.wPos));
				float spec = max(0, dot(nor, normalize(viewDir + lightDir)));
				spec = pow(spec, _Smoothness*_Smoothness * 200);
				spec *= tex.a;
				float rim = 1 - pow(max(0, dot(nor, viewDir)), _Fresnel * 6);
				rim *= tex.a;
				fixed4 refl = texCUBE(_Reflect, -reflect(viewDir, nor));
				fixed4 col = tex * _Color;
				col.rgb += _SpecColor * spec;
				col.rgb += rim * refl.rgb;
				col.a = max(rim, max(spec, col.a));
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
				ENDCG
		}
	}
}