// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

shader "Custom/EdgeCheck" {
	Properties{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_EdgeOnly("Edge Only",Range(0,1)) = 0.5
		_EdgeColor("Edge Color",Color) = (1,1,1,1)
		_BackgroundColor("BackGround Color",Color) = (1,1,1,1)
	}

		CGINCLUDE

#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		fixed _EdgeOnly;
		fixed3 _EdgeColor;
		fixed3 _BackgroundColor;

		struct a2v
		{
			float4 vertex:POSITION;
			float2 texcoord:TEXCOORD0;
		};

		struct v2f
		{
			float4 pos:SV_POSITION;
			half2 uv[9]:TEXCOORD0;
		};
		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			half2 uv = v.texcoord;
			o.uv[0] = uv + half2(-1, -1) * _MainTex_TexelSize;
			o.uv[1] = uv + half2(0, -1) * _MainTex_TexelSize;
			o.uv[2] = uv + half2(1, -1) * _MainTex_TexelSize;
			o.uv[3] = uv + half2(-1, 0) * _MainTex_TexelSize;
			o.uv[4] = uv + half2(0, 0) * _MainTex_TexelSize;
			o.uv[5] = uv + half2(1, 0) * _MainTex_TexelSize;
			o.uv[6] = uv + half2(-1, 1) * _MainTex_TexelSize;
			o.uv[7] = uv + half2(0, 1) * _MainTex_TexelSize;
			o.uv[8] = uv + half2(1, 1) * _MainTex_TexelSize;
			return o;
		}
		//计算各个颜色通道分量对亮度贡献
		//弃用  使用unity灰度计算.dot(color *  graycolor)
		fixed luminance(fixed3 color)
		{
			return color.r * 0.212 + color.g * 0.715 + color.b * 0.072;
		}

		half sobel(v2f i)
		{
			const half Gx[9] =
			{
				-1,-2,-1,
				0,0,0,
				1,2,1
			};
			const half Gy[9] =
			{
				1,0,-1,
				2,0,-2,
				1,0,1
			};
			half edgeX;
			half edgeY;
			for (int it = 0; it < 9; it++)
			{
				half lum = Luminance(tex2D(_MainTex, i.uv[it]).rgb);
				edgeX += lum * Gx[it];
				edgeY += lum * Gy[it];
			}
			return 1 - abs(edgeX) - abs(edgeY);
		}

		fixed4 frag(v2f i) :SV_Target
		{
			//G值越大表示梯度越小
			half G = sobel(i);
			fixed3 withEdgeColor = lerp(_EdgeColor,tex2D(_MainTex,i.uv[4]).rgb,G);
			fixed3 edgeOnlyColor = lerp(_EdgeColor,_BackgroundColor,G);
			return fixed4(lerp(withEdgeColor,edgeOnlyColor,_EdgeOnly),1.0);
		}
			ENDCG

			SubShader {
			Tags{ "RenderType" = "Opaque" }
				LOD 200
				Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				ENDCG
			}
		}
		FallBack "Diffuse"
}