Shader "Customized /spotlight"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
	}
		SubShader
		{
			Tags{
					"RenderType" = "Opaque" /*"Transparent" "TransparentCutout" "Background" "Overlay"*/
					"Queue" = "Transparent-10"
				}
			Cull Off /* Front Back  ZWrite Off ZTest Always  Off LEqual */ZTest Always
			/* GrabPass {"_Mygrab"} */
			Pass
			{
			//Tags{"LightMode" = "ForwardBase" /* "ForwardAdd" "Vertex" "VertexLit" "ShadowCaster" "ShadowCollector"*/}
			//AlphaTest Off /*Less L/G/Not Equal[0.2] Greater[0.5] Never */
			Blend  SrcAlpha One
			ColorMask RBG
			Offset 1,1 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 objPos :TEXCOORD1;
				float4 projpos :TEXCOORD2;
				float4 litPos :TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			float4 litPos;

			v2f vert(appdata v)
			{
				v2f o;
				//float3 lightDir = ObjSpaceLightDir(v.vertex);
				o.litPos = float4(litPos.x, litPos.y, litPos.z, litPos.w);
				float factor = dot(normalize(litPos), v.normal);
				float exfactor = step(factor, 0);

				v.vertex.xyz += v.normal*0.03;
				v.vertex.xyz -= litPos * (exfactor * 30);
				o.objPos = v.vertex.xyz / v.vertex.w;

				v.vertex.xy *=(distance(o.litPos, o.objPos)+0.2) * (exfactor * 0.42);
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = v.uv;
				return o;
			}
			sampler2D _MainTex;
			fixed4 _Color;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color ;
				float tol = distance(i.litPos, i.objPos);
				float dis = tol - 0.2;
				float att = saturate(1 - dis / 256);
				col.a = pow(att, 35);
				return col;
			}
			ENDCG
		}
	}
}
