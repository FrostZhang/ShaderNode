Shader "Customized /Fresnel"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Cube("Box",Cube) = ""{}
		_EtaRatio("EtaRatio",Range(0,1)) = 0.1
		_Fresnel("Fresnel ",Vector) = (1,1,5)
	}
	SubShader
	{
		Tags{
				"RenderType" = "Transparent" /*"Transparent" "TransparentCutout" "Background" "Overlay"*/
				"Queue" = "Transparent" /* "Geometry" "AlphaTest" "Transparent" "Overlay"*/
			}
		Cull Off /* Front Back */ ZWrite Off ZTest Always /* Off LEqual */
		/* GrabPass {"_Mygrab"} */
		Pass
		{
			//Tags{"LightMode" = "ForwardBase" /* "ForwardAdd" "Vertex" "VertexLit" "ShadowCaster" "ShadowCollector"*/}
			//AlphaTest Off /*Less L/G/Not Equal[0.2] Greater[0.5] Never */
			Blend One  OneMinusSrcAlpha 
			//ColorMask RBG
			//Offset -1,-1 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			/*# pragma target 3.0*/
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 refle : TEXCOORD1;
				float3 refre : TEXCOORD2;
				float3 fresnel : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			float _EtaRatio;
			float3 _Fresnel;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				fixed3 viewdir = WorldSpaceViewDir( v.vertex);
				float3 normal = UnityObjectToWorldNormal(v.normal);
				o.refle = reflect(viewdir, normal);
				o.refre = refract(viewdir, normal, _EtaRatio);
				o.fresnel = max(0, min(1, _Fresnel.x + _Fresnel.y*pow(min(0, 1 - dot(viewdir, normal)), _Fresnel.z)));
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			fixed4 _Color;
			samplerCUBE _Cube;
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;
			    fixed4 boxcol =	texCUBE(_Cube, i.refle);
				fixed4 boxcol2 = texCUBE(_Cube, i.refre);
				col.rbg *= lerp(boxcol, boxcol2, i.fresnel);
				return col;
			}
			ENDCG
		}
	}
}
