Shader "Unlit/GausBlur"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" { }
		__blurAmount("Blur", float) = 0.5
	}
		SubShader
		{
			// Horizontal blur pass
			Tags {"Queue" = "Transparent" "IgnoreProjector" = "true" "RenderType" = "Transparent"}

			GrabPass {"_GrabTexture"}

			Pass
			{
				Blend SrcAlpha OneMinusSrcAlpha
				Name "HorizontalBlur"

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag            
				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _blurAmount;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = ComputeGrabScreenPos(o.vertex);
					return o;
				}

				fixed4 frag(v2f i) : COLOR
				{
				   float4 sum = float4(0.0, 0.0, 0.0, 0.0);

				   sum += tex2D(_MainTex, float2(i.uv.x - 5.0 * _blurAmount, i.uv.y)) * 0.025;
				   sum += tex2D(_MainTex, float2(i.uv.x - 4.0 * _blurAmount, i.uv.y)) * 0.05;
				   sum += tex2D(_MainTex, float2(i.uv.x - 3.0 * _blurAmount, i.uv.y)) * 0.09;
				   sum += tex2D(_MainTex, float2(i.uv.x - 2.0 * _blurAmount, i.uv.y)) * 0.12;
				   sum += tex2D(_MainTex, float2(i.uv.x - _blurAmount, i.uv.y)) * 0.15;
				   sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y)) * 0.16;
				   sum += tex2D(_MainTex, float2(i.uv.x + _blurAmount, i.uv.y)) * 0.15;
				   sum += tex2D(_MainTex, float2(i.uv.x + 2.0 * _blurAmount, i.uv.y)) * 0.12;
				   sum += tex2D(_MainTex, float2(i.uv.x + 3.0 * _blurAmount, i.uv.y)) * 0.09;
				   sum += tex2D(_MainTex, float2(i.uv.x + 4.0 * _blurAmount, i.uv.y)) * 0.05;
				   sum += tex2D(_MainTex, float2(i.uv.x + 5.0 * _blurAmount, i.uv.y)) * 0.025;

				   sum = sum / 11;

				   return sum;
				}
				ENDCG
			}

			GrabPass
			{
			
			}

			//VerticalBlur

			Pass{
				
				Blend SrcAlpha OneMinusSrcAlpha
				Name "VerticalBlur"

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag            
				#include "UnityCG.cginc"
				
				
				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 vertex : SV_POSITION;
				};

				sampler2D _GrabTexture : register(s0);
				float4 _GrabTexture_ST;
				float _blurAmount;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _GrabTexture);
					return o;
				}

				fixed4 frag(v2f i) : COLOR
				{
					float4 sum = float4(0.0, 0.0, 0.0, 0.0);

					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y - 5.0 * _blurAmount)) * 0.025;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y - 4.0 * _blurAmount)) * 0.05;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y - 3.0 * _blurAmount)) * 0.09;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y - 2.0 * _blurAmount)) * 0.12;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y - _blurAmount)) * 0.15;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y)) * 0.16;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y + _blurAmount)) * 0.15;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y + 2.0 * _blurAmount)) * 0.12;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y + 3.0 * _blurAmount)) * 0.09;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y + 4.0 * _blurAmount)) * 0.05;
					sum += tex2D(_GrabTexture, float2(i.uv.x, i.uv.y + 5.0 * _blurAmount)) * 0.025;

					sum = sum / 11;
					return sum;
				}
				ENDCG
			}

		}
}
