Shader "Unlit/PowerShape"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "white" {}
		_NormalStenth("Normal Stenth",float )=0.5
		_HeightLight("Height Light",COLOR)=(1,1,1,1)
		_DepthColor("Depth Color",COLOR)=(1,0,0,1)
		_Threshold("Threshold",float )=0.5
		_Rim("Rim",float )=1
		_AlphaScale("Alpha Scale",Range(0,1))=1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
		Cull Off Lighting Off ZWrite Off
		Blend  SrcAlpha OneMinusSrcAlpha
		Pass
		{
			//Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma multi_compile_particles

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "Thrid/FishManShaderTutorial/Shaders/ShaderLibs/Feature.cginc"
			#include "Thrid/FishManShaderTutorial/Shaders/ShaderLibs/Noise.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float4 tangent:TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 projpos :TEXCOORD2;
				float3 normal : NORMAL;
				float3 viewdir:TEXCOORD3;
				float3 lightdir:TEXCOORD4;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NormalMap;
			float  _Threshold;
			float  _NormalStenth;
			float _AlphaScale;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.projpos = ComputeScreenPos(o.vertex);	//projectedPosition 为了frag获得该物体在深度图的位置
				COMPUTE_EYEDEPTH(o.projpos.z);	//获得此物体的深度

			    o.viewdir = normalize(WorldSpaceViewDir(v.vertex));
				o.normal =normalize(UnityObjectToWorldNormal(v.normal));
				
				TANGENT_SPACE_ROTATION;
				o.lightdir =normalize(mul(rotation,ObjSpaceLightDir(v.vertex)));

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

			fixed4 _HeightLight;
			fixed4 _DepthColor;
			float _Rim;

			fixed4 frag (v2f i) : SV_Target
			{
				float2 uv =i.uv+_Time.x;
				float3 tangennor = UnpackNormal(tex2D(_NormalMap,uv));
				tangennor.xy *= _NormalStenth;
				fixed4 col = tex2D(_MainTex, uv);
				float lightstengh = saturate(dot(i.lightdir,normalize( tangennor)));
				float3 diff =col.rbg * _LightColor0 * lightstengh;
				//fixed3 ctcol = CausticTriTwist(i.uv,_Time.y);
				fixed spec = CausticVoronoi(i.uv*5,_Time.y)*pow(lightstengh,0.1);
				col.rbg = col+ diff + spec +UNITY_LIGHTMODEL_AMBIENT.rbg;
				col.a*=_AlphaScale;

				float sz = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(i.projpos )));
				float fade = saturate(_Threshold*(sz - i.projpos.z));
				float intersect = (1 - fade) ;
				col = lerp(col,_DepthColor,intersect);

				float rim = pow(1-abs(dot(i.viewdir,i.normal)),_Rim);
				col.rgb = lerp(col.rgb,_HeightLight,rim);

				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
