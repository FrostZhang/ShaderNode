Shader "Hidden/Dissolve"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_DissolveTex("DissolveTex", 2D) = "white" {}
		_Threshold("_Threshold", Range(0,1)) = 0.5
		_Edge("_Edge",Range(0,.2)) = .1
		_EdgeColor("_EdgeColor",Color) = (1,1,1,1)
	}
		SubShader
		{
			// No culling or depth
			Cull Back ZWrite On ZTest Always

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
					float2 uv2 : TEXCOORD1;
					float4 vertex : SV_POSITION;
				};
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _DissolveTex;
				float4 _DissolveTex_ST;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.uv2 = TRANSFORM_TEX(v.uv, _DissolveTex);
					return o;
				}
				float _Threshold;
				float _Edge;
				float4 _EdgeColor;
				fixed4 frag(v2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					float cutout = tex2D(_DissolveTex, i.uv2).r;
					clip(cutout - _Threshold);
					if (cutout > _Edge &&  cutout - _Threshold < _Edge)
					{
						return lerp(col, _EdgeColor, _Threshold);
					}
					//float4 final = lerp(_DissColor, _AddColor, clipAmount / _DizzSize) * 2;
					//col = col * final;
					return col;
				}
				ENDCG
			}
		}
}
