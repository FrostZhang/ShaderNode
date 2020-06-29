Shader "Customized /reflect"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Fra("Fra",float) = 0.5
	}
		SubShader
		{
			Tags{
					"RenderType" = "Opaque" /*"Transparent" "TransparentCutout" "Background" "Overlay"*/
					"Queue" = "Transparent" /* "Geometry" "AlphaTest" "Transparent" "Overlay"*/
				}
			Cull Off 
		GrabPass {
			Name "_GrabTexture"
			Tags { "LightMode" = "Always" }
		}
			Pass
			{
			//Tags{"LightMode" = "ForwardBase" /* "ForwardAdd" "Vertex" "VertexLit" "ShadowCaster" "ShadowCollector"*/}
			//AlphaTest Off /*Less L/G/Not Equal[0.2] Greater[0.5] Never */
			//Blend One Zero /* SrcAlpha OneMinusSrcAlpha */
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 grappos:TEXCOORD1;
				float4 vertex : SV_POSITION;
			};
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.grappos = ComputeGrabScreenPos(v.vertex);
				//o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
				o.grappos.zw = o.vertex.zw;
				return o;
			}

			fixed4 _Color;
			float _Fra;
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				i.grappos.xy = _GrabTexture_TexelSize.xy * i.grappos.z + i.grappos.xy;
				half4 fra = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grappos));
				//fixed4 fra = tex2D(_GrabTexture, i.grappos.xy);
				return lerp(fra, col, _Fra);
			}
			ENDCG
		}
		}
}
