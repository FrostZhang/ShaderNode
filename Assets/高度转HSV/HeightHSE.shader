// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "UnityLibrary/Effects/HeightHSE" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_HeightRange ("HeightRange", Float) = 500
		_Heightbegin ("Heightbegin", Float) = 0
		_L("亮度", Range(8.0, 256)) = 89   // 控制高光区域大小
        _S("纯度", Range(8.0, 256)) = 240   // 控制高光区域大小
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull Off
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _HeightRange;
		float _Heightbegin;
		float _L;
		float _S;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)
		//HSV to RGB
			float3 HSVConvertToRGB(float3 hsv)
			{
				float R,G,B;
            //float3 rgb;
				if( hsv.y == 0 )
				{
					R=G=B=hsv.z;
				}
				else
				{
					hsv.x = hsv.x/60.0; 
					int i = abs((int)hsv.x);
					float f = hsv.x - (float)i;
					float a = hsv.z * ( 1 - hsv.y );
					float b = hsv.z * ( 1 - hsv.y * f );
					float c = hsv.z * ( 1 - hsv.y * (1 - f ) );
					switch(i)
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
				return float3(R,G,B);
			}       
			float3 height2Color(float y){
				float fact = abs(y - _Heightbegin)/_HeightRange;
				if (fact > 1)
					fact = 1.0;
				float H = pow((1 - fact), 0.3)*240.0;
				float L = _L/255.0;
				float S = _S/255.0;
				float3 color = HSVConvertToRGB(float3(H, S, L));
				return color;
			}
		void surf (Input IN, inout SurfaceOutputStandard o) {

			// Albedo comes from a texture tinted by color
			//fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float y=IN.worldPos.y;
			o.Albedo =height2Color(y);
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 0.8;
		}
		
		ENDCG
	}
	FallBack "Diffuse"
}
