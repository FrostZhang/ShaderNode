Shader "Unlit/OutLine"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("OutLine Color",COLOR) =(1,0,0,1)
		_Outline("OutLine Width",float) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		FOG{Mode off}

		Pass
		{

		}

		Pass
		{
			Cull Front
			ZWrite On 
			Offset -1,-1
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal :NORMAL ;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float _Outline;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 dir = normalize(v.vertex);
				float3 dir2 = v.normal;
				dir = lerp(dir,dir2,dot(dir,dir2));
				dir  = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV, dir));
				float2 offset = TransformViewToProjection(dir.xy);
				o.vertex.xy += o.vertex.z * normalize( offset) * _Outline;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				clip(_Outline);
				return _Color;
			}
			ENDCG
		}
	}
}
