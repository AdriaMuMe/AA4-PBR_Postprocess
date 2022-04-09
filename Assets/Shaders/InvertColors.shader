Shader "Custom/InvertColors"
{
	HLSLINCLUDE
		// StdLib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you need to write common effects.
#include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

		TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);

	float _samples;
	float _blurAmount;

	float4 Frag(VaryingsDefault i) : SV_Target
	{
		//init color variable
		float4 col = 0;
		float sum = _samples;

		//Y
		for (float index = 0; index < _samples; index++) {
			//get the offset of the sample
			float offset = (index / (_samples - 1) - 0.5) * _blurAmount;
			//get uv coordinate of sample
			float2 uv = i.texcoord + float2(0, offset);
			col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
		}
		
		col = col / sum;

		//X
		for (float index2 = 0; index2 < _samples; index2++) {
			//get the offset of the sample
			float offset = (index / (_samples - 1) - 0.5) * _blurAmount;
			//get uv coordinate of sample
			float2 uv = i.texcoord + float2(0, offset);
			col += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
		}

		//divide the sum of values by the amount of _samples
		col = col / sum;
		return col;
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
