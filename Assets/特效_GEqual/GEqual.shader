Shader "Customized /GEqual"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_GColor("Color", Color) = (1,1,1,1)
		_Rim("Rim", float) = 0.5
	}
		SubShader
		{
			/* GrabPass {"_Mygrab"} */
			Tags{
					"RenderType" = "Geometry"
					"Queue" = "Geometry+100"
				}
			Pass
			{
				Cull Back /* Front Back */ ZWrite Off ZTest Greater
				//Tags{"LightMode" = "ForwardBase" /* "ForwardAdd" "Vertex" "VertexLit" "ShadowCaster" "ShadowCollector"*/}
				//AlphaTest Off /*Less L/G/Not Equal[0.2] Greater[0.5] Never */
				Blend SrcAlpha OneMinusSrcAlpha /* SrcAlpha OneMinusSrcAlpha */
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
				float3 worldnormal : TEXCOORD1;
				float3 viewdir : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				o.worldnormal = normalize(UnityObjectToWorldNormal(v.normal)) ;
				o.viewdir = normalize(WorldSpaceViewDir(v.vertex));
				
				return o;
			}

			sampler2D _MainTex;
			fixed4 _GColor;
			float _Rim;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _GColor;
				float rim = pow(1-abs(dot(i.viewdir,i.worldnormal)),_Rim); //GlowingEdges 边缘光
				col.a *= rim;
				return col;
			}
			ENDCG
			}

			Pass
			{
				Cull Back /* Front Back */ ZWrite On ZTest Less

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				/*# pragma target 3.0*/
				#include "UnityCG.cginc"

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

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;
			fixed4 _Color;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				return col;
			}
			ENDCG
			}
		}
}
