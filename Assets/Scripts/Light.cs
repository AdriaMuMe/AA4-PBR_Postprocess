﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Light : MonoBehaviour
{
    public enum LightType {Point,Directional};
    public LightType type;
    public Vector3 direction;
    public Color color;
    public float intensity;
    
    Material lightMat;
    public Material[] mat = new Material[3];

    // Start is called before the first frame update
    void OnEnable()
    {
        direction = transform.forward;
        //mat = ;
        if (type == LightType.Point)
        {
            Shader.EnableKeyword("POINT_LIGHT_ON");
            lightMat = GetComponent<Renderer>().sharedMaterial;
        }
        if(type == LightType.Directional)
            Shader.EnableKeyword("DIRECTIONAL_LIGHT_ON");
        
    }
    private void OnDisable()
    {
        if (type == LightType.Point)
            Shader.DisableKeyword("POINT_LIGHT_ON");
        if (type == LightType.Directional)
            Shader.DisableKeyword("DIRECTIONAL_LIGHT_ON");
    }
    private void OnDrawGizmos()
    {
       if (type == LightType.Directional)
            Debug.DrawLine(transform.position, transform.position + direction, color);
    }

    // Update is called once per frame
    void Update()
    {
        if (type == LightType.Directional)
        {
            direction = transform.forward;
            for (int i = 0; i < mat.Length; i++)
            {
                mat[i].SetVector("_directionalLightDir", -direction);
                mat[i].SetColor("_directionalLightColor", color);
            }
        }
        else if(type == LightType.Point)
        {
            lightMat.SetColor("_EmissionColor", color * 20 * intensity);
            for (int i = 0; i < mat.Length; i++)
            {
                mat[i].SetVector("_pointLightPos", transform.position);
                mat[i].SetColor("_pointLightColor", color);
            }
        }
    }
}
