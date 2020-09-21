Shader "Hidden/TriPlaner"
{
	Properties
	{
		_DiffuseMap ("Texture", 2D) = "white" {}	//地形专用名称
		_DiffuseMapTop ("TextureTop", 2D) = "white" {}	//地形专用名称
		_DiffuseMapRight ("TextureRight", 2D) = "white" {}	//地形专用名称
		_TextureScale ("Texture Scale",float) = 1
		_TriplanarBlendSharpness ("Blend Sharpness",float) = 1 //非90度混合
	}
	SubShader
	{
		// No culling or depth
		Cull back ZWrite On ZTest LEqual

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
				float3 normal:NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal:NORMAL;
				UNITY_FOG_COORDS(1)
				float3 worldPos:TEXCOORD2;
			};

			sampler2D _DiffuseMap;
			float4 _DiffuseMap_ST;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv,_DiffuseMap);
				o.normal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}

			float _TextureScale;
			float _TriplanarBlendSharpness;
			sampler2D _DiffuseMapTop;
			sampler2D _DiffuseMapRight;
			fixed4 frag (v2f i) : SV_Target
			{
				float3 bWeight= pow(abs(normalize(i.normal)),_TriplanarBlendSharpness);

				bWeight=bWeight/(bWeight.x+bWeight.y+bWeight.z);
				float4 xtex  = tex2D(_DiffuseMapRight,i.worldPos.zy/_TextureScale);
				float4 ytex  = tex2D(_DiffuseMapTop,i.worldPos.xz/_TextureScale);
				float4 ztex  = tex2D(_DiffuseMap,i.worldPos.xy/_TextureScale);
				fixed4 col= xtex*bWeight.x + ytex * bWeight.y + ztex * bWeight.z;
				UNITY_APPLY_FOG(i.fogCoord, tex);
				return col;
			}
			ENDCG
		}
	}
}
