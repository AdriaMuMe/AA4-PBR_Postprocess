using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(BlurRenderer), PostProcessEvent.AfterStack, "Unlit/BlurEffect")]
public sealed class Blur : PostProcessEffectSettings
{
    [Range(0.01f, 1f)]
    public FloatParameter _blurAmout = new FloatParameter { value = 0.02f };
    public FloatParameter _samples = new FloatParameter { value = 50 };
    //int _samples;
}
public sealed class BlurRenderer : PostProcessEffectRenderer<Blur>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Unlit/BlurEffect"));
        sheet.properties.SetFloat("_blurAmount", settings._blurAmout);
        sheet.properties.SetFloat("_samples", settings._samples);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}