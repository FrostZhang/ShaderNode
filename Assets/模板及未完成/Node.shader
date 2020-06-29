// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Cus/Node"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "white" {}
		_NormalStenth("Normal Stenth",float) = 1

		_DissolveMap("DissolveMap",2D) = "white"{}
		 _Cube("Reflection Cubemap", Cube) = "_Skybox" {}
	}
		SubShader
	{
		Cull Off /* Front Back */  ZWrite On ZTest Always /* Off LEqual */
		Tags {
				"RenderType" = "Opaque" /*"Transparent" "TransparentCutout" "Background" "Overlay"*/
				"Queue" = "Background" /* "Geometry" "AlphaTest" "Transparent" "Overlay"*/
			 }
		/*UsePass "name"*/
		LOD 300
		/* GrabPass {"_Mygrab"} */
		Pass
		{
			Tags{
					"LightMode" = "ForwardBase" /* "ForwardAdd" "Vertex" "VertexLit" "ShadowCaster" "ShadowCollector"*/
					//ForwardBase  环境光、最重要的平行光、逐顶点/SH光源、lightmaps
					//ForwardAdd  额外的逐像素光照，每个pass对应一个光源
					//Deffered    会渲染G缓冲
					//ShadowCaster 把物体的深度信息渲染到阴影映射纹理lightmap或一张深度纹理中
					//prepassBase  用于遗留的延迟渲染，该pass会渲染法线和高光反射的指数部分
					//prepassFinal 用于遗留的延迟渲染，合并纹理、光照和自发光
					//vertex vertexLMRGBM VeretxLM 遗留的顶点光照
				}
			Fog {Mode Off}
			AlphaTest Off /*Less L/G/Not Equal[0.2] Greater[0.5] Never */
			Blend One Zero /* SrcAlpha OneMinusSrcAlpha */
			BlendOp Max // Add Subtract ReverseSubtract Min LogicalClear Multiply Screen Overlay Darken
						// Lighten ColorDodge ColorBurn HardLight SoftLight Difference Exclusion  HSLHue HSLSaturation HSLColor HSLLuminosity
			/* ColorMask R */
			/* Lighting On */
			/* Offset -1,-1 //Ouline*/
			Name "NODE"  //Capital
			Stencil{
						Ref 0 //0-255 
						ReadMask 255
						WriteMask 255
						Comp Equal
						Pass keep /* Keep Zero Replace IncrSat DecrSat Invert IncrWrap DecrWrap */
						Fail keep
						ZFail keep
					}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		/*# pragma target 3.0*/

		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#include "AutoLight.cginc"
		sampler2D _CameraDepthTexture;
		sampler2D _CameraNormalsTexture;

		struct appdata
		{
			float4 vertex : POSITION;
			float4 uv : TEXCOORD0;
			float3 normal:NORMAL;
			float4 tangent:TANGENT;
		};

		struct v2f
		{
			float4 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
			fixed projector : COLOR;
			float4 screenPos  : TEXCOORD1;
			float3 reflectDir:TEXCOORD3;
			UNITY_FOG_COORDS(2)
		};
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _NormalMap;
		float _NormalStenth;
		float _Outline;
		float _Toon;
		float _RotarionSpeed;

		float4 DoRotation(float4 vertex)
		{
			float rotation = _RotarionSpeed * _Time.y;
			float s,c;
			sincos(radians(rotation),s,c);
			float2x2 rotMatrix = float2x2(c,-s,s,c);
			vertex.xy = mul(vertex.xy,rotMatrix);
			return vertex;
		}

		float4 DoScale(float4 vertex)
		{
			vertex.xz *= clamp((_SinTime.w + 3.0)*0.5, 1.0, 2.0);
			return vertex;
		}

		float4x4 unity_Projector;
		float4x4 unity_ProjectorClip;
		v2f vert(appdata v)
		{
			v2f o;

			o.vertex = UnityObjectToClipPos(v.vertex);

			//描边 Ouline
			float3 nor = mul((float3x3)UNITY_MATRIX_T_MV,v.normal);
			float2 offset = TransformViewToProjection(nor.xy);
			o.vertex.xy += offset * o.vertex.z * _Outline; 

			//Billboard 公告板
			float4 ori =mul(UNITY_MATRIX_MV ,float(0,0,0,1));
			float4 vt = v.vertex;
			float2 r1 = float2(unity_ObjectToWorld[0][0],unity_ObjectToWorld[0][2]);
			float2 r2 = float2(unity_ObjectToWorld[2][0],unity_ObjectToWorld[2][2]);
			float2 vt0 = vt.x*r1;
			vt0 += vt.z *r2;
			vt.xy = vt0;
			//vt.y= vt.z;
			vt.z=0;
			vt.xyz+=ori.xyz;
			o.vertex = mul(UNITY_MATRIX_P ,vt); 

			o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

			float3 worldnormal = normalize(UnityObjectToWorldNormal(v.normal));
			float3 worldPos = mul(unity_ObjectToWorld, v.vertex);

			//光源类型 平行光：位置固定、衰减固定为1 点光源：有位置、衰减由一个函数定义 聚光灯：位置、范围、衰减
#ifdef USING_DIRECTIONAL_LIGHT
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
#else
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - worldPos.xyz);
#endif

				//光照强度
#ifdef USING_DIRECTIONAL_LIGHT
				fixed atten = 1.0;
#else
#if defined (POINT)
				float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#elif defined (SPOT)
				float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#else
				fixed atten = 1.0;
#endif
#endif

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//Diffuse光 _LightColor0 平行光
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				//Specular光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				//Specular光 halfDir
				float halflight = _LightColor0.rgb * _Specular.rgb *pow(saturate(dot(normalize(halfDir), normalize(worldLightDir))), _Gloss);

				//卡通 Catoon (利用step步进)
				float lambert = max(0, dot(worldNormal, worldLightDir));
				lambert = （lambert + 1） / 2;
				lambert = smoothstep(lambert / 12,1,lambert);
				float toon = floor(lambert *0.5) / 0.5;
				lambert = lerp(lambert,toon,_Toon);

				//反射光
				float3 reflectdir = reflect(-worldLightDir, worldnormal);
				float reflectstrenth = saturate(dot(reflectdir, viewdir));
				float spec = pow(reflectstrenth, 128);

				//lightProp光照解析
				float3 vertexlight = ShadeVertexLights(v.vertex ,v.normal);
				float3 lightprob = ShadeSH9(half4(worldnormal,1.0));

				//LightMap 得到烘焙的光照
				#ifndef LIGHTMAP_ON
				fixed3 vlight = ShadeSH9(float4(worldnormal, 1.0));
				//vlight += LightingLambertVS(worldnormal, _WorldSpaceLightPos0.xyz);
				//片元部分
				float2 lightmapuv = o.uv.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				fixed3 bakedColor = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, lightmapuv));
				#endif

				//使用点光阵
				float3 pointLight = Shade4PointLights(unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
					unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
					unity_4LightAtten0,UnityObjectToWorldDir(o.vertex), UnityObjectToWorldNormal(v.normal));

				//使用切空间
				TANGENT_SPACE_ROTATION;
				float3 tangentlightdir = mul(rotation,lightdir);
				float3 tangennor = UnpackNormal(tex2D(_NormalMap,o.uv.xy));
				tangennor.xy *= _NormalStenth;

				//projector 投影
				o.pos = UnityObjectToClipPos(vertex);
				o.uvShadow = mul(unity_Projector, vertex);
				o.uvFalloff = mul(unity_ProjectorClip, vertex);
				UNITY_TRANSFER_FOG(o, o.pos);
				//projector 投影 片元部分
				float4 uv = i.uvShadow;
				fixed x = uv.x / uv.w;
				fixed y = uv.y / uv.w;
				fixed4 texS = fixed4(0, 0, 0, 0);
				if (x<0.0001 || x>0.9999 || y<0.0001 || y>0.9999)
				{
					
				}
				else
				{
					texS = tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow));
					texS *= _Color;
				}

				// depth 获取深度值 参见Decal
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				//后处理深度 参见Depth

				//打开雾效
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				float4 _MainTex_TexelSize;
				float  _Dissolved;
				sampler2D _DissolveMap;
				uniform samplerCUBE _Cube;
				fixed4 frag(v2f i) : SV_Target
				{

					fixed4 col = tex2D(_MainTex, i.uv);

				//Gray 灰度
					half lumin = Luminance(col);
					col = float4(lumin,lumin,lumin,col.a);

					//BlitMutilTap 模糊
					float4 uv[4];
					uv[0] = i.uv + float4(-_MainTex_TexelSize.x,-_MainTex_TexelSize.y,0,1);
					uv[1] = i.uv + float4(_MainTex_TexelSize.x,-_MainTex_TexelSize.y,0,1);
					uv[2] = i.uv + float4(_MainTex_TexelSize.x,_MainTex_TexelSize.y,0,1);
					uv[3] = i.uv + float4(-_MainTex_TexelSize.x,_MainTex_TexelSize.y,0,1);
					float4 c = tex2D(_MainTex, uv[0]);
					 c += tex2D(_MainTex, uv[1]);
					 c += tex2D(_MainTex, uv[2]);
					 c += tex2D(_MainTex, uv[3]);
					c /= 4;

					//Dissolved 特效溶解
					fixed4 dissolvecolor = tex2D(_DissolveMap,i.uv);
					if(dissolvecolor.r< _Dissolved)
					{
						discard;
					}
					float prece = _Dissolved / dissolvecolor.r;
					float weight = saturate( sign(prece - 0.5));
					fixed3 edgrcol = lerp(dissolvecolor.rbg ,col.rbg ,weight); 

					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;

					//fresnel 菲涅普 Pow4(1 - saturate(dot(normalWorld, -eyeVec))); 
					// float rim = pow(1-abs(dot(viewdir,normal)),_Rim);

					/*float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
					float diff =1- saturate( _IntersectPower*(sceneZ - i.screenPos.z)); //深度  相交点*/

					fixed4 reflcol = texCUBE(_Cube, i.reflectDir);	//CUBE解析

					//refract(); 折射
				}
				ENDCG
			}

		//阴影处理 和 instancing shader
		Pass
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }

			ZWrite On ZTest LEqual Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_instancing	// 允许instancing
			#pragma multi_compile_shadowcaster	//开启阴影 受meshfilter控制
			#include "UnityCG.cginc"
				//"AutoLight.cginc"   

			struct v2f {
				V2F_SHADOW_CASTER;	//制造阴影
				UNITY_VERTEX_OUTPUT_STEREO
				SHADOW_COORDS(2)
			};
		
			//INSTANCE: UNITY_VERTEX_INPUT_INSTANCE_ID
			v2f vert(appdata_base v)
			{
				v2f o;

				//UNITY_INITIALIZE_OUTPUT(v2f, o);
				//UNITY_SETUP_INSTANCE_ID(v);
				//UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)	//制造阴影
				TRANSFER_SHADOW(o); //接收阴影
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{

				SHADOW_CASTER_FRAGMENT(i) //制造阴影

				//接收阴影的值* 最终结果
				fixed shadow = SHADOW_ATTENUATION(i);
				//如果定义了AutoLight 可通过unity结算阴影强度
				UNITY_LIGHT_ATTENUATION(shadow, i, i.worldPos);
				
			}
			ENDCG
		
			//	FallBack "Transparent/VertexLit"  强制打开透明物体阴影
		}

					/*Pass
					{
						ZTest Greater

						fixed4 frag (v2f i):SV_Target
						{
							return fixed4(1,0,0,1);
						}
					}
					Pass
					{
						ZTest Less

						fixed4 frag (v2f i):SV_Target
						{
							return fixed4(1,1,0,1);
						}
					} //显示物体背后的物体 */
	}

		FallBack "Diffuse"
}
