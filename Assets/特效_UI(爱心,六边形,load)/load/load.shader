Shader "Hidden/load"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
			void mainImage(out float4 fragColor, in float2 fragCoord)
			{
				float2 p = 2*(fragCoord-0.5);
				float tau = 3.1415926535*2.0;
				float a = atan(p.x/p.y);
				float r = length(p)*0.75;
				float2 uv = float2(a / tau, r);

				//get the color
				float xCol = (uv.x - (_Time.y / 3.0)) * 3.0;
				xCol = fmod(xCol, 3.0);
				float3 horColour = float3(0.25, 0.25, 0.25);

				if (xCol < 1.0) {

					horColour.r += 1.0 - xCol;
					horColour.g += xCol;
				}
				else if (xCol < 2) {

					xCol -= 1.0;
					horColour.g += 1.0 - xCol;
					horColour.b += xCol;
				}
				else {

					xCol -= 2.0;
					horColour.b += 1.0 - xCol;
					horColour.r += xCol;
				}

				// draw color beam
				uv = (2.0 * uv) - 1.0;
				float res = 10.0*tau*0.15 * clamp(floor(5.0 + 10.0*cos(_Time.y)), 0.0, 10.0);
				float beamWidth = (0.7 + 0.5*cos(uv.x)) * abs(1.0 / (30.0 * uv.y));
				float3 horBeam = float3(beamWidth, beamWidth, beamWidth);
				fragColor = float4(((horBeam)* horColour), beamWidth);
			}
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
				  fixed4 col;
				mainImage(col, i.uv);
				return col;
            }
            ENDCG
        }
    }
}
