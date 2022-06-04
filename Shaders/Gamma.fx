#include "ReShade.fxh"
#include "Common.fxh"

uniform float _Gamma <
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "Gamma";
    ui_type = "drag";
    ui_tooltip = "Adjust gamma correction";
> = 1.0f;

texture2D GammaTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA16F; }; 
sampler2D Gamma { Texture = GammaTex; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(Gamma, uv).rgba; }

float4 PS_Gamma(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 col = tex2D(Common::AcerolaBuffer, uv).rgba;
    float UIMask = 1.0f - col.a;

    float3 output = pow(saturate(abs(col.rgb)), _Gamma);

    return float4(lerp(col.rgb, output, UIMask), col.a);
}

technique Gamma {
    pass {
        RenderTarget = GammaTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_Gamma;
    }

    pass EndPass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}