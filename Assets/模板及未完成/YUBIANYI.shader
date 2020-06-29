Shader "Unlit/YUBIANYI"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[Toggle]_Toggle("Toggle",float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			//#pragma geometry geom	//DX10几何着色器  target 4.0
			//#pragma hull hull	//DX10壳着色器  target 5.0
			//#pragma domain domain	//DX10域着色器  target 5.0
			#pragma target 2.0	
			// #pragma only_renderers exclude_renderers 
			#pragma multi_compile ceshi_on ceshi_off
			#include "UnityCG.cginc"
			#define  UseceshiTogggle 0.5

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				#if defined( UseceshiTogggle)
				col.b = 0;
				#endif 
				col.b = UseceshiTogggle;

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
