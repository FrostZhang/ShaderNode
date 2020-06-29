Shader "Hidden/load2"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
	  Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" }
		Cull Off Lighting Off ZWrite On
		Blend  SrcAlpha OneMinusSrcAlpha

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
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			float2x2 rotate2d(float angle) {
				return float2x2(cos(angle), -sin(angle),
					sin(angle), cos(angle));
			}

			float variation(float2 v1, float2 v2, float strength, float speed) {
				return sin(
					dot(normalize(v1), normalize(v2)) * strength + _Time.y * speed
				) / 100.0;
			}

			float3 paintCircle(float2 uv, float2 center, float rad, float width) {

				float2 diff = center - uv;
				float len = length(diff);

				len += variation(diff, float2(0.0, 1.0), 5.0, 2.0);
				len -= variation(diff, float2(1.0, 0.0), 5.0, 2.0);

				float circle = smoothstep(rad - width, rad, len) - smoothstep(rad, rad + width, len);
				return float3(circle, circle, circle);
			}


			void mainImage(out float4 fragColor, in float2 fragCoord)
			{
				float2 uv = fragCoord;
				uv.x *= 1;
				//uv.x -= 0.5;

				float3 color;
				float radius = 0.35;
				float2 center = float2(0.5, 0.5);


				//paint color circle
				color = paintCircle(uv, center, radius, 0.1);

				//color with gradient
				float2 v = mul(rotate2d(_Time.y) , uv);
				color *= float3(v.x, v.y, 0.7 - v.y*v.x);

				//paint white circle
				color += paintCircle(uv, center, radius, 0.01);


				fragColor = float4(color, max(color.r,color.b));
			}

			sampler2D _MainTex;

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col;
				mainImage(col, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
