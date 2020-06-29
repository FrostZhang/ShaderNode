Shader "Hidden/HSV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		_H("H",float) = 220
		_L("L",float) = 220
		_V("V",float) = 220
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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

			float3 HSVConvertToRGB(float3 hsv)
			{
				float R, G, B;
				//float3 rgb;
				if (hsv.y == 0)
				{
					R = G = B = hsv.z;
				}
				else
				{
					hsv.x = hsv.x / 60.0;
					int i = abs((int)hsv.x);
					float f = hsv.x - (float)i;
					float a = hsv.z * (1 - hsv.y);
					float b = hsv.z * (1 - hsv.y * f);
					float c = hsv.z * (1 - hsv.y * (1 - f));
					switch (i)
					{
					case 0: R = hsv.z; G = c; B = a;
						break;
					case 1: R = b; G = hsv.z; B = a;
						break;
					case 2: R = a; G = hsv.z; B = c;
						break;
					case 3: R = a; G = b; B = hsv.z;
						break;
					case 4: R = c; G = a; B = hsv.z;
						break;
					default: R = hsv.z; G = a; B = b;
						break;
					}
				}
				return float3(R, G, B);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			float _H;
			float _L;
			float _V;
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // just invert the colors
                col.rgb = HSVConvertToRGB(float3(_H, _L, _V));
                return col;
            }
            ENDCG
        }
    }
}
