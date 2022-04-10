Shader "Unlit/Phong"
{
	Properties
	{
		 _objectColor("Main color",Color) = (0,0,0,1)
		 _ambientInt("Ambient int", Range(0,1)) = 0.25
		 _ambientColor("Ambient Color", Color) = (0,0,0,1)

		 _diffuseInt("Diffuse int", Range(0,1)) = 1
		_scecularExp("Specular exponent",Float) = 2.0

		_pointLightPos("Point light Pos",Vector) = (0,0,0,1)
		_pointLightColor("Point light Color",Color) = (0,0,0,1)
		_pointLightIntensity("Point light Intensity",Float) = 1

		_directionalLightDir("Directional light Dir",Vector) = (0,1,0,1)
		_directionalLightColor("Directional light Color",Color) = (0,0,0,1)
		_directionalLightIntensity("Directional light Intensity",Float) = 1

		_alpha("Roughtness", Range(0,1)) = 0.5
		_q("q coheficient", Range(0,1)) = 0.1

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile __ POINT_LIGHT_ON 
			#pragma multi_compile __ DIRECTIONAL_LIGHT_ON
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
				float3 wPos : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.uv;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

			fixed4 _objectColor;
			
			float _ambientInt;//How strong it is?
			fixed4 _ambientColor;
			float _diffuseInt;
			float _scecularExp;

			float4 _pointLightPos;
			float4 _pointLightColor;
			float _pointLightIntensity;

			float4 _directionalLightDir;
			float4 _directionalLightColor;
			float _directionalLightIntensity;

			//non static var:
			float _alpha;
			float _q;


            fixed4 frag (v2f i) : SV_Target
            {
				
				//3 phong model light components
                //We assign color to the ambient term		
				fixed4 ambientComp = _ambientColor * _ambientInt;//We calculate the ambient term based on intensity
				fixed4 finalColor = ambientComp;
				
				float3 viewVec;
				float3 halfVec;
				float3 difuseComp = float4(0, 0, 0, 1);
				float3 specularComp = float4(0, 0, 0, 1);
				float3 lightColor;
				float3 lightDir;

				//Ex. 2 Variables:
				float Pi = 3.14159265359f;
				float Fresnel;
				float maxP, Geometry;
				float dist1, dist2, dist3, dist4, Distribution;
				float escalat;

#if DIRECTIONAL_LIGHT_ON

				//Directional light properties
				lightColor = _directionalLightColor.xyz;
				lightDir = normalize(_directionalLightDir);

				//Diffuse componenet
				difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.worldNormal),0,1);

				//Specular component	
				viewVec = normalize(_WorldSpaceCameraPos - i.wPos);

				//Specular component
				//phong
				//float3 halfVec = reflect(-lightDir, i.worldNormal);
				//fixed4 specularComp = lightColor * pow(clamp(dot(halfVec, viewVec),0,1), _scecularExp);
				
				//blinnPhong
				halfVec = normalize(viewVec + lightDir);
				//specularComp = lightColor * pow(max(dot(halfVec, i.worldNormal),0), _scecularExp);


				//-------------------------------------- Ex 2.
				//--------------------------------------   

				//Preguntes profe: ( tres valors parametritzables? --> tres tipus de materials, 
				//aquests métodes els apliquem a cada cas? --> repetir )

				//Fresnel Schlick
				Fresnel = _q + (1 - _q) * pow(1 - dot(halfVec, lightDir),5);
				
				//Geometry Neumann
				maxP = max(dot(i.worldNormal, lightDir), dot(i.worldNormal, viewVec));
				Geometry = (dot(i.worldNormal, lightDir) * dot(i.worldNormal, viewVec)) / maxP;
				
				//Distribution GGX (Isotropic)
				/*float Distribution = (alpha * alpha) /
					(Pi * pow(pow(dot(i.worldNormal, halfVec), 2) * (((alpha * alpha) - 1) + 1), 2) );
				*/

				//Distribution Beckmann
				dist1 = Pi * pow(_alpha, 2);
				dist2 = pow(dot(i.worldNormal, halfVec),4);
				dist3 = 1 - pow(dot(i.worldNormal, halfVec), 2);
				dist4 = pow(_alpha, 2) * pow(dot(i.worldNormal, halfVec), 2);
			
				Distribution = (1 / dist1 * dist2) * exp(-(dist3) / (dist4));

				//Final steps:
				escalat = (4 * dot(i.worldNormal, lightDir) * dot(i.worldNormal, viewVec));
				specularComp = (Fresnel * Geometry * Distribution) / escalat;
				
				//-----------------------------------
				//-----------------------------------



				//Sum
				finalColor += clamp(float4(_directionalLightIntensity*(difuseComp + specularComp),1),0,1);
#endif
#if POINT_LIGHT_ON
				//Point light properties
				lightColor = _pointLightColor.xyz;
				lightDir = _pointLightPos - i.wPos;
				float lightDist = length(lightDir);
				lightDir = lightDir / lightDist;
				//lightDir *= 4 * 3.14;

				//Diffuse componenet
				difuseComp = lightColor * _diffuseInt * clamp(dot(lightDir, i.worldNormal), 0, 1)/ lightDist;

				//Specular component	
				viewVec = normalize(_WorldSpaceCameraPos - i.wPos);

				//Specular component
				//phong
				//float3 halfVec = reflect(-lightDir, i.worldNormal);
				//fixed4 specularComp = lightColor * pow(clamp(dot(halfVec, viewVec),0,1), _scecularExp);

				//blinnPhong
				halfVec = normalize(viewVec + lightDir);
				//specularComp = lightColor * pow(max(dot(halfVec, i.worldNormal), 0), _scecularExp) / lightDist;


				//-------------------------------------- Ex 2.
				//-------------------------------------- 

				//Fresnel Schlick
				Fresnel = _q + ((1 - _q) * (1 - dot(halfVec, lightDir)));

				//Geometry Neumann
				maxP = max(dot(i.worldNormal, lightDir), dot(i.worldNormal, viewVec));
				Geometry = (dot(i.worldNormal, lightDir) * dot(i.worldNormal, viewVec)) / maxP;

				//Distribution GGX (Isotropic)
				/*float Distribution = (alpha * alpha) /
					(Pi * pow(pow(dot(i.worldNormal, halfVec), 2) * (((alpha * alpha) - 1) + 1), 2) );
				*/

				//Distribution Beckmann
				dist1 = Pi * pow(_alpha, 2);
				dist2 = pow(dot(i.worldNormal, halfVec), 4);
				dist3 = 1 - pow(dot(i.worldNormal, halfVec), 2);
				dist4 = pow(_alpha, 2) * pow(dot(i.worldNormal, halfVec), 2);

				Distribution = (1 / dist1 * dist2) * exp(-(dist3) / (dist4));

				//Final steps:
				escalat = (4 * dot(i.worldNormal, lightDir) * dot(i.worldNormal, viewVec));
				specularComp = (Fresnel * Geometry * Distribution) / escalat;

				//-----------------------------------
				//-----------------------------------

				//Sum
				finalColor += clamp(float4(_pointLightIntensity*(difuseComp + specularComp),1),0,1);
				
#endif
				//pointLight
                
				return finalColor * _objectColor;
            }
            ENDCG
        }
    }

}


