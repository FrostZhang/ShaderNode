Shader "Hidden/RoY"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_RotarionSpeed("RotarionSpeed", float) = 1
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#define S45 .707106781187
			#define C45 .707106781187
			#define Rot45 float2x2(C45, -S45, S45, C45)

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
			float _RotarionSpeed;
			float4 DoRotation(float4 vertex)
			{
				float rotation = _RotarionSpeed * _Time.y;
				float s, c;
				sincos(radians(rotation), s, c);
				////X轴旋转45
				//vertex.xyz = float3(vertex.x, vertex.y*c1 - vertex.z	*s1, vertex.y*s1 + vertex.z	*c1);
				////Z轴旋转45
				//vertex.xyz = float3(vertex.x*c1 - vertex.y*s1, vertex.x*s1 + vertex.y	*c1, vertex.z);
				////Y轴旋转随时间
				//vertex.xyz = float3( vertex.x*c - vertex.z	*s, vertex.y,vertex.x*s + vertex.z*c);
				vertex.yz = mul(vertex.yz, Rot45);
				vertex.xy = mul(vertex.xy, Rot45);
				vertex.xz = mul(vertex.xz, float2x2(c, -s, s, c));
				return vertex;
			}

			v2f vert (appdata v)
			{
				v2f o;
				v.vertex = DoRotation(v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
			FallBack "Legacy Shaders/Bumped Diffuse"
}
