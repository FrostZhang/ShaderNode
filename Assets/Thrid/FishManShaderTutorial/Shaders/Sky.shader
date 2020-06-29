// create by JiepengTan 
// https://github.com/JiepengTan/FishManShaderTutorial
// 2018-04-13  email: jiepengtan@gmail.com
Shader "FishManShaderTutorial/Mountain" {
    Properties{
        _MainTex("Base (RGB)", 2D) = "white" {}
		_CloudCol("CloudCol",Color) = (1.0,0.95,1.0,1)
		_SkyCol("SkyCol",Color) = (0.2,0.5,0.85,1)
		_SkyLine("SkyLine",Color) = (0.7,0.75,0.85,1)
		_SunCol("SunCol",Color) = (1,0.7,0.4,1)
		_SunCol2("SunCol2",Color) = (1,0.8,0.6,1)
		_SunCol3("SunCol3",Color) = (1,0.8,0.6,1)
		_World("_World",Color) = (0.4,0.65,1.0,1)
    }
    SubShader{
        Pass {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM

#pragma vertex vert   
#pragma fragment frag  
#include "ShaderLibs/Framework3D.cginc"

			float4 Cloud2(float3 bgCol,float3 ro,float3 rd,float3 cloudCol,float spd, float layer)
			{
				float4 col = float4(bgCol.x, bgCol.y, bgCol.z, 0);
				float time = _Time.y*0.05*spd;
				float2 sc;
				for (int i = 0; i < layer; i++) {
					sc = ro.xz + rd.xz*((i + 3)*1000 - ro.y) / rd.y;
					col.xyz = lerp(col, cloudCol, 0.5*smoothstep(0.5,0.8,TimeFBM(0.001*sc,time*(i + 3))));
					col.w = abs(sc.y);
				}
				return col;
			}
			fixed4 _CloudCol;
			fixed4 _SunCol;
			fixed4 _SunCol2;
			fixed4 _SunCol3;
			fixed4 _SkyCol;
			fixed4 _SkyLine;
			fixed4 _World;
			//uv:屏幕UV ro:_WorldSpaceCameraPos rd:射线方向 depth:camera Far sceneCol:相机本来的颜色
            float4 ProcessRayMarch(float2 uv,float3 ro,float3 rd,inout float sceneDep,float4 sceneCol)  {
                fixed3 col = fixed3(0.0,0.0,0.0);  
				float3 light1 = normalize(UnityWorldSpaceLightDir(rd)); /*normalize( _WorldSpaceLightPos0);*/ normalize(float3(-0.8, 0.4, -0.3));
				float sundot = clamp(dot(rd,light1),0.0,1.0);
                 // sky      
                col = _SkyCol *1.1  - rd.y*0.25;
                col = lerp( col, 0.85*_SkyLine, pow( 1.0-max(rd.y,0.0), 4.0 ) );
                // sun
                col += 0.25*_SunCol*pow( sundot ,5.0 );
                col += 0.25*_SunCol2*pow( sundot ,64.0 );
                col += 0.2*_SunCol*3*pow( sundot ,256.0 );
                // clouds
				float4 ccol = Cloud2(col,ro + rd *1000,rd, _CloudCol,1,1);
                // .
                col = lerp(ccol.xyz, 0.68*_World, pow( 1.0-max(rd.y,0.0), 16.0 ) );
				if (sceneDep < 999)
				{
					return sceneCol;
				}
				else
				{
					sceneCol.xyz = col;
					return sceneCol;
				}
            } 
            ENDCG
        }//end pass
    }//end SubShader
    FallBack Off
}



