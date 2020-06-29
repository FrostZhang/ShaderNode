Shader "Hidden/Ice"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Ice("Ice", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_Y("_Y", Range(-1.5,1)) = 0.5
	}
	SubShader
	{
		// No culling or depth
		//Cull Back ZWrite On ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float high : TEXCOORD1;
				float3 lightdir : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _BumpMap;
			float _Y;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.high= step(v.vertex.y, _Y);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _Ice;
			fixed4 frag (v2f i) : SV_Target
			{
				float4 col = tex2D(_MainTex, i.uv)*(1 - i.high);
				float4 col2 = tex2D(_Ice, i.uv + _Time.x*0.5)* i.high;
				col = col + col2;
				return col;
			}
			ENDCG
		}
	}
			FallBack "Legacy Shaders/Bumped Diffuse"
}
