Shader "Unlit/Snow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		XSPEED("XSPEED",float) = 1
		YSPEED("YSPEED",float) =1
		SIZE_RATE("SIZE_RATE", float) = 0.1
		LAYERS("LAYERS",float) = 10
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "ShaderLibs/Framework3D.cginc"
			#define ftime 0.02

			float4 _MainTex_ST;

			float XSPEED;
			float YSPEED;
			float SIZE_RATE;

			float3 SnowSingleLayer(float2 uv, float layer) {
				fixed3 acc = fixed3(0.0, 0.0, 0.0);//让雪花的大小变化
				uv = uv * (2.0 + layer);//透视视野变大效果
				float xOffset = uv.y * (((Hash11(layer) * 2 - 1.)*0.5 + 1.)*XSPEED);//增加x轴移动
				float yOffset = (YSPEED*_Time.y);//y轴下落过程
				uv += fixed2(xOffset, yOffset);
				float2 rgrid = Hash22(floor(uv) + (31.1759*layer));
				uv = frac(uv);
				uv -= (rgrid * 2 - 1.0) * 0.35;
				uv -= 0.5;
				float r = length(uv);
				float circleSize = 0.05*(1.0 + 0.3*sin(ftime*SIZE_RATE));//让大小变化点
				float val = smoothstep(circleSize, -circleSize, r);
				float3 col = float3(val, val, val)* rgrid.x;
				return col;
			}

			float3 SnowSingleLayer2(float3 ro, float3 rd, float layer) {
				fixed3 acc = fixed3(0.0, 0.0, 0.0);//让雪花的大小变化
				rd = ro.xyz + rd * (2.0 + layer);//透视视野变大效果
				float xOffset = rd.y * (((Hash11(layer) * 2 - 1.)*0.5 + 1.)*XSPEED);//增加x轴移动
				float yOffset = (YSPEED*_Time.y);//y轴下落过程
				rd += fixed3(xOffset, yOffset,0);
				float2 rgrid = Hash22(floor(rd) + (31.1759*layer));
				rd = frac(rd);
				rd.xy -= (rgrid * 2 - 1.0) * 0.35;
				rd -= 0.5;
				float r = length(rd);
				float circleSize = 0.05*(1.0 + 0.3*sin(ftime*SIZE_RATE));//让大小变化点
				float val = smoothstep(circleSize, -circleSize, r);
				float3 col = float3(val, val, val)* rgrid.x;
				return col;
			}


			float LAYERS;
			float4 ProcessRayMarch(float2 uv, float3 ro, float3 rd, inout float sceneDep, float4 sceneCol)
			{
				float3 acc = float3(0, 0, 0);
				for (fixed i = 0.; i < LAYERS; i++) {
					acc += SnowSingleLayer(uv, i);
				}
				sceneCol.rbg += acc;
				return sceneCol;
			}

			ENDCG
		}
	}
}
