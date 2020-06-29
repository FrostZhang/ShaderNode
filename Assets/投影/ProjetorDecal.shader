Shader "Cus/ProjectorDecal" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_ShadowTex("Cookie", 2D) = "" {}
		_FalloffTex("FallOff", 2D) = "" {}

		_H("H min", float) = 0
		_L("L", Range(0, 1)) = 1
		_V("V",Range(0, 1)) = 1
		_Step("Step",Range(0, 8))=1
	}

		Subshader{
			Tags {"Queue" = "Transparent"}
			Pass {
				ZWrite Off
				ColorMask RGB
				Blend SrcAlpha OneMinusSrcAlpha
				Offset -1, -1

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "UnityCG.cginc"

				struct v2f {
					float4 uvShadow : TEXCOORD0;
					float4 uvFalloff : TEXCOORD1;
					UNITY_FOG_COORDS(2)
					float4 pos : SV_POSITION;
				};

				float4x4 unity_Projector;
				float4x4 unity_ProjectorClip;

				v2f vert(float4 vertex : POSITION)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(vertex);
					o.uvShadow = mul(unity_Projector, vertex);
					//o.uvFalloff = mul(unity_ProjectorClip, vertex);
					UNITY_TRANSFER_FOG(o,o.pos);
					return o;
				}

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

				fixed4 _Color;
				sampler2D _ShadowTex;
				sampler2D _FalloffTex;
				float _L;
				float _H;
				float _V;
				float _Step;
				fixed4 frag(v2f i) : SV_Target
				{
					float4 uv = i.uvShadow;
					fixed x = uv.x / uv.w;
					fixed y = uv.y / uv.w;
					fixed4 texS = fixed4(0,0,0,0);
					if (x<0.0001 || x>0.9999 || y<0.0001 || y>0.9999)
					{

					}
					else
					{
						texS = tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow));
						texS *= _Color;
						texS.a *= (uv.y / uv.w);
						
						float h = 0;
						float hm = uv.w - uv.z;
						if (hm <_H)
						{
							h = hm / _H;
							h = pow(h, _Step) * 240 + 115 ;
						}
						else
						{
							h = 355.99;
						}
						//115 到 355.99
						texS.rbg = HSVConvertToRGB(float3(h,_L, _V)) ;
					}
					//fixed4 texF = tex2Dproj (_FalloffTex, UNITY_PROJ_COORD(i.uvFalloff));
					//fixed4 res = texS * texF.a;

					UNITY_APPLY_FOG_COLOR(i.fogCoord, res, fixed4(1,1,1,1));
					return texS;
				}
				ENDCG
			}
	}

		FallBack "DIFFUSE"
}
