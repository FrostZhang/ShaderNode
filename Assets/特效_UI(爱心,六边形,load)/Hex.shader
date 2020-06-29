Shader "Unlit/Hex2" {
Properties {
    _EdgeColor ("Edge Color", Color) = (0,1,1,1)
    _Color ("BG Color", Color) = (1,1,1,1)
    _Colmun ("Colmun", float) = 1
    _Edge ("Edge Width", Range(0,1)) = 0
    _Center ("Center(xy) OffsetX(zw)", Vector) =  (0,0,0,0)

    _Target ("A(xy)", Vector) =  (0,0,0,0)
}

SubShader {
    Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
    LOD 100

    Cull Off
    ZWrite Off
    //Blend SrcAlpha OneMinusSrcAlpha 

    Pass {  
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(0)
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _Color;
            fixed4 _EdgeColor;
            fixed _Colmun;
            fixed _Edge;

            fixed4 _Target;


            fixed4 _Center;

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f input) : COLOR
            {
                //fixed4 col = _EdgeColor;

                fixed size = 0.5 / (_Colmun * 0.86602540378445);
                fixed2 pixel = input.uv.xy + fixed2( 2 * size * _Center.z - _Center.x, 2 * size * _Center.w - _Center.y);

                fixed q = (pixel.x * 0.57735026918963 - pixel.y *0.33333333333) / size;
                fixed r = pixel.y * 0.66666666666 / size;

                fixed rx = round(q);
                fixed ry = round(-q - r);
                fixed rz = round(r);

                fixed yx = step(abs(ry + q + r),abs(rx - q));
                fixed zx = step(abs(rz - r),abs(rx - q));
                fixed zy = step(abs(rz - r),abs(ry + q + r));

                rx = (yx * zx) * (-ry - rz) + (1-yx * zx ) * rx;
                ry = (zy- yx*zx*zy) * (-rx - rz) + (1- zy+yx*zx*zy) *ry;
                rz = (1- zy+yx*zx*zy) * (-rx - ry) + (zy-yx * zx* zy) * rz;

                fixed3 n[6] = {
                    fixed3(0, 1, -1),
                    fixed3(1, 0, -1),
                    fixed3(-1, 1, 0),
                    fixed3(1, -1, 0),
                    fixed3(-1, 0, 1),
                    fixed3(0, -1, 1),
                };

                fixed mindis = 2;
                for(int i=0; i<6; i++){
                    fixed2 pos = fixed2(size * 1.73205080756887 * ((rx+n[i].x) + (rz+n[i].z) * 0.5),size * 1.5 *(rz+ n[i].z));
                    fixed a = distance(pixel.xy,pos);
                    mindis = min(mindis,a);
                }

                fixed isEdge = step(abs(distance(pixel.xy,fixed2(size * 1.73205080756887 * (rx + rz * 0.5) ,size * 1.5 * rz))-mindis),size*_Edge);

                
                zx = (_Target.x<0)*ceil(_Target.x) + (_Target.x>0)*floor(_Target.x);
                zy = (_Target.y<0)*ceil(_Target.y) + (_Target.y>0)*floor(_Target.y);

                fixed hx = zx - (zy - fmod(zy,2)) *0.5;
                hx = step(hx,0) * ceil(hx) + step(0,hx) * floor(hx);
                fixed hz = zy;
                fixed hy = -hx - hz;

                fixed isTarget= distance(fixed3(hx,hy,hz), fixed3(rx,ry,rz)) == 0;

                fixed4 col = isEdge * _EdgeColor + 
                (1 - isEdge)*(1-isTarget) * _Color + 
                (1 - isEdge)* isTarget* fixed4(1,0,0,1);
                
                //fixed4 col = isEdge * _EdgeColor + 
                //(1 - isEdge)* _Color;

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
        ENDCG
    }
}

}