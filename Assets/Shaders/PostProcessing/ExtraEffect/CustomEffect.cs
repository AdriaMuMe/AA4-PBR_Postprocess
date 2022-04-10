using UnityEngine;

[ExecuteInEditMode]
public class CustomEffect : MonoBehaviour
{
    [SerializeField]
    public Material EffectMaterial;

    void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        Graphics.Blit(src, dst, EffectMaterial);
    }
}
