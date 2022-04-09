Shader "Hidden/Unlit/Blur"{
	//show values to edit in inspector
	Properties{
		[HideInInspector] _MainTex("Texture", 2D) = "white" {}
		_blurAmount("Blur amout", Range(0,0.5)) = 0
		_samples("Number of samples", Range(10,100)) = 10
	}

		SubShader{
			// markers that specify that we don't need culling 
			// or reading/writing to the depth buffer

			Cull Off
			ZWrite Off
			ZTest Always


			//Vertical Blur
			Pass{
				CGPROGRAM
				//include useful shader functions
				#include "UnityCG.cginc"

				//define vertex and fragment shader
				#pragma vertex vert
				#pragma fragment frag

				//texture and transforms of the texture
				sampler2D _MainTex;
				float _blurAmount;
				float _samples;

				#define PI 3.14159265359
				#define E 2.71828182846


				//the object data that's put into the vertex shader
				struct appdata {
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				//the data that's used to generate fragments and can be read by the fragment shader
				struct v2f {
					float4 position : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				//the vertex shader
				v2f vert(appdata v) {
					v2f o;
					//convert the vertex positions from object space to clip space so they can be rendered
					o.position = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}

				//the fragment shader
				fixed4 frag(v2f i) : SV_TARGET{

					//init color variable
					float4 col = 0;

					float sum = _samples;

					//iterate over blur _samples
					for (float index = 0; index < _samples; index++) {
						//get the offset of the sample
						float offset = (index / (_samples - 1) - 0.5) * _blurAmount;
						//get uv coordinate of sample
						float2 uv = i.uv + float2(0, offset);
						col += tex2D(_MainTex, uv);

					}
					//divide the sum of values by the amount of _samples
					col = col / sum;
					return col;
				}

				ENDCG
			}

			//Horizontal Blur
			Pass{
				CGPROGRAM
				//include useful shader functions
				#include "UnityCG.cginc"


				//define vertex and fragment shader
				#pragma vertex vert
				#pragma fragment frag

				//texture and transforms of the texture
				sampler2D _MainTex;
				float _blurAmount;
				float _samples;

				#define PI 3.14159265359
				#define E 2.71828182846

				//the object data that's put into the vertex shader
				struct appdata {
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				//the data that's used to generate fragments and can be read by the fragment shader
				struct v2f {
					float4 position : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				//the vertex shader
				v2f vert(appdata v) {
					v2f o;
					//convert the vertex positions from object space to clip space so they can be rendered
					o.position = UnityObjectToClipPos(v.vertex);
					o.uv = v.uv;
					return o;
				}

				//the fragment shader
				fixed4 frag(v2f i) : SV_TARGET{

					//calculate aspect ratio
					float invAspect = _ScreenParams.y / _ScreenParams.x;
				//init color variable
				float4 col = 0;

				float sum = _samples;

				//iterate over blur _samples
				for (float index = 0; index < _samples; index++) {
					//get the offset of the sample
					float offset = (index / (_samples - 1) - 0.5) * _blurAmount * invAspect;
					//get uv coordinate of sample
					float2 uv = i.uv + float2(offset, 0);
					//simply add the color if we don't have a gaussian blur (box)
					col += tex2D(_MainTex, uv);

				}
				//divide the sum of values by the amount of _samples
				col = col / sum;
				return col;
			}

			ENDCG
		}
		}
}