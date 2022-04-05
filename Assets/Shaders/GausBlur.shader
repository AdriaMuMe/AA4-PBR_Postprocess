Shader "Unlit/GausBlur"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _BlurSize("BlurSize", Range(0, 0.1)) = 0
        _objectColor("Main color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _BlurSize;
            float iterationSample = 10;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = 0;

                for (float index = 0; index < iterationSample; index++)
                {
                    float2 uv = i.uv + float2(0, (index/9 - 0.5) * _BlurSize);
                    col += tex2D(_MainTex, uv);
                }
                
                col = col / iterationSample;
                //col.rgb = lerp(col.rgb, color.rgb, );

                return col;
            }
            ENDCG
        }
    }
}
