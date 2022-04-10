Shader "Unlit/BlurEffect"
{
	HLSLINCLUDE
		// StdLib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you need to write common effects.
#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

		TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);

	float _samples;
	float _blurAmount;

	float4 Frag(VaryingsDefault i) : SV_Target
	{
		float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

		for (int j = 0; j < _samples; j++)
		{
			float offset = (j/(_samples - 1) - 0.5) * _blurAmount;
			color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.texcoord + float2(0, offset)));
			color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.texcoord + float2(offset, 0)));
		}
		color = color/(_samples*2);
		return color;
	}

		ENDHLSL

		SubShader
	{
		Cull Off ZWrite Off ZTest Always
		Pass
		{
			HLSLPROGRAM
				#pragma vertex VertDefault
				#pragma fragment Frag
			ENDHLSL
		}
	}
}
