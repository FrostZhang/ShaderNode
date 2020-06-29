Shader "Hidden/Shape"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_A ("A", float) = 0
		_B ("B", float) = 0
		_C ("C", float) = 0
		_Color("Color",COLOR) =(1,1,1,1)
		cx("cx",range(-0.8, 0.375)) = -0.8
        cy("cy",range(-1,-1)) = 0.156
        scale("scale", range(1,3)) = 1.6
		_Rot ("Rot", float) = 0

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
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			float _Rot;

			v2f vert (appdata v)
			{
				v2f o;
				float s, c;
				float s1, c1;
				//sincos(radians(_Rot* _Time.y), s, c);
				sincos(radians(_Rot), s1, c1);
				v.vertex.yz = mul(v.vertex.yz,fixed2x2(c1,-s1,s1,c1));
				//v.vertex.xy = mul(v.vertex.xy,fixed2x2(c,-s,s,c));
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			#define RS(a,b,x) ( smoothstep(a-.01,a+.01,x)*(1-smoothstep(b-.01,b+.01,x)) )
			#define RANGE(a,b,x) ( step(a,x)*(1.0-step(b,x)) )
			float _A;
			float _B;
			float _C;

			float3 CausticTriTwist(float2 uv,float time )
			{
				const int MAX_ITER = 5;
				float2 p = fmod(uv*UNITY_TWO_PI,UNITY_TWO_PI )-250.0;

				float2 i = float2(p);
				float c = 1.0;
				float inten = .005;

				for (int n = 0; n < MAX_ITER; n++) 
				{
					float t = time * (1.0 - (3.5 / float(n+1)));
					i = p + float2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
					c += 1.0/length(float2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
				}
    
				c /= float(MAX_ITER);
				c = 1.17-pow(c, 1.4);
				float val = pow(abs(c), 8.0);
				return val;
			}
			fixed4 _Color;
			// 复数 c 的实部
			float cx;
			// 复数 c 的虚部
			float cy;
			float scale;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;

				fixed2 c = 1/2.0;
				//col = RANGE(_A,_B,i.uv.y-_C) *fixed4(1,0,0,1);
				//fixed2 uv = (i.uv*3);
			 //   uv -= floor(uv );
				//fixed val = step(uv.x,0.01) + step(uv.y,0.01);
			 //   fixed2 uv2 =	i.uv -= 0.5;
				//fixed signv = sign(uv2.x) *sign(uv2.y);

			 //	col.xyz = CausticTriTwist(i.uv,_Time.y)*_Color;
				//fixed2 uv3 = floor((i.uv-0.5)*5)/2;
				//fixed qipan = frac(uv3.x+uv3.y)*2;

				////朱利亚集合 Julia 奇幻图形 
				//i.uv +=0.5;
				//// 迭代初始值的实部
    //            float ax = scale * (0.5 - i.uv.x) / 0.5;
    //            // 迭代初始值的虚部
    //            float ay = scale * (0.5 - i.uv.y) / 0.5;
    //            float juliaValue;
    //            // 进行 200 次迭代
    //            for(int index = 0; index<100; index++){
    //                // 迭代函数实现 , 先计算复数乘法 , 然后加上 c
    //                float _ax = ax*ax - ay*ay;
    //                float _ay = ay*ax + ax*ay;
    //                ax = _ax + cx;
    //                ay = _ay + cy;
    //                // 计算模长 , 超过阈值则认为不属于 Julia 集 , 返回黑色
    //                juliaValue = sqrt(ax * ax + ay*ay);
    //                if(juliaValue > 100){
    //                    return fixed4(0,0,0,1);
    //                }
    //            }
    //            // Julia 集内部的点 , 需要根据 Julia 值来计算颜色 , 这个可以自己设置颜色
    //            return fixed4(
    //            juliaValue,
    //            (fixed)(sin(_Time * 100)+1)/2,
    //            (fixed)(cos(_Time * 50)+1)/2,
    //            1
    //            );
				float len =	length(i.uv - c);
				fixed r =  smoothstep(len-0.01,len+0.01,0.25);
				//r = step(len,0.25);
				//r = clamp(len,0,0.25);
				r = fmod(i.uv.y,0.5);
				r= abs(i.uv-0.5);
				r =floor(i.uv*2 );
				r= clamp(i.uv-0.5,0,0.5);
				r = any(r);
				//lit() 一次计算各种光
				fixed ou;
				r= modf(1.11,ou);
				r= pow(abs( i.uv.x-0.5),1.1);
				r=  saturate((i.uv-0.5));
				r= sign(i.uv-0.5);

				col = tex2D(_MainTex,i.uv);
				return col;
			}
			ENDCG
		}
	}
}
