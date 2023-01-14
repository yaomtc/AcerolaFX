#include "Includes/AcerolaFX_Common.fxh"
#include "Includes/AcerolaFX_TempTex1.fxh"

uniform float _FocalPlaneDistance <
    ui_min = 0.0f; ui_max = 1000.0f;
    ui_label = "Focal Plane";
    ui_type = "slider";
    ui_tooltip = "Adjust distance at which detail is sharp.";
> = 40.0f;

uniform float _FocusRange <
    ui_min = 0.0f; ui_max = 1000.0f;
    ui_label = "Focus Range";
    ui_type = "slider";
    ui_tooltip = "Adjust range at which detail is sharp around the focal plane.";
> = 20.0f;

uniform float _Strength <
    ui_min = 0.0f; ui_max = 3.0f;
    ui_label = "Strength";
    ui_type = "drag";
    ui_tooltip = "Adjust strength of the depth of field.";
> = 1.0f;

uniform bool _Fill <
    ui_label = "Fill";
    ui_tooltip = "Attempt to fill in undersampling of kernel.";
> = true;

texture2D AFX_CoC { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RG8; };
sampler2D CoC { Texture = AFX_CoC; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};

texture2D AFX_QuarterColor { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA16; };
sampler2D QuarterColor { Texture = AFX_QuarterColor; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D QuarterColorLinear { Texture = AFX_QuarterColor; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_NearBlur { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA16; };
sampler2D NearBlur { Texture = AFX_NearBlur; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D NearBlurLinear { Texture = AFX_NearBlur; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_FarBlur { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA16; };
sampler2D FarBlur { Texture = AFX_FarBlur; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D FarBlurLinear { Texture = AFX_FarBlur; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_NearFill { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA16; };
sampler2D NearFill { Texture = AFX_NearFill; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D NearFillLinear { Texture = AFX_NearFill; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_FarFill { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA16; };
sampler2D FarFill { Texture = AFX_FarFill; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D FarFillLinear { Texture = AFX_FarFill; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_QuarterCoC { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RG8; };
sampler2D QuarterCoC { Texture = AFX_QuarterCoC; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D QuarterCoCLinear { Texture = AFX_QuarterCoC; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_QuarterFarColor { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RGBA16; };
sampler2D QuarterFarColor { Texture = AFX_QuarterFarColor; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D QuarterFarColorLinear { Texture = AFX_QuarterFarColor; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_NearCoCBlur { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = R8; };
sampler2D NearCoCBlur { Texture = AFX_NearCoCBlur; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};
sampler2D NearCoCBlurLinear { Texture = AFX_NearCoCBlur; MagFilter = LINEAR; MinFilter = LINEAR; MipFilter = LINEAR;};

texture2D AFX_QuarterPing { Width = BUFFER_WIDTH / 2; Height = BUFFER_HEIGHT / 2; Format = RG8; };
sampler2D QuarterPing { Texture = AFX_QuarterPing; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT;};

sampler2D Bokeh { Texture = AFXTemp1::AFX_RenderTex1; MagFilter = POINT; MinFilter = POINT; MipFilter = POINT; };
storage2D s_Bokeh { Texture = AFXTemp1::AFX_RenderTex1; };
float4 PS_EndPass(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET { return tex2D(Bokeh, uv).rgba; }

static const float2 offsets[] =
{
	2.0f * float2(1.000000f, 0.000000f),
	2.0f * float2(0.707107f, 0.707107f),
	2.0f * float2(-0.000000f, 1.000000f),
	2.0f * float2(-0.707107f, 0.707107f),
	2.0f * float2(-1.000000f, -0.000000f),
	2.0f * float2(-0.707106f, -0.707107f),
	2.0f * float2(0.000000f, -1.000000f),
	2.0f * float2(0.707107f, -0.707107f),
	
	4.0f * float2(1.000000f, 0.000000f),
	4.0f * float2(0.923880f, 0.382683f),
	4.0f * float2(0.707107f, 0.707107f),
	4.0f * float2(0.382683f, 0.923880f),
	4.0f * float2(-0.000000f, 1.000000f),
	4.0f * float2(-0.382684f, 0.923879f),
	4.0f * float2(-0.707107f, 0.707107f),
	4.0f * float2(-0.923880f, 0.382683f),
	4.0f * float2(-1.000000f, -0.000000f),
	4.0f * float2(-0.923879f, -0.382684f),
	4.0f * float2(-0.707106f, -0.707107f),
	4.0f * float2(-0.382683f, -0.923880f),
	4.0f * float2(0.000000f, -1.000000f),
	4.0f * float2(0.382684f, -0.923879f),
	4.0f * float2(0.707107f, -0.707107f),
	4.0f * float2(0.923880f, -0.382683f),

	6.0f * float2(1.000000f, 0.000000f),
	6.0f * float2(0.965926f, 0.258819f),
	6.0f * float2(0.866025f, 0.500000f),
	6.0f * float2(0.707107f, 0.707107f),
	6.0f * float2(0.500000f, 0.866026f),
	6.0f * float2(0.258819f, 0.965926f),
	6.0f * float2(-0.000000f, 1.000000f),
	6.0f * float2(-0.258819f, 0.965926f),
	6.0f * float2(-0.500000f, 0.866025f),
	6.0f * float2(-0.707107f, 0.707107f),
	6.0f * float2(-0.866026f, 0.500000f),
	6.0f * float2(-0.965926f, 0.258819f),
	6.0f * float2(-1.000000f, -0.000000f),
	6.0f * float2(-0.965926f, -0.258820f),
	6.0f * float2(-0.866025f, -0.500000f),
	6.0f * float2(-0.707106f, -0.707107f),
	6.0f * float2(-0.499999f, -0.866026f),
	6.0f * float2(-0.258819f, -0.965926f),
	6.0f * float2(0.000000f, -1.000000f),
	6.0f * float2(0.258819f, -0.965926f),
	6.0f * float2(0.500000f, -0.866025f),
	6.0f * float2(0.707107f, -0.707107f),
	6.0f * float2(0.866026f, -0.499999f),
	6.0f * float2(0.965926f, -0.258818f),
};

float DepthNDCToView(float depth_ndc) {
    float zNear = 1.0f;
    float zFar = 1000.0f;

    float2 projParams = float2(zFar / (zNear - zFar), zNear * zFar / (zNear - zFar));

    return -projParams.y / (depth_ndc + projParams.x);
}

float4 PS_CoC(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float nearBegin = max(0.0f, _FocalPlaneDistance - _FocusRange);
    float nearEnd = _FocalPlaneDistance;
    float farBegin = _FocalPlaneDistance;
    float farEnd = _FocalPlaneDistance + _FocusRange;
    
    float depth = -DepthNDCToView(tex2D(ReShade::DepthBuffer, uv).r);

    float nearCOC = 0.0f;
    if (depth < nearEnd)
        nearCOC = 1.0f / (nearBegin - nearEnd) * depth + -nearEnd / (nearBegin - nearEnd);
    else if (depth < nearBegin)
        nearCOC = 1.0f;

    float farCOC = 1.0f;
    if (depth < farBegin)
        farCOC = 0.0f;
    else if (depth < farEnd)
        farCOC = 1.0f / (farEnd - farBegin) * depth + -farBegin / (farEnd - farBegin);
    
    return saturate(float4(nearCOC, farCOC, 0.0f, 1.0f));
}

float4 PS_DownscaleColor(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    return float4(tex2D(Common::AcerolaBufferLinear, uv).rgb, 1.0f);
}

float4 PS_DownscaleCoC(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    return tex2D(CoC, uv + float2(-0.25f, -0.25f) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT));
}

float4 PS_DownscaleFarColor(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float2 pixelSize = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);

    float2 coc = tex2D(CoC, uv + float2(-0.25f, -0.25f) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)).rg;

    float2 texCoord00 = uv + float2(-0.25f, -0.25f) * pixelSize;
	float2 texCoord10 = uv + float2( 0.25f, -0.25f) * pixelSize;
	float2 texCoord01 = uv + float2(-0.25f,  0.25f) * pixelSize;
	float2 texCoord11 = uv + float2( 0.25f,  0.25f) * pixelSize;

    float cocFar00 = tex2D(CoC, texCoord00).g;
    float cocFar10 = tex2D(CoC, texCoord10).g;
    float cocFar01 = tex2D(CoC, texCoord01).g;
    float cocFar11 = tex2D(CoC, texCoord11).g;

    float weight00 = 1000.0f;
	float4 colorMulCOCFar = weight00 * tex2D(Common::AcerolaBuffer, texCoord00);
	float weightsSum = weight00;
	
	float weight10 = 1.0f / (abs(cocFar00 - cocFar10) + 0.001f);
	colorMulCOCFar += weight10 * tex2D(Common::AcerolaBuffer, texCoord10);
	weightsSum += weight10;
	
	float weight01 = 1.0f / (abs(cocFar00 - cocFar01) + 0.001f);
	colorMulCOCFar += weight01 * tex2D(Common::AcerolaBuffer, texCoord01);
	weightsSum += weight01;
	
	float weight11 = 1.0f / (abs(cocFar00 - cocFar11) + 0.001f);
	colorMulCOCFar += weight11 * tex2D(Common::AcerolaBuffer, texCoord11);
	weightsSum += weight11;

	colorMulCOCFar /= weightsSum;
	colorMulCOCFar *= coc.g;

    return float4(colorMulCOCFar.rgb, 1.0f);
}

float2 PS_MaxCoCX(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float cocMax = tex2D(QuarterCoC, uv).r;
    
    for (int x = -6; x <= 6; ++x) {
        if (x == 0) continue;
        cocMax = max(cocMax, tex2D(QuarterCoC, uv + float2(x, 0) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)).r);
    }
    return cocMax;
}

float PS_MaxCoCY(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float cocMax = tex2D(QuarterPing, uv).r;
    
    for (int y = -6; y <= 6; ++y) {
        if (y == 0) continue;
        cocMax = max(cocMax, tex2D(QuarterPing, uv + float2(0, y) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)).r);
    }
    return cocMax;
}

float2 PS_BlurCoCX(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float coc = tex2D(NearCoCBlur, uv).r;
    
    for (int x = -6; x <= 6; ++x) {
        if (x == 0) continue;
        coc += tex2D(NearCoCBlur, uv + float2(x, 0) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)).r;
    }

    return coc / 13;
}

float PS_BlurCoCY(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float coc = tex2D(QuarterPing, uv).r;
    
    for (int y = -6; y <= 6; ++y) {
        if (y == 0) continue;
        coc += tex2D(QuarterPing, uv + float2(0, y) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)).r;
    }
    
    return coc / 13;
}

float4 PS_NearBlur(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float kernelScale = _Strength >= 0.25f ? _Strength : 0.25f;
    float cocNearBlurred = tex2D(NearCoCBlur, uv).r;
    
    float4 col = tex2D(QuarterColor, uv);
    if (cocNearBlurred > 0.0f) {
        [unroll]
        for (int i = 0; i < 48; ++i) {
            float2 offset = kernelScale * offsets[i] * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
            col += tex2D(QuarterColorLinear, uv + offset);
        }

        return col / 49.0f;
    } else {
        return col;
    }
}

float4 PS_FarBlur(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float kernelScale = _Strength >= 0.25f ? _Strength : 0.25f;
    
    float4 col = tex2D(QuarterFarColor, uv);
    if (tex2D(QuarterCoC, uv).g > 0.0f) {
        float weightsSum = tex2D(QuarterCoC, uv).y;
        [unroll]
        for (int i = 0; i < 48; ++i) {
            float2 offset = kernelScale * offsets[i] * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);

            col += tex2D(QuarterFarColorLinear, uv + offset);
            weightsSum += tex2D(QuarterCoC, uv + offset).g;
        }

        return col / max(1.0f, weightsSum);
    } else {
        return 0.0f;
    }
}

float4 PS_NearFill(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float cocNearBlurred = tex2D(NearCoCBlur, uv).r;
    
    float4 col = tex2D(NearBlur, uv);
    if (cocNearBlurred > 0.0f && _Fill) {
        [unroll]
        for (int x = -1; x <= -1; ++x) {
            [unroll]
            for (int y = -1; y <= -1; ++y) {
                col = max(col, tex2D(NearBlur, uv + float2(x, y) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)));
            }
        }
    }

    return col;
}

float4 PS_FarFill(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float farCoC = tex2D(QuarterCoC, uv).g;
    
    float4 col = tex2D(FarBlur, uv);
    if (farCoC > 0.0f && _Fill) {
        [unroll]
        for (int x = -1; x <= -1; ++x) {
            [unroll]
            for (int y = -1; y <= -1; ++y) {
                col = max(col, tex2D(FarBlur, uv + float2(x, y) * float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)));
            }
        }
    }

    return col;
}

float4 PS_Composite(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float2 pixelSize = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
    float blend = _Strength >= 0.25f ? 1.0f : 4.0f * _Strength;

    float4 result = tex2D(Common::AcerolaBuffer, uv);

    float2 uv00 = uv;
    float2 uv10 = uv + float2(pixelSize.x, 0.0f);
    float2 uv01 = uv + float2(0.0f, pixelSize.y);
    float2 uv11 = uv + float2(pixelSize.x, pixelSize.y);

    float cocFar = tex2D(CoC, uv).g;
    float4 cocsFar_x4 = tex2DgatherG(QuarterCoC, uv00).wzxy;
    float4 cocsFarDiffs = abs(cocFar.xxxx - cocsFar_x4);

    float4 dofFar00 = tex2D(FarFillLinear, uv00);
    float4 dofFar10 = tex2D(FarFillLinear, uv10);
    float4 dofFar01 = tex2D(FarFillLinear, uv01);
    float4 dofFar11 = tex2D(FarFillLinear, uv11);


    float2 imageCoord = uv / pixelSize;
    float2 fractional = frac(imageCoord);
    float a = (1.0f - fractional.x) * (1.0f - fractional.y);
    float b = fractional.x * (1.0f - fractional.y);
    float c = (1.0f - fractional.x) * fractional.y;
    float d = fractional.x * fractional.y;

    float4 dofFar = 0.0f;
    float weightsSum = 0.0f;

    float weight00 = a / (cocsFarDiffs.x + 0.001f);
    dofFar += weight00 * dofFar00;
    weightsSum += weight00;

    float weight10 = b / (cocsFarDiffs.y + 0.001f);
    dofFar += weight10 * dofFar10;
    weightsSum += weight10;

    float weight01 = c / (cocsFarDiffs.z + 0.001f);
    dofFar += weight01 * dofFar01;
    weightsSum += weight01;

    float weight11 = d / (cocsFarDiffs.w + 0.001f);
    dofFar += weight11 * dofFar11;
    weightsSum += weight11;

    dofFar /= weightsSum;

    result = lerp(result, dofFar, blend * cocFar);

    float cocNear = tex2D(NearCoCBlurLinear, uv).r;
    float4 dofNear = tex2D(NearFillLinear, uv);

    result = lerp(result, dofNear, blend * cocNear);

    return result;
}

technique AFX_BokehBlur < ui_label = "Bokeh Blur"; ui_tooltip = "Simulate camera focusing."; > {
    pass {
        RenderTarget = AFX_CoC;

        VertexShader = PostProcessVS;
        PixelShader = PS_CoC;
    }

    pass {
        RenderTarget = AFX_QuarterColor;

        VertexShader = PostProcessVS;
        PixelShader = PS_DownscaleColor;
    }

    pass {
        RenderTarget = AFX_QuarterCoC;

        VertexShader = PostProcessVS;
        PixelShader = PS_DownscaleCoC;
    }

    pass {
        RenderTarget = AFX_QuarterFarColor;

        VertexShader = PostProcessVS;
        PixelShader = PS_DownscaleFarColor;
    }

    pass {
        RenderTarget = AFX_QuarterPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_MaxCoCX;
    }

    pass {
        RenderTarget = AFX_NearCoCBlur;

        VertexShader = PostProcessVS;
        PixelShader = PS_MaxCoCY;
    }

    pass {
        RenderTarget = AFX_QuarterPing;

        VertexShader = PostProcessVS;
        PixelShader = PS_BlurCoCX;
    }

    pass {
        RenderTarget = AFX_NearCoCBlur;

        VertexShader = PostProcessVS;
        PixelShader = PS_BlurCoCY;
    }

    pass {
        RenderTarget = AFX_NearBlur;

        VertexShader = PostProcessVS;
        PixelShader = PS_NearBlur;
    }

    pass {
        RenderTarget = AFX_FarBlur;

        VertexShader = PostProcessVS;
        PixelShader = PS_FarBlur;
    }

    pass {
        RenderTarget = AFX_NearFill;

        VertexShader = PostProcessVS;
        PixelShader = PS_NearFill;
    }

    pass {
        RenderTarget = AFX_FarFill;

        VertexShader = PostProcessVS;
        PixelShader = PS_FarFill;
    }

    pass {
        RenderTarget = AFXTemp1::AFX_RenderTex1;

        VertexShader = PostProcessVS;
        PixelShader = PS_Composite;
    }

    pass EndPass {
        RenderTarget = Common::AcerolaBufferTex;

        VertexShader = PostProcessVS;
        PixelShader = PS_EndPass;
    }
}