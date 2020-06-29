// create by JiepengTan 
// https://github.com/JiepengTan/FishManShaderTutorial
// 2018-04-13  email: jiepengtan@gmail.com
Shader "FishManShaderTutorial/Stars" {
    Properties{
        _MainTex("Base (RGB)", 2D) = "white" {}
    }
    SubShader{
        Pass {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM

#pragma vertex vert  
#pragma fragment frag  
#include "ShaderLibs/Feature.cginc"
#include "ShaderLibs/Framework3D.cginc"

		float4 Stars(in float3 rd,float den,float tileNum)
		{
			float3 c = float3(0.,0.,0.);
			float3 p = rd * 50;
			float SIZE = 0.5;
			for (float i = 0.; i < 3.; i++)
			{
				float3 q = frac(p*tileNum) - 0.5;
				float3 id = floor(p*tileNum);
				float2 rn = Hash33(id).xy;

				float size = (Hash13(id)*0.2 + 0.8)*0.6;
				float demp = pow(1. - size/0.6 ,.8)*0.4;
				float val = (sin(_Time.y*31.*size)*demp + 1. - demp) * size;
				float c2 = 1. - smoothstep(0.,val,length(q));
				c2 *= step(rn.x,(.005 + i * i*0.01)*den);
				c += c2 * (lerp(float3(1.0,0.49,0.1),float3(0.75,0.9,1.),rn.y)*0.25 + 0.75);
				p *= 2;
			}
			fixed3 col = c * c*.7;
			return fixed4(col.x,col.y,col.z,p.z);
		}

		//uv:屏幕UV ro:相机的位置 rd:射线方向 depth:Unity深度 sceneCol:相机本来的颜色
            float4 ProcessRayMarch(float2 uv,float3 ro,float3 rd,inout float sceneDep,float4 sceneCol) 
			{
				float4 starcol = Stars(rd,3.,10.);
				float isMarchcol = step(starcol.w, sceneDep);
				starcol.w = 1;
				sceneCol = isMarchcol * starcol + (1 - isMarchcol) * sceneCol;
                return sceneCol;
            } 
            ENDCG
        }//end pass
    }//end SubShader
    FallBack Off
}



