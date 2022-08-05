#ifndef GPUSKINNING_SURFACE_INPUT_INCLUDE
#define GPUSKINNING_SURFACE_INPUT_INCLUDE

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/API/D3D11.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders//LitInput.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

#define UNITY_INITIALIZE_OUTPUT(type,name) name = (type)0;

//float4    _Color;
// half    _Cutoff;
//
// TEXTURE2D(_BaseMap);
// SAMPLER(sampler_BaseMap);
// float4    _BaseMap_ST;
// TEXTURE2D(_EmissionMap);
// SAMPLER(sampler_EmissionMap);
// half4    _EmissionColor;
//
// TEXTURE2D(_SpecGlossMap);
// SAMPLER(sampler_SpecGlossMap);
// TEXTURE2D(_MetallicGlossMap);
// SAMPLER(sampler_MetallicGlossMap);
// half    _Metallic;
float   _GlossMapScale;
float   _Glossiness;
// float4  _SpecColor;
//
// TEXTURE2D(_OcclusionMap);
// SAMPLER(sampler_OcclusionMap);
// half    _OcclusionStrength;
//
// TEXTURE2D(_BumpMap);
// SAMPLER(sampler_BumpMap);
// half    _BumpScale;
//
// TEXTURE2D(_DetailMask);
// SAMPLER(sampler_DetailMask);
// TEXTURE2D(_DetailNormalMap);
// SAMPLER(sampler_DetailNormalMap);
// half    _DetailNormalMapScale;

half Alpha(float2 uv)
{
    #if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
        return _BaseColor.a;
    #else
        return SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,0).a * _BaseColor.a;
    #endif
}

struct SurfaceOutputStandard
{
    half3 Albedo;      // base (diffuse or specular) color
    float3 Normal;      // tangent space normal, if written
    half3 Emission;
    half Metallic;      // 0=non-metal, 1=metal
    // Smoothness is the user facing name, it should be perceptual smoothness but user should not have to deal with it.
    // Everywhere in the code you meet smoothness it is perceptual smoothness
    half Smoothness;    // 0=rough, 1=smooth
    half Occlusion;     // occlusion (default 1)
    half Alpha;        // alpha for transparencies
};

struct SurfaceOutputStandardSpecular
{
    half3 Albedo;      // diffuse color
    half3 Specular;    // specular color
    float3 Normal;      // tangent space normal, if written
    half3 Emission;
    half Smoothness;    // 0=rough, 1=smooth
    half Occlusion;     // occlusion (default 1)
    half Alpha;        // alpha for transparencies
};

half3 Emission(float2 uv)
{
    #ifndef _EMISSION
        return 0;
    #else
        return SAMPLE_TEXTURE2D(_EmissionMap,sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
    #endif
}


half2 MetallicGloss(float2 uv)
{
    half2 mg;

    #ifdef _METALLICGLOSSMAP
        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
         mg.r = tex2D(_MetallicGlossMap, uv).r;
            mg.g = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, uv).a;
        #else
            mg = SAMPLE_TEXTURE2D(_MetallicGlossMap,sampler_MetallicGlossMap, uv).ra;
        #endif
        mg.g *= _GlossMapScale;
    #else
        mg.r = _Metallic;
        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            mg.g = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, uv).a * _GlossMapScale;
        #else
            mg.g = _Glossiness;
        #endif
    #endif
    return mg;
}

half LerpOneTo(half b, half t)
{
    half oneMinusT = 1 - t;
    return oneMinusT + b * t;
}

half Occlusion(float2 uv)
{
    #if (SHADER_TARGET < 30)
    // SM20: instruction count limitation
    // SM20: simpler occlusion
        return SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap,uv).g;
    #else
        half occ = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_OcclusionMap,uv).g;
        return LerpOneTo (occ, _OcclusionStrength);
    #endif
}

float3 NormalizePerPixelNormal (float3 n)
{
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        return n;
    #else
        return normalize((float3)n); // takes float to avoid overflow
    #endif
}

half4 SpecularGloss(float2 uv)
{
    half4 sg;
    #ifdef _SPECGLOSSMAP
       #if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
            sg.rgb = SAMPLE_TEXTURE2D(_SpecGlossMap, sampler_SpecGlossMap,uv).rgb;
            sg.a = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,uv).a;
        #else
            sg = SAMPLE_TEXTURE2D(_SpecGlossMap, sampler_SpecGlossMap,uv);
        #endif
    sg.a *= _GlossMapScale;
    #else
        sg.rgb = _SpecColor.rgb;
        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            sg.a = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,uv).a * _GlossMapScale;
        #else
            sg.a = _Glossiness;
        #endif
    #endif
    return sg;
}

half DetailMask(float2 uv)
{
    return SAMPLE_TEXTURE2D (_DetailMask, sampler_DetailMask,uv).a;
}

half3 UnpackScaleNormalRGorAG(half4 packednormal, half bumpScale)
{
    #if defined(UNITY_NO_DXT5nm)
        half3 normal = packednormal.xyz * 2 - 1;
    #if (SHADER_TARGET >= 30)
    // SM2.0: instruction count limitation
    // SM2.0: normal scaler is not supported
        normal.xy *= bumpScale;
    #endif
        return normal;
    #else
    // This do the trick
    packednormal.x *= packednormal.w;

    half3 normal;
    normal.xy = (packednormal.xy * 2 - 1);
    #if (SHADER_TARGET >= 30)
    // SM2.0: instruction count limitation
    // SM2.0: normal scaler is not supported
        normal.xy *= bumpScale;
    #endif
        normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
    return normal;
    #endif
}

half3 UnpackScaleNormal(half4 packednormal, half bumpScale)
{
    return UnpackScaleNormalRGorAG(packednormal, bumpScale);
}

#ifdef _NORMALMAP
half3 BlendNormals(half3 n1, half3 n2)
{
    return normalize(half3(n1.xy + n2.xy, n1.z*n2.z));
}

half3 NormalInTangentSpace(float4 texcoords)
{
    half3 normalTangent = UnpackScaleNormal(SAMPLE_TEXTURE2D (_BumpMap,sampler_BumpMap, texcoords.xy), _BumpScale);

    #if _DETAIL && defined(UNITY_ENABLE_DETAIL_NORMALMAP)
    half mask = DetailMask(texcoords.xy);
    half3 detailNormalTangent = UnpackScaleNormal(SAMPLE_TEXTURE2D (_DetailNormalMap,sampler_DetailNormalMap ,texcoords.zw), _DetailNormalMapScale);
    #if _DETAIL_LERP
    normalTangent = lerp(
        normalTangent,
        detailNormalTangent,
        mask);
    #else
    normalTangent = lerp(
        normalTangent,
        BlendNormals(normalTangent, detailNormalTangent),
        mask);
    #endif
    #endif

    return normalTangent;
}
#endif

#define UNITY_OPAQUE_ALPHA(outputAlpha) outputAlpha = 1.0

half4 OutputForward (half4 output, half alphaFromSurface)
{
    #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
        output.a = alphaFromSurface;
    #else
        UNITY_OPAQUE_ALPHA(output.a);
    #endif
    return output;
}

#endif