
#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#define __METAL__
#include "../vMetalShaderTypes.h"

//-------------------------------------------------------------
// Supported shaders
//-------------------------------------------------------------

//-------------------------------------------------------------
// Standard Shaders:                        ( Alpha Equation | RGB Equation )
//
// FlatColorShader                          (T | FlatRGB)
// VertexColorShader                        (T * VCAlpha | VCRGB)
// TextureShader                            (T * TexAlpha | TexRGB)
// TextureFlatColorShader                   (T * TexAlpha | Flat color + TexRGB)
// TextureVertexColorShader                 (T * TexAlpha * VCAlpha | VCRGB + TexRGB)
// TextureBlendVertexColorShader            (T * VCAlpha | TexRGB * TexAlpha + VCRGB * 1 - TexAlpha)
// TextureAlphaFlatColorShader              (T * TexAlpha | Flat color)
// TextureAlphaVertexColorShader            (T * TexAlpha * VCAlpha | VCRGB)
// Texture2AlphaFlatColorShader             (T * TexAlpha * TexAlpha2 | Flat color + TexRGB)
// PhongFlatColorShader                     (T | Ambient + FlatRGB * df + Specular * sf)
// PhongVertexColorShader                   (T * VCAlpha | VCRGB * df + Specular * sf)
// PhongTextureFlatColorShader              (T * TexAlpha | Ambient + (FlatRGB + TexRGB) *  df + Specular * sf)
// PhongTexture2AlphaFlatColorShader        (T * TexAlpha * TexAlpha2 | Ambient + (FlatRGB + TexRGB) *  df + Specular *
// sf) PhongEnvMapShader                    (T | Ambient + (FlatRGB * 0.9 + EnvMap * BlendValue) * df + Specular *
// sf) NormalMapFlatColorShader             (T * NormAlpha | Ambient + FlatRGB * df + Specular * sf)
// NormalMapVertexColorShader               (T * NormAlpha * VCAlpha | VCRGB * df + Specular * sf)
//
// RRPhongEnvMapTextureShader (rounded rect)
// RRNormalMapTextureShader (rounded rect)
// TextBacklightShader (text background glow)
// MultiTextrureShader (blend 2 textures)
//
// Sprite Shaders :                         ( Alpha Equation | RGB Equation )
// SpriteFlatColorShader                    (T & FlatRGB)
// SpriteVertexColorShader                  (T * VCAlpha | VCRGB)
// SpriteTextureShader                      (T * TexAlpha | TexRGB)
// SpriteTextureVertexColorShader           (T * TexAlpha  * VCAlpha | VCRGB + TexRGB)
// SpriteTextureAtlasVertexColorShader      (T * TexAlpha  * VCAlpha | VCRGB + TexRGB)
// SpriteTextureAlphaVertexColorShader      (T * TexAlpha  * VCAlpha | VCRGB)
// SpriteTextureAtlasAlphaVertexColorShader (T * TexAlpha  * VCAlpha | VCRGB)
// SpriteNormalMapVertexColorShader         (T * NormAlpha * VCAlpha | VCRGB * df + Specular * sf)
// SpriteNormalMapAtlasVertexColorShader    (T * NormAlpha * VCAlpha | VCRGB * df + Specular * sf)
//
// Picking Shaders :
// PickFlatColorShader
// PickVertexColorShader
// PickSpriteVertexColorShader
// PickSpriteTextureVertexColorShader
// PickSpriteTextureAtlasVertexColorShader
//-------------------------------------------------------------

// Vertex shader outputs and pixel shader inputs

typedef struct
{
    float4 position [[position]];
} RasterizerDataXYZ;

typedef struct
{
    float4 position [[position]];
    float4 color;
} RasterizerDataXYZC;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
    float2 texCoord2;
} RasterizerDataXYZT;

typedef struct
{
    float4 position [[position]];
    float4 color;
    float2 texCoord;
    float2 texCoord2;
} RasterizerDataXYZCT;

//-------------------------------------------------------------
// normals

typedef struct
{
    float4 position [[position]];
    float4 normal;
} RasterizerDataXYZN;

typedef struct
{
    float4 position [[position]];
    float4 normal;
    float4 color;
} RasterizerDataXYZNC;

typedef struct
{
    float4 position [[position]];
    float4 normal;
    float2 texCoord;
    float2 texCoord2;
} RasterizerDataXYZNT;

//-------------------------------------------------------------
// point sprites

typedef struct
{
    float4 position [[position]];
    float pointSize [[point_size]];
} RasterizerDataSpriteXYZ;

typedef struct
{
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
} RasterizerDataSpriteXYZC;

typedef struct
{
    float4 position [[position]];
    float4 color;
    float2 texCoord;
    float2 texCoord2;
    float pointSize [[point_size]];
} RasterizerDataSpriteXYZCT;

typedef struct
{
    float4 position [[position]];
    float4 normal;
    float4 color;
    float2 texCoord;
    float2 texCoord2;
    float pointSize [[point_size]];
} RasterizerDataSpriteXYZNCT;

//-------------------------------------------------------------
// Supported shaders
//-------------------------------------------------------------

//-------------------------------------------------------------
//-------------------------------------------------------------
//  FlatColorShader

vertex RasterizerDataXYZ
MetalFlatColorShaderVS(uint vertexID [[vertex_id]],
                       constant MetalVertXYZ *vertices [[buffer(MetalVSVertices)]],
                       constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZ out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;

    return out;
}

fragment float4 MetalFlatColorShaderPS(RasterizerDataXYZ in [[stage_in]],
                                       constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float alpha = materialBuffer.transparency;
    return float4( materialBuffer.diffuse.rgb * alpha, alpha );
}

//-------------------------------------------------------------
//  VertexColorShader

vertex RasterizerDataXYZC
MetalVertexColorShaderVS(uint vertexID [[vertex_id]],
                         constant MetalVertXYZC *vertices [[buffer(MetalVSVertices)]],
                         constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZC out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;

    return out;
}

fragment float4 MetalVertexColorShaderPS(RasterizerDataXYZC in [[stage_in]],
                                         constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float alpha = in.color.a * materialBuffer.transparency;
    return float4( in.color.rgb * alpha, alpha );
}

//-------------------------------------------------------------
//-------------------------------------------------------------
//  TextureShader

vertex RasterizerDataXYZT
MetalTextureShaderVS(uint vertexID [[vertex_id]],
                     constant MetalVertXYZT *vertices [[buffer(MetalVSVertices)]],
                     constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalTextureShaderPS(RasterizerDataXYZT in [[stage_in]],
                                     texture2d<float> diffuseTexture [[texture(0)]],
                                     sampler samplr [[sampler(0)]],
                                     constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float alpha = texColor.a * materialBuffer.transparency;
    return float4( texColor.rgb * alpha, alpha );
    
    //"    vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    float alpha = texColor.a * Transparency;"
    //"    gl_FragColor = vec4(texColor.xyz * alpha, alpha);"
}

//-------------------------------------------------------------
//  TextureFlatColorShader

vertex RasterizerDataXYZT
MetalTextureFlatColorShaderVS(uint vertexID [[vertex_id]],
                              constant MetalVertXYZT *vertices [[buffer(MetalVSVertices)]],
                              constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalTextureFlatColorShaderPS(RasterizerDataXYZT in [[stage_in]],
                                              texture2d<float> diffuseTexture [[texture(0)]],
                                              sampler samplr [[sampler(0)]],
                                              constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float alpha = texColor.a * materialBuffer.transparency;
    return float4( (materialBuffer.diffuse.rgb + texColor.rgb) * alpha, alpha );
    
    //"    vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    float alpha = texColor.a * Transparency;"
    //"    gl_FragColor = vec4((Color + texColor.xyz) * alpha, alpha);"
}


//-------------------------------------------------------------
//  TextureVertexColorShader

vertex RasterizerDataXYZCT
MetalTextureVertexColorShaderVS(uint vertexID [[vertex_id]],
                                constant MetalVertXYZCT *vertices [[buffer(MetalVSVertices)]],
                                constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalTextureVertexColorShaderPS(RasterizerDataXYZCT in [[stage_in]],
                                                texture2d<float> diffuseTexture [[texture(0)]],
                                                sampler samplr [[sampler(0)]],
                                                constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float alpha = in.color.a * texColor.a * materialBuffer.transparency;
    return float4( (in.color.rgb + texColor.rgb) * alpha, alpha );
    
    //"    vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    float alpha = varColor.a * texColor.a * Transparency;"
    //"    vec3 color = texColor.xyz + varColor.xyz;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  TextureBlendVertexColorShader

vertex RasterizerDataXYZCT
MetalTextureBlendVertexColorShaderVS(uint vertexID [[vertex_id]],
                                     constant MetalVertXYZCT *vertices [[buffer(MetalVSVertices)]],
                                     constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalTextureBlendVertexColorShaderPS(RasterizerDataXYZCT in [[stage_in]],
                                                     texture2d<float> diffuseTexture [[texture(0)]],
                                                     sampler samplr [[sampler(0)]],
                                                     constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float alpha = in.color.a * materialBuffer.transparency;
    float3 color = (texColor.rgb * texColor.a) + (in.color.rgb * (1.0 - texColor.a));
    return float4( color * alpha, alpha );
    
    //"     vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    float alpha = varColor.a * Transparency;"
    //"    vec3 color = (texColor.xyz * texColor.a) + (varColor.xyz * (1.0 - texColor.a));"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//-------------------------------------------------------------
//  TextureAlphaFlatColorShader

vertex RasterizerDataXYZT
MetalTextureAlphaFlatColorShaderVS(uint vertexID [[vertex_id]],
                                   constant MetalVertXYZT *vertices [[buffer(MetalVSVertices)]],
                                   constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalTextureAlphaFlatColorShaderPS(RasterizerDataXYZT in [[stage_in]],
                                                   texture2d<float> diffuseTexture [[texture(0)]],
                                                   sampler samplr [[sampler(0)]],
                                                   constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float alpha = texColor.a * materialBuffer.transparency;
    return float4( materialBuffer.diffuse.rgb * alpha, alpha );
    
    //"    vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    float alpha = texColor.a * Transparency;"
    //"    gl_FragColor = vec4(Color * alpha, alpha);"
}

//-------------------------------------------------------------
//  TextureAlphaVertexColorShader

vertex RasterizerDataXYZCT
MetalTextureAlphaVertexColorShaderVS(uint vertexID [[vertex_id]],
                                     constant MetalVertXYZCT *vertices [[buffer(MetalVSVertices)]],
                                     constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalTextureAlphaVertexColorShaderPS(RasterizerDataXYZCT in [[stage_in]],
                                                     texture2d<float> diffuseTexture [[texture(0)]],
                                                     sampler samplr [[sampler(0)]],
                                                     constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float alpha = in.color.a * texColor.a * materialBuffer.transparency;
    return float4( in.color.rgb * alpha, alpha );
    
    //"    vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    float alpha = varColor.a * texColor.a * Transparency;"
    //"    gl_FragColor = vec4(varColor.xyz * alpha, alpha);"
}

//-------------------------------------------------------------
//  Texture2AlphaFlatColorShader

vertex RasterizerDataXYZT
MetalTexture2AlphaFlatColorShaderVS(uint vertexID [[vertex_id]],
                                   constant MetalVertXYZT *vertices [[buffer(MetalVSVertices)]],
                                   constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.texCoord = vertices[vertexID].texCoord;
    out.texCoord2 = vertices[vertexID].texCoord2;
    
    return out;
}

fragment float4 MetalTexture2AlphaFlatColorShaderPS(RasterizerDataXYZT in [[stage_in]],
                                                    texture2d<float> diffuseTexture [[texture(0)]],
                                                    sampler samplr [[sampler(0)]],
                                                    texture2d<float> diffuseTexture2 [[texture(1)]],
                                                    sampler samplr2 [[sampler(1)]],
                                                    constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float4 texAlpha = diffuseTexture2.sample(samplr2, in.texCoord2).rgba;
    float alpha = texColor.a * texAlpha.a * materialBuffer.transparency;
    return float4( (materialBuffer.diffuse.rgb + texColor.rgb) * alpha, alpha );
    
    //"     vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    vec4 texAlpha = texture2D(TextureID2, varTexCoord2);"
    //"    float alpha = texColor.a * texAlpha.a * Transparency;"
    //"     gl_FragColor = vec4((Color + texColor.xyz) * alpha, alpha);"
}

//-------------------------------------------------------------
//-------------------------------------------------------------
//  PhongFlatColorShader

vertex RasterizerDataXYZN
MetalPhongFlatColorShaderVS(uint vertexID [[vertex_id]],
                            constant MetalVertXYZN *vertices [[buffer(MetalVSVertices)]],
                            constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZN out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.normal.xyz = vertices[vertexID].normal;
    
    return out;
}

fragment float4 MetalPhongFlatColorShaderPS(RasterizerDataXYZN in [[stage_in]],
                                            constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float3 N = normalize(in.normal.xyz);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float3 color = materialBuffer.ambient + df * materialBuffer.diffuse + sf * materialBuffer.specular;
    float alpha = materialBuffer.transparency;
    return float4( color * alpha, alpha );
    
    //"    vec3 N = normalize(varNormal);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec3 color = Ambient + df * Diffuse + sf * Specular;"
    //"     gl_FragColor = vec4(color * Transparency, Transparency);"
}

//-------------------------------------------------------------
//  PhongVertexColorShader

vertex RasterizerDataXYZNC
MetalPhongVertexColorShaderVS(uint vertexID [[vertex_id]],
                              constant MetalVertXYZNC *vertices [[buffer(MetalVSVertices)]],
                              constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZNC out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.normal.xyz = vertices[vertexID].normal;
    out.color = vertices[vertexID].color;
    
    return out;
}

fragment float4 MetalPhongVertexColorShaderPS(RasterizerDataXYZNC in [[stage_in]],
                                              constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float3 N = normalize(in.normal.xyz);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float3 color = df * in.color.rgb + sf * materialBuffer.specular;
    float alpha = in.color.a * materialBuffer.transparency;
    return float4( color * alpha, alpha );
    
    //"    vec3 N = normalize(varNormal);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec3 color = df * varColor.xyz + sf * Specular;"
    //"    float alpha = varColor.a * Transparency;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  PhongTextureFlatColorShader

vertex RasterizerDataXYZNT
MetalPhongTextureFlatColorShaderVS(uint vertexID [[vertex_id]],
                                   constant MetalVertXYZNT *vertices [[buffer(MetalVSVertices)]],
                                   constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZNT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.normal.xyz = vertices[vertexID].normal;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalPhongTextureFlatColorShaderPS(RasterizerDataXYZNT in [[stage_in]],
                                                   texture2d<float> diffuseTexture [[texture(0)]],
                                                   sampler samplr [[sampler(0)]],
                                                   constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float3 N = normalize(in.normal.xyz);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float3 color = materialBuffer.ambient + df * (materialBuffer.diffuse.rgb + texColor.rgb) + sf * materialBuffer.specular;
    float alpha = texColor.a * materialBuffer.transparency;
    return float4( color * alpha, alpha );
    
    //"    vec3 N = normalize(varNormal);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    vec3 color = Ambient + df * (Diffuse + texColor.xyz) + sf * Specular;"
    //"    float alpha = texColor.a * Transparency;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  PhongTexture2AlphaFlatColorShader

vertex RasterizerDataXYZNT
MetalPhongTexture2AlphaFlatColorShaderVS(uint vertexID [[vertex_id]],
                                         constant MetalVertXYZNT *vertices [[buffer(MetalVSVertices)]],
                                         constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZNT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.normal.xyz = vertices[vertexID].normal;
    out.texCoord = vertices[vertexID].texCoord;
    out.texCoord2 = vertices[vertexID].texCoord2;
    
    return out;
}

fragment float4 MetalPhongTexture2AlphaFlatColorShaderPS(RasterizerDataXYZNT in [[stage_in]],
                                                         texture2d<float> diffuseTexture [[texture(0)]],
                                                         sampler samplr [[sampler(0)]],
                                                         texture2d<float> diffuseTexture2 [[texture(1)]],
                                                         sampler samplr2 [[sampler(1)]],
                                                         constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float3 N = normalize(in.normal.xyz);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float4 texAlpha = diffuseTexture2.sample(samplr2, in.texCoord2).rgba;
    float3 color = materialBuffer.ambient + df * (materialBuffer.diffuse.rgb + texColor.rgb) + sf * materialBuffer.specular;
    float alpha = texColor.a * texAlpha.a * materialBuffer.transparency;
    return float4( color * alpha, alpha );
    
    //"    vec3 N = normalize(varNormal);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    vec4 texAlpha = texture2D(TextureID2, varTexCoord2);"
    //"    vec3 color = Ambient + df * (Diffuse + texColor.xyz) + sf * Specular;"
    //"    float alpha = texColor.a * texAlpha.a * Transparency;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  PhongEnvMapShader

vertex RasterizerDataXYZNT
MetalPhongEnvMapShaderVS(uint vertexID [[vertex_id]],
                         constant MetalVertXYZNT *vertices [[buffer(MetalVSVertices)]],
                         constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZNT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.normal.xyz = vertices[vertexID].normal;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalPhongEnvMapShaderPS(RasterizerDataXYZNT in [[stage_in]],
                                         texture2d<float> diffuseTexture [[texture(0)]],
                                         sampler samplr [[sampler(0)]],
                                         constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float3 N = normalize(in.normal.xyz);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float3 baseColor = (materialBuffer.diffuse.rgb * 0.9) + (texColor.rgb * materialBuffer.blend);
    float3 color = materialBuffer.ambient + df * baseColor.rgb + sf * materialBuffer.specular;
    float alpha = materialBuffer.transparency;
    return float4( color * alpha, alpha );
    
    //"    vec3 N = normalize(varNormal);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec4 texColor = texture2D(TextureID, varTexCoord);"
    //"    vec3 baseColor = (Diffuse * 0.9) + (texColor.xyz * BlendValue);"
    //"    vec3 blendColor = Ambient + df * baseColor + sf * Specular;"
    //"    gl_FragColor = vec4(blendColor * Transparency, Transparency);"
}

//-------------------------------------------------------------
//  NormalMapFlatColorShader

vertex RasterizerDataXYZNT
MetalNormalMapFlatColorShaderVS(uint vertexID [[vertex_id]],
                                constant MetalVertXYZNT *vertices [[buffer(MetalVSVertices)]],
                                constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZNT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.normal.xyz = vertices[vertexID].normal;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalNormalMapFlatColorShaderPS(RasterizerDataXYZNT in [[stage_in]],
                                                texture2d<float> normalMap [[texture(0)]],
                                                sampler samplr [[sampler(0)]],
                                                constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 normMap = normalMap.sample(samplr, in.texCoord).rgba;
    // Scale and bias from [0, 1] to [-1, 1] and normalize
    float3 NMxyz = normalize(normMap.xyz * 2.0 - 1.0);
    float3 N = normalize(in.normal.xyz + NMxyz);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float3 color = materialBuffer.ambient + df * materialBuffer.diffuse.rgb + sf * materialBuffer.specular;
    float alpha = normMap.a * materialBuffer.transparency;
    return float4( color * alpha, alpha );
    
    //"    vec4 normalMap = texture2D(TextureID, varTexCoord);"
    //"    // Scale and bias from [0, 1] to [-1, 1] and normalize\n"
    //"    vec3 NMxyz = normalize(normalMap.xyz * 2.0 - 1.0);"
    //"    vec3 N = normalize(varNormal+NMxyz);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec3 color = Ambient + df * Diffuse + sf * Specular;"
    //"    float alpha = normalMap.a * Transparency;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}


//-------------------------------------------------------------
//  NormalMapVertexColorShader

vertex RasterizerDataXYZCT
MetalNormalMapVertexColorShaderVS(uint vertexID [[vertex_id]],
                                  constant MetalVertXYZCT *vertices [[buffer(MetalVSVertices)]],
                                  constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalNormalMapVertexColorShaderPS(RasterizerDataXYZCT in [[stage_in]],
                                                  texture2d<float> normalMap [[texture(0)]],
                                                  sampler samplr [[sampler(0)]],
                                                  constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 normMap = normalMap.sample(samplr, in.texCoord).rgba;
    // Scale and bias from [0, 1] to [-1, 1] and normalize
    float3 NMxyz = normalize(normMap.xyz * 2.0 - 1.0);
    float3 N = normalize(float3(0.0, 0.0, 1.0) + NMxyz);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float3 color = df * in.color.rgb + sf * materialBuffer.specular;
    float alpha = normMap.a * in.color.a * materialBuffer.transparency;
    return float4( color * alpha, alpha );
    
    //"    vec4 normalMap = texture2D(NormalMapID, varTexCoord);"
    //"    // XXXXX - undo pre-multiplied alpha\n"
    //"    //vec3 normalMapXYZ = normalMap.xyz / normalMap.a;\n"
    //"    // Scale and bias from [0, 1] to [-1, 1] and normalize\n"
    //"    vec3 normalXYZ = normalize(normalMap.xyz * 2.0 - 1.0);"
    //"    vec3 N = normalize(vec3(0.0, 0.0, 1.0)+normalXYZ);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec3 color = df * varColor.xyz + sf * Specular;"
    //"    float alpha = normalMap.a * varColor.a * Transparency;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  TextBacklightShader


vertex RasterizerDataXYZT
MetalTextBacklightShaderVS(uint vertexID [[vertex_id]],
                           constant MetalVertXYZT *vertices [[buffer(MetalVSVertices)]],
                           constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalTextBacklightShaderPS(RasterizerDataXYZT in [[stage_in]],
                                           texture2d<float> diffuseTexture [[texture(0)]],
                                           sampler samplr [[sampler(0)]],
                                           constant MetalMaterialBuffer & materialBuffer [[buffer(0)]],
                                           constant MetalBacklightBuffer & backlightBuffer [[buffer(1)]])
{
    const float PI = 3.14159265358979323846264;
    const float totalDistance = 4.0;
    
    float px = 1.0 / backlightBuffer.texSize.x;
    float py = 1.0 / backlightBuffer.texSize.y;
    float outerStrength = 3.0 * backlightBuffer.strength;
    float textAlpha = diffuseTexture.sample(samplr, in.texCoord).a;
    float totalAlpha = 0.0;
    float maxTotalAlpha = 0.0;
    for (float angle = 0.0; angle < PI * 2.0; angle += PI/4.0)
    {
        float cosAngle = cos(angle);
        float sinAngle = sin(angle);
        for (float dist = 1.0; dist <= totalDistance; dist += 2.0)
        {
            float currDistance = totalDistance - dist;
            float sampleAlpha = diffuseTexture.sample(samplr, float2(in.texCoord.x + cosAngle * dist * px,
                                                                     in.texCoord.y + sinAngle * dist * py)).a;
            totalAlpha += currDistance * sampleAlpha;
            maxTotalAlpha += (totalDistance - dist);
        }
    }
    maxTotalAlpha = max(maxTotalAlpha, 0.0001);
    float outerGlowAlpha = (totalAlpha / maxTotalAlpha) * outerStrength * (1.0 - textAlpha);
    float resultAlpha = textAlpha + outerGlowAlpha;
    float mixPercent = outerGlowAlpha / resultAlpha;
    
    float3 resultColor = (backlightBuffer.color * (1.0-mixPercent)) + (backlightBuffer.backColor * mixPercent);
    float alpha = resultAlpha * materialBuffer.transparency;
    return float4( resultColor * alpha, alpha );
    
    //"   float px = 1.0 / TextureSize.x;"
    //"   float py = 1.0 / TextureSize.y;"
    //"   float outerStrength = 3.0 * Strength;"
    //"   float textAlpha = texture2D(TextureID, varTexCoord).a;"
    //"   float totalAlpha = 0.0;"
    //"   float maxTotalAlpha = 0.0;"
    //"   for (float angle = 0.0; angle < PI * 2.0; angle += PI/4.0)"
    //"   {"
    //"       float cosAngle = cos(angle);"
    //"       float sinAngle = sin(angle);"
    //"       for (float distance = 1.0; distance <= totalDistance; distance += 2.0)"
    //"       {"
    //"           float currDistance = totalDistance - distance;"
    //"           float sampleAlpha = texture2D(TextureID, vec2(varTexCoord.x + cosAngle * distance * px, "
    //"                                                         varTexCoord.y + sinAngle * distance * py)).a;"
    //"           totalAlpha += currDistance * sampleAlpha;"
    //"           maxTotalAlpha += (totalDistance - distance);"
    //"       }"
    //"    }"
    //"    maxTotalAlpha = max(maxTotalAlpha, 0.0001);"
    //"    float outerGlowAlpha = (totalAlpha / maxTotalAlpha) * outerStrength * (1.0 - textAlpha);"
    //"    float resultAlpha = textAlpha + outerGlowAlpha;"
    //"    float mixPercent = outerGlowAlpha / resultAlpha;"
    //"    vec3 resultColor = (Color * (1.0-mixPercent)) + (BackColor * mixPercent);"
    //"   gl_FragColor = vec4(resultColor * resultAlpha * Transparency, resultAlpha * Transparency);"
}

//-------------------------------------------------------------
//  RRPhongEnvMapTextureShader - special shader for Rounded Rectangle

vertex RasterizerDataXYZNT
MetalRRPhongEnvMapTextureShaderVS(uint vertexID [[vertex_id]],
                                  constant MetalVertXYZNT *vertices [[buffer(MetalVSVertices)]],
                                  constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZNT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.normal.xyz = vertices[vertexID].normal;
    out.texCoord = vertices[vertexID].texCoord;
    out.texCoord2 = vertices[vertexID].texCoord2;
    
    return out;
}

fragment float4 MetalRRPhongEnvMapTextureShaderPS(RasterizerDataXYZNT in [[stage_in]],
                                                  texture2d<float> diffuseTexture [[texture(0)]],
                                                  sampler samplr [[sampler(0)]],
                                                  texture2d<float> envTexture [[texture(1)]],
                                                  sampler samplr2 [[sampler(1)]],
                                                  constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 textureMap = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float4 envMap = envTexture.sample(samplr2, in.texCoord2).rgba;
    float3 N = normalize(in.normal.xyz);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float3 baseColor = (materialBuffer.diffuse * 0.9) + (envMap.xyz * materialBuffer.blend);
    float3 blendColor = materialBuffer.ambient + df * baseColor + sf * materialBuffer.specular;
    float alpha = textureMap.a * materialBuffer.transparency;
    return float4( blendColor * alpha, alpha );

    //"    vec4 textureMap = texture2D(TextureID, varTexCoord);"
    //"    vec4 envMap = texture2D(EnvMapID, varTexCoord2);"
    //"    vec3 N = normalize(varNormal);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec3 baseColor = (Diffuse * 0.9) + (envMap.xyz * BlendValue);"
    //"    vec3 blendColor = Ambient + df * baseColor + sf * Specular;"
    //"    float alpha = textureMap.a * Transparency;"
    //"    gl_FragColor = vec4(blendColor * alpha, alpha);"
}

//-------------------------------------------------------------
//  RRNormalMapTextureShader - special shader for Rounded Rectangle
//

vertex RasterizerDataXYZNT
MetalRRNormalMapTextureShaderVS(uint vertexID [[vertex_id]],
                                constant MetalVertXYZNT *vertices [[buffer(MetalVSVertices)]],
                                constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZNT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.normal.xyz = vertices[vertexID].normal;
    out.texCoord = vertices[vertexID].texCoord;
    out.texCoord2 = vertices[vertexID].texCoord2;
    
    return out;
}

fragment float4 MetalRRNormalMapTextureShaderPS(RasterizerDataXYZNT in [[stage_in]],
                                                texture2d<float> diffuseTexture [[texture(0)]],
                                                sampler samplr [[sampler(0)]],
                                                texture2d<float> normalMap [[texture(1)]],
                                                sampler samplr2 [[sampler(1)]],
                                                constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 textureMap = diffuseTexture.sample(samplr, in.texCoord).rgba;
    float4 normMap = normalMap.sample(samplr2, in.texCoord2).rgba;
    // Scale and bias from [0, 1] to [-1, 1] and normalize
    float3 NMxyz = normalize(normMap.xyz * 2.0 - 1.0);
    float3 N = normalize(in.normal.xyz + NMxyz);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float3 color = materialBuffer.ambient + df * materialBuffer.diffuse.rgb + sf * materialBuffer.specular;
    float alpha = textureMap.a * materialBuffer.transparency;
    return float4( color * alpha, alpha );

    
    //"    vec4 textureMap = texture2D(TextureID, varTexCoord);"
    //"    vec4 normalMap = texture2D(NormalMapID, varTexCoord2);"
    //"    // Scale and bias from [0, 1] to [-1, 1] and normalize\n"
    //"    vec3 NMxyz = normalize(normalMap.xyz * 2.0 - 1.0);"
    //"    vec3 N = normalize(varNormal+NMxyz);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec3 color = Ambient + df * Diffuse + sf * Specular;"
    //"    float alpha = textureMap.a * Transparency;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//-------------------------------------------------------------
//  PickFlatColorShader

vertex RasterizerDataXYZ
MetalPickFlatColorShaderVS(uint vertexID [[vertex_id]],
                       constant MetalVertXYZ *vertices [[buffer(MetalVSVertices)]],
                       constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZ out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    
    return out;
}

fragment float4 MetalPickFlatColorShaderPS(RasterizerDataXYZ in [[stage_in]],
                                       constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    return float4( materialBuffer.diffuse.rgb, materialBuffer.transparency );
}

//-------------------------------------------------------------
//  PickVertexColorShader

vertex RasterizerDataXYZC
MetalPickVertexColorShaderVS(uint vertexID [[vertex_id]],
                         constant MetalVertXYZC *vertices [[buffer(MetalVSVertices)]],
                         constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZC out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    
    return out;
}

fragment float4 MetalPickVertexColorShaderPS(RasterizerDataXYZC in [[stage_in]],
                                         constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    return float4( in.color.bgra );
}

//-------------------------------------------------------------
//-------------------------------------------------------------
//  PickSpriteVertexColorShader

vertex RasterizerDataSpriteXYZC
MetalPickSpriteVertexColorShaderVS(uint vertexID [[vertex_id]],
                                   constant MetalVertXYZC *vertices [[buffer(MetalVSVertices)]],
                                   constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZC out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalPickSpriteVertexColorShaderPS(RasterizerDataSpriteXYZC in [[stage_in]],
                                                   constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    return float4( in.color.bgra );
}

//-------------------------------------------------------------
//  PickSpriteTextureVertexColorShader

vertex RasterizerDataSpriteXYZC
MetalPickSpriteTextureVertexColorShaderVS(uint vertexID [[vertex_id]],
                                          constant MetalVertXYZC *vertices [[buffer(MetalVSVertices)]],
                                          constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZC out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalPickSpriteTextureVertexColorShaderPS(RasterizerDataSpriteXYZC in [[stage_in]],
                                                          float2 uv[[point_coord]],
                                                          texture2d<float> diffuseTexture [[texture(0)]],
                                                          sampler samplr [[sampler(0)]],
                                                          constant MetalMaterialBuffer & materialBuffer [[buffer(0)]],
                                                          constant MetalTextureBuffer & textureBuffer [[buffer(1)]])
{
    float2 texcoord;
    texcoord.x = uv.x * textureBuffer.texSize.x + textureBuffer.texOffset.x;
    texcoord.y = uv.y * textureBuffer.texSize.y + textureBuffer.texOffset.y;
    float4 textureMap = diffuseTexture.sample(samplr, texcoord);
    if (textureMap.a < 0.5)  { discard_fragment(); }
    return float4( in.color.bgra );
    
    //"    vec2 texcoord;"
    //"    texcoord.x = gl_PointCoord.x * TextureSize.x + TextureOffset.x;"
    //"    texcoord.y = gl_PointCoord.y * TextureSize.y + TextureOffset.y;"
    //"    vec4 textureMap = texture2D(TextureID, texcoord);"
    //"    if (textureMap.a < 0.5)  { discard; }"
    //"    gl_FragColor = varColor;"
}

//-------------------------------------------------------------
//  PickSpriteTextureAtlasVertexColorShader

vertex RasterizerDataSpriteXYZCT
MetalPickSpriteTextureAtlasVertexColorShaderVS(uint vertexID [[vertex_id]],
                                               constant MetalVertXYZCT *vertices [[buffer(MetalVSVertices)]],
                                               constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.texCoord = vertices[vertexID].texCoord;
    out.texCoord2 = vertices[vertexID].texCoord2;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalPickSpriteTextureAtlasVertexColorShaderPS(RasterizerDataSpriteXYZCT in [[stage_in]],
                                                               float2 uv[[point_coord]],
                                                               texture2d<float> diffuseTexture [[texture(0)]],
                                                               sampler samplr [[sampler(0)]],
                                                               constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float2 texcoord;
    texcoord.x = uv.x * in.texCoord2.x + in.texCoord.x;
    texcoord.y = uv.y * in.texCoord2.y + in.texCoord.y;
    float4 textureMap = diffuseTexture.sample(samplr, texcoord);
    if (textureMap.a < 0.5)  { discard_fragment(); }
    return float4( in.color.bgra );
    
    //"    vec2 texcoord;"
    //"    texcoord.x = gl_PointCoord.x * varTexCoord2.x + varTexCoord.x;"
    //"    texcoord.y = gl_PointCoord.y * varTexCoord2.y + varTexCoord.y;"
    //"    vec4 textureMap = texture2D(TextureID, texcoord);"
    //"    if (textureMap.a < 0.5)  { discard; }"
    //"    gl_FragColor = varColor;"
}

//-------------------------------------------------------------
//-------------------------------------------------------------
//  SpriteFlatColorShader

vertex RasterizerDataSpriteXYZ
MetalSpriteFlatColorShaderVS(uint vertexID [[vertex_id]],
                             constant MetalVertXYZ *vertices [[buffer(MetalVSVertices)]],
                             constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZ out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalSpriteFlatColorShaderPS(RasterizerDataSpriteXYZ in [[stage_in]],
                                             constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float alpha = materialBuffer.transparency;
    return float4( materialBuffer.diffuse.rgb * alpha, alpha );
    
    //"    gl_FragColor = vec4(Color * Transparency, Transparency);"
}


//-------------------------------------------------------------
//  SpriteVertexColorShader

vertex RasterizerDataSpriteXYZC
MetalSpriteVertexColorShaderVS(uint vertexID [[vertex_id]],
                               constant MetalVertXYZC *vertices [[buffer(MetalVSVertices)]],
                               constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZC out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalSpriteVertexColorShaderPS(RasterizerDataSpriteXYZC in [[stage_in]],
                                               constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float alpha = in.color.a * materialBuffer.transparency;
    return float4( in.color.rgb * alpha, alpha );
    
    //"    float alpha = varColor.a * Transparency;"
    //"    gl_FragColor = vec4(varColor.bgr * alpha, alpha);"
}

//-------------------------------------------------------------
//  SpriteTextureShader

vertex RasterizerDataSpriteXYZ
MetalSpriteTextureShaderVS(uint vertexID [[vertex_id]],
                           constant MetalVertXYZC *vertices [[buffer(MetalVSVertices)]],
                           constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZ out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalSpriteTextureShaderPS(RasterizerDataSpriteXYZ in [[stage_in]],
                                           float2 uv[[point_coord]],
                                           texture2d<float> diffuseTexture [[texture(0)]],
                                           sampler samplr [[sampler(0)]],
                                           constant MetalMaterialBuffer & materialBuffer [[buffer(0)]],
                                           constant MetalTextureBuffer & textureBuffer [[buffer(1)]])
{
    float2 texcoord;
    texcoord.x = uv.x * textureBuffer.texSize.x + textureBuffer.texOffset.x;
    texcoord.y = uv.y * textureBuffer.texSize.y + textureBuffer.texOffset.y;
    float4 textureMap = diffuseTexture.sample(samplr, texcoord);
    float alpha = textureMap.a * materialBuffer.transparency;
    return float4( textureMap.xyz * alpha, alpha );
    
    //"    vec2 texcoord;"
    //"    texcoord.x = gl_PointCoord.x * TextureSize.x + TextureOffset.x;"
    //"    texcoord.y = gl_PointCoord.y * TextureSize.y + TextureOffset.y;"
    //"    vec4 textureMap = texture2D(TextureID, texcoord);"
    //"    float alpha = textureMap.a * Transparency;"
    //"    gl_FragColor = vec4(textureMap.xyz * alpha, alpha);"
}

//-------------------------------------------------------------
//  SpriteTextureVertexColorShader

vertex RasterizerDataSpriteXYZC
MetalSpriteTextureVertexColorShaderVS(uint vertexID [[vertex_id]],
                                      constant MetalVertXYZC *vertices [[buffer(MetalVSVertices)]],
                                      constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZC out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalSpriteTextureVertexColorShaderPS(RasterizerDataSpriteXYZC in [[stage_in]],
                                                      float2 uv[[point_coord]],
                                                      texture2d<float> diffuseTexture [[texture(0)]],
                                                      sampler samplr [[sampler(0)]],
                                                      constant MetalMaterialBuffer & materialBuffer [[buffer(0)]],
                                                      constant MetalTextureBuffer & textureBuffer [[buffer(1)]])
{
    float2 texcoord;
    texcoord.x = uv.x * textureBuffer.texSize.x + textureBuffer.texOffset.x;
    texcoord.y = uv.y * textureBuffer.texSize.y + textureBuffer.texOffset.y;
    float4 textureMap = diffuseTexture.sample(samplr, texcoord);
    float alpha;
    if (textureBuffer.shaderFlags == 1) // DiscardEnabled
    {
        if (textureMap.a < 0.25) { discard_fragment(); }
        alpha = in.color.a * materialBuffer.transparency;
    }
    else // exclude textureMap when DiscardEnabled
    {
        alpha = in.color.a * materialBuffer.transparency * textureMap.a;
    }
    float3 color = in.color.rgb + textureMap.xyz;
    return float4( color * alpha, alpha );
    
    //"    vec2 texcoord;"
    //"    texcoord.x = gl_PointCoord.x * TextureSize.x + TextureOffset.x;"
    //"    texcoord.y = gl_PointCoord.y * TextureSize.y + TextureOffset.y;"
    //"    vec4 textureMap = texture2D(TextureID, texcoord);"
    //"    float alpha;"
    //"    if (ShaderFlags == 1) {" // DiscardEnabled
    //"        if (textureMap.a < 0.25) { discard; }"
    //"        alpha = varColor.a * Transparency;"
    //"    } else {" // exclude textureMap.a when DiscardEnabled
    //"        alpha = varColor.a * Transparency * textureMap.a;"
    //"    }"
    //"    vec3 color = varColor.bgr + textureMap.xyz;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  SpriteTextureAlphaVertexColorShader

vertex RasterizerDataSpriteXYZC
MetalSpriteTextureAlphaVertexColorShaderVS(uint vertexID [[vertex_id]],
                                           constant MetalVertXYZC *vertices [[buffer(MetalVSVertices)]],
                                           constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZC out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalSpriteTextureAlphaVertexColorShaderPS(RasterizerDataSpriteXYZC in [[stage_in]],
                                                           float2 uv[[point_coord]],
                                                           texture2d<float> diffuseTexture [[texture(0)]],
                                                           sampler samplr [[sampler(0)]],
                                                           constant MetalMaterialBuffer & materialBuffer [[buffer(0)]],
                                                           constant MetalTextureBuffer & textureBuffer [[buffer(1)]])
{
    float2 texcoord;
    texcoord.x = uv.x * textureBuffer.texSize.x + textureBuffer.texOffset.x;
    texcoord.y = uv.y * textureBuffer.texSize.y + textureBuffer.texOffset.y;
    float4 textureMap = diffuseTexture.sample(samplr, texcoord);
    float alpha;
    if (textureBuffer.shaderFlags == 1) // DiscardEnabled
    {
        if (textureMap.a < 0.25) { discard_fragment(); }
        alpha = in.color.a * materialBuffer.transparency;
    }
    else // exclude textureMap when DiscardEnabled
    {
        alpha = in.color.a * materialBuffer.transparency * textureMap.a;
    }
    float3 color = in.color.rgb;
    return float4( color * alpha, alpha );
    
    //"    vec2 texcoord;"
    //"    texcoord.x = gl_PointCoord.x * TextureSize.x + TextureOffset.x;"
    //"    texcoord.y = gl_PointCoord.y * TextureSize.y + TextureOffset.y;"
    //"    vec4 textureMap = texture2D(TextureID, texcoord);"
    //"    float alpha;"
    //"    if (ShaderFlags == 1) {" // DiscardEnabled
    //"        if (textureMap.a < 0.25) { discard; }"
    //"        alpha = varColor.a * Transparency;"
    //"    } else {" // exclude textureMap.a when DiscardEnabled
    //"        alpha = varColor.a * Transparency * textureMap.a;"
    //"    }"
    //"    vec3 color = varColor.bgr;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  SpriteTextureAtlasVertexColorShader

vertex RasterizerDataSpriteXYZCT
MetalSpriteTextureAtlasVertexColorShaderVS(uint vertexID [[vertex_id]],
                                           constant MetalVertXYZCT *vertices [[buffer(MetalVSVertices)]],
                                           constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.texCoord = vertices[vertexID].texCoord;
    out.texCoord2 = vertices[vertexID].texCoord2;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalSpriteTextureAtlasVertexColorShaderPS(RasterizerDataSpriteXYZCT in [[stage_in]],
                                                           float2 uv[[point_coord]],
                                                           texture2d<float> diffuseTexture [[texture(0)]],
                                                           sampler samplr [[sampler(0)]],
                                                           constant MetalMaterialBuffer & materialBuffer [[buffer(0)]],
                                                           constant MetalTextureBuffer & textureBuffer [[buffer(1)]])
{
    float2 texcoord;
    texcoord.x = uv.x * in.texCoord2.x + in.texCoord.x;
    texcoord.y = uv.y * in.texCoord2.y + in.texCoord.y;
    float4 textureMap = diffuseTexture.sample(samplr, texcoord);
    float alpha;
    if (textureBuffer.shaderFlags == 1) // DiscardEnabled
    {
        if (textureMap.a < 0.25) { discard_fragment(); }
        alpha = in.color.a * materialBuffer.transparency;
    }
    else // exclude textureMap when DiscardEnabled
    {
        alpha = in.color.a * materialBuffer.transparency * textureMap.a;
    }
    float3 color = in.color.rgb + textureMap.xyz;
    return float4( color * alpha, alpha );
    
    //"    vec2 texcoord;"
    //"    texcoord.x = gl_PointCoord.x * varTexCoord2.x + varTexCoord.x;"
    //"    texcoord.y = gl_PointCoord.y * varTexCoord2.y + varTexCoord.y;"
    //"    vec4 textureMap = texture2D(TextureID, texcoord);"
    //"    float alpha;"
    //"    if (ShaderFlags == 1) {" // DiscardEnabled
    //"        if (textureMap.a < 0.25) { discard; }"
    //"        alpha = varColor.a * Transparency;"
    //"    } else {" // exclude textureMap.a when DiscardEnabled
    //"        alpha = varColor.a * Transparency * textureMap.a;"
    //"    }"
    //"    vec3 color = varColor.bgr + textureMap.xyz;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  SpriteTextureAlphaAtlasVertexColorShader

vertex RasterizerDataSpriteXYZCT
MetalSpriteTextureAlphaAtlasVertexColorShaderVS(uint vertexID [[vertex_id]],
                                                constant MetalVertXYZCT *vertices [[buffer(MetalVSVertices)]],
                                                constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.texCoord = vertices[vertexID].texCoord;
    out.texCoord2 = vertices[vertexID].texCoord2;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalSpriteTextureAlphaAtlasVertexColorShaderPS(RasterizerDataSpriteXYZCT in [[stage_in]],
                                                                float2 uv[[point_coord]],
                                                                texture2d<float> diffuseTexture [[texture(0)]],
                                                                sampler samplr [[sampler(0)]],
                                                                constant MetalMaterialBuffer & materialBuffer [[buffer(0)]],
                                                                constant MetalTextureBuffer & textureBuffer [[buffer(1)]])
{
    float2 texcoord;
    texcoord.x = uv.x * in.texCoord2.x + in.texCoord.x;
    texcoord.y = uv.y * in.texCoord2.y + in.texCoord.y;
    float4 textureMap = diffuseTexture.sample(samplr, texcoord);
    float alpha;
    if (textureBuffer.shaderFlags == 1) // DiscardEnabled
    {
        if (textureMap.a < 0.25) { discard_fragment(); }
        alpha = in.color.a * materialBuffer.transparency;
    }
    else // exclude textureMap when DiscardEnabled
    {
        alpha = in.color.a * materialBuffer.transparency * textureMap.a;
    }
    float3 color = in.color.rgb;
    return float4( color * alpha, alpha );
    
    //"    vec2 texcoord;"
    //"    texcoord.x = gl_PointCoord.x * varTexCoord2.x + varTexCoord.x;"
    //"    texcoord.y = gl_PointCoord.y * varTexCoord2.y + varTexCoord.y;"
    //"    vec4 textureMap = texture2D(TextureID, texcoord);"
    //"    float alpha;"
    //"    if (ShaderFlags == 1) {" // DiscardEnabled
    //"        if (textureMap.a < 0.25) { discard; }"
    //"        alpha = varColor.a * Transparency;"
    //"    } else {" // exclude textureMap.a when DiscardEnabled
    //"        alpha = varColor.a * Transparency * textureMap.a;"
    //"    }"
    //"    vec3 color = varColor.bgr;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  SpriteNormalMapVertexColorShader

vertex RasterizerDataSpriteXYZC
MetalSpriteNormalMapVertexColorShaderVS(uint vertexID [[vertex_id]],
                                        constant MetalVertXYZC *vertices [[buffer(MetalVSVertices)]],
                                        constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZC out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalSpriteNormalMapVertexColorShaderPS(RasterizerDataSpriteXYZC in [[stage_in]],
                                                        float2 uv[[point_coord]],
                                                        texture2d<float> normalMap [[texture(0)]],
                                                        sampler samplr [[sampler(0)]],
                                                        constant MetalMaterialBuffer & materialBuffer [[buffer(0)]],
                                                        constant MetalTextureBuffer & textureBuffer [[buffer(1)]])
{
    float2 texcoord;
    texcoord.x = uv.x * textureBuffer.texSize.x + textureBuffer.texOffset.x;
    texcoord.y = uv.y * textureBuffer.texSize.y + textureBuffer.texOffset.y;
    float4 normMap = normalMap.sample(samplr, texcoord).rgba;
    float alpha;
    if (textureBuffer.shaderFlags == 1) // DiscardEnabled
    {
        if (normMap.a < 0.25) { discard_fragment(); }
        alpha = in.color.a * materialBuffer.transparency;
    }
    else // exclude normMap.a when DiscardEnabled
    {
        alpha = in.color.a * materialBuffer.transparency * normMap.a;
    }
    // Scale and bias from [0, 1] to [-1, 1] and normalize
    float3 normalXYZ = normMap.xyz * 2.0 - 1.0;
    float3 N = normalize(float3(0.0, 0.0, 1.0) + normalXYZ);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float3 color = df * in.color.rgb + sf * materialBuffer.specular;
    return float4( color * alpha, alpha );
    
    //"    vec2 texcoord;"
    //"    texcoord.x = gl_PointCoord.x * TextureSize.x + TextureOffset.x;"
    //"    texcoord.y = gl_PointCoord.y * TextureSize.y + TextureOffset.y;"
    //"    vec4 normalMap = texture2D(TextureID, texcoord);"
    //"    float alpha;"
    //"    if (ShaderFlags == 1) {" // DiscardEnabled
    //"        if (normalMap.a < 0.25) { discard; }"
    //"        alpha = varColor.a * Transparency;"
    //"    } else {" // exclude normalMap.a when DiscardEnabled
    //"        alpha = varColor.a * Transparency * normalMap.a;"
    //"    }"
    //"    // Scale and bias from [0, 1] to [-1, 1] and normalize\n"
    //"    vec3 normalXYZ = normalMap.xyz * 2.0 - 1.0;"
    //"    vec3 N = normalize(vec3(0.0, 0.0, 1.0)+normalXYZ);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec3 color = df * varColor.bgr + sf * Specular;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  SpriteNormalMapAtlasVertexColorShader

vertex RasterizerDataSpriteXYZCT
MetalSpriteNormalMapAtlasVertexColorShaderVS(uint vertexID [[vertex_id]],
                                             constant MetalVertXYZCT *vertices [[buffer(MetalVSVertices)]],
                                             constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataSpriteXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.texCoord = vertices[vertexID].texCoord;
    out.texCoord2 = vertices[vertexID].texCoord2;
    out.pointSize = vertices[vertexID].position.w;
    
    return out;
}

fragment float4 MetalSpriteNormalMapAtlasVertexColorShaderPS(RasterizerDataSpriteXYZCT in [[stage_in]],
                                                             float2 uv[[point_coord]],
                                                             texture2d<float> normalMap [[texture(0)]],
                                                             sampler samplr [[sampler(0)]],
                                                             constant MetalMaterialBuffer & materialBuffer [[buffer(0)]],
                                                             constant MetalTextureBuffer & textureBuffer [[buffer(1)]])
{
    float2 texcoord;
    texcoord.x = uv.x * in.texCoord2.x + in.texCoord.x;
    texcoord.y = uv.y * in.texCoord2.y + in.texCoord.y;
    float4 normMap = normalMap.sample(samplr, texcoord).rgba;
    float alpha;
    if (textureBuffer.shaderFlags == 1) // DiscardEnabled
    {
        if (normMap.a < 0.25) { discard_fragment(); }
        alpha = in.color.a * materialBuffer.transparency;
    }
    else // exclude normMap.a when DiscardEnabled
    {
        alpha = in.color.a * materialBuffer.transparency * normMap.a;
    }
    // Scale and bias from [0, 1] to [-1, 1] and normalize
    float3 normalXYZ = normMap.xyz * 2.0 - 1.0;
    float3 N = normalize(float3(0.0, 0.0, 1.0) + normalXYZ);
    float df = max(0.0, dot(N, materialBuffer.lightPosition));
    float sf = pow(df, materialBuffer.shininess);
    float3 color = df * in.color.rgb + sf * materialBuffer.specular;
    return float4( color * alpha, alpha );
    
    //"    vec2 texcoord;"
    //"    texcoord.x = gl_PointCoord.x * varTexCoord2.x + varTexCoord.x;"
    //"    texcoord.y = gl_PointCoord.y * varTexCoord2.y + varTexCoord.y;"
    //"    vec4 normalMap = texture2D(TextureID, texcoord);"
    //"    float alpha;"
    //"    if (ShaderFlags == 1) {" // DiscardEnabled
    //"        if (normalMap.a < 0.25) { discard; }"
    //"        alpha = varColor.a * Transparency;"
    //"    } else {" // exclude normalMap.a when DiscardEnabled
    //"        alpha = varColor.a * Transparency * normalMap.a;"
    //"    }"
    //"    // Scale and bias from [0, 1] to [-1, 1] and normalize\n"
    //"    vec3 normalXYZ = normalMap.xyz * 2.0 - 1.0;"
    //"    vec3 N = normalize(vec3(0.0, 0.0, 1.0)+normalXYZ);"
    //"    float df = max(0.0, dot(N, LightPosition));"
    //"    float sf = pow(df, Shininess);"
    //"    vec3 color = df * varColor.bgr + sf * Specular;"
    //"    gl_FragColor = vec4(color * alpha, alpha);"
}

//-------------------------------------------------------------
//  MultiTextureShader

vertex RasterizerDataXYZT
MetalMultiTextureShaderVS(uint vertexID [[vertex_id]],
                          constant MetalVertXYZT *vertices [[buffer(MetalVSVertices)]],
                          constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalMultiTextureShaderPS(RasterizerDataXYZT in [[stage_in]],
                                          texture2d<float> diffuseTexture1 [[texture(0)]],
                                          sampler samplr1 [[sampler(0)]],
                                          texture2d<float> diffuseTexture2 [[texture(1)]],
                                          sampler samplr2 [[sampler(1)]],
                                          constant MetalMaterialBuffer & materialBuffer [[buffer(0)]])
{
    float4 texColor1 = diffuseTexture1.sample(samplr1, in.texCoord).rgba;
    float4 texColor2 = diffuseTexture2.sample(samplr2, in.texCoord).rgba;
    float4 blendColor = (texColor1 * materialBuffer.blend) + (texColor2 * (1.0 - materialBuffer.blend));
    float alpha = blendColor.a * materialBuffer.transparency;
    return float4( blendColor.rgb * alpha, alpha );
    
    //"    vec4 texColor1 = texture2D(TextureID, varTexCoord);"
    //"    vec4 texColor2 = texture2D(BlendTextureID, varTexCoord);"
    //"    vec4 blendColor = (texColor1 * BlendValue) + (texColor2 * (1.0 - BlendValue));"
    //"    float alpha = blendColor.a * Transparency;"
    //"    gl_FragColor = vec4(blendColor.xyz * alpha, alpha);"
}


//-------------------------------------------------------------
// Debug shaders
//-------------------------------------------------------------

//-------------------------------------------------------------
//  DebugVertexColorShader
vertex RasterizerDataXYZCT
MetalDebugVertexColorShaderVS(uint vertexID [[vertex_id]],
                              constant MetalVertXYZCT * vertices [[buffer(MetalVSVertices)]])
{
    RasterizerDataXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = modelPosition;
    out.color = vertices[vertexID].color;
    
    return out;
}

// Pixel shader
fragment float4 MetalDebugVertexColorShaderPS(RasterizerDataXYZCT in [[stage_in]])
{
    return float4( in.color.rgb, 1.0 );
}

//-------------------------------------------------------------
//  DebugTextureShader

vertex RasterizerDataXYZCT
MetalDebugTextureShaderVS(uint vertexID [[vertex_id]],
                          constant MetalVertXYZCT *vertices [[buffer(MetalVSVertices)]],
                          constant float4x4 *mvp [[buffer(MetalVSMVP)]])
{
    RasterizerDataXYZCT out;
    
    float4 modelPosition;
    modelPosition.xyz = vertices[vertexID].position.xyz;
    modelPosition.w = 1.0f;
    out.position = (*mvp) * modelPosition;
    out.color = vertices[vertexID].color;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 MetalDebugTextureShaderPS(RasterizerDataXYZCT in [[stage_in]],
                                          texture2d<float> diffuseTexture [[texture(0)]],
                                          sampler samplr [[sampler(0)]])
{
    float4 texColor = diffuseTexture.sample(samplr, in.texCoord).rgba;
    return float4( texColor.rgb, 1.0 );
}

//-------------------------------------------------------------
//-------------------------------------------------------------
