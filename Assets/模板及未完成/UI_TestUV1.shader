Shader "Hidden/TestUV1"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Detail ("Detail", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_Ext("Ext",Vector)=(100,100,0,0)
		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}
	SubShader
	{
	    Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

		Stencil
        {
            Ref 0
            Comp Equal
            Pass keep
            ReadMask 255
            WriteMask 255
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RBG

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float4 color:COLOR;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 color:COLOR;
				float4 vertex : SV_POSITION;
				float2 canvasPos : TEXCOORD1;
				float4 worldPosition : TEXCOORD2;
			};
			fixed4 _Color;
			sampler2D _Detail;
			float4 _DetailTex_ST;
            float4 _DetailTex_TexelSize;
			v2f vert (appdata v)
			{
				v2f o;
				o.worldPosition = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.canvasPos = TRANSFORM_TEX(v.uv1 * _DetailTex_TexelSize.xy, _DetailTex);
				o.color = v.color * _Color;
				return o;
			}
			
			sampler2D _MainTex;
			float4 _Ext;
			fixed4 _TextureSampleAdd;
            float4 _ClipRect;
			fixed4 frag (v2f i) : SV_Target
			{
				//i.canvasPos.x/=_Ext.x;
				//i.canvasPos.y/=_Ext.y;
				fixed4 col = (tex2D(_MainTex, i.uv)+ _TextureSampleAdd)*i.color;
				fixed4	detail = tex2D(_Detail, i.canvasPos);
				col.rgb = lerp(col.rgb, col.rgb * detail.rgb, detail.a *0.2);

				#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

				return col;
			}
			ENDCG
		}
	}
}
