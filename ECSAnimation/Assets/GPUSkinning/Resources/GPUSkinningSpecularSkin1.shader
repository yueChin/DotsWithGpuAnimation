Shader "GPUSkinning/GPUSkinning_Specular_Skin1"
{
    Properties
    {
		_BaseColor("Color", Color) = (1,1,1,1)
		_BaseMap("Albedo", 2D) = "white" {}
		
		_Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

		_Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
		_GlossMapScale("Smoothness Factor", Range(0.0, 1.0)) = 1.0
		[Enum(Specular Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

		_SpecColor("Specular", Color) = (0.2,0.2,0.2)
		_SpecGlossMap("Specular", 2D) = "white" {}
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

		_BumpScale("Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}

		_Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
		_ParallaxMap ("Height Map", 2D) = "black" {}

		_OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
		_OcclusionMap("Occlusion", 2D) = "white" {}

		_EmissionColor("Color", Color) = (0,0,0)
		_EmissionMap("Emission", 2D) = "white" {}
		
		_DetailMask("Detail Mask", 2D) = "white" {}

		_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
		_DetailNormalMapScale("Scale", Float) = 1.0
		_DetailNormalMap("Normal Map", 2D) = "bump" {}

		[Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0


		// Blending state
		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _SrcBlend ("__src", Float) = 1.0
		[HideInInspector] _DstBlend ("__dst", Float) = 0.0
		[HideInInspector] _ZWrite ("__zw", Float) = 1.0
    }
 
//HLSLPROGRAM
    // You may define one of these to expressly specify it.
    // #define UNITY_BRDF_PBS BRDF1_Unity_PBS
    // #define UNITY_BRDF_PBS BRDF2_Unity_PBS
    // #define UNITY_BRDF_PBS BRDF3_Unity_PBS
 
    // You can reduce the time to compile by constraining the usage of eash features.
    // Corresponding shader_feature pragma should be disabled.
    // #define _NORMALMAP 1
    // #define _ALPHATEST_ON 1
    // #define _EMISSION 1
    // #define _METALLICGLOSSMAP 1
    // #define _DETAIL_MULX2 1
//ENDHLSL
 
    SubShader
    {
        Tags 
    	{
    		"RenderType"="Opaque"
    		"PerformanceChecks"="False" 
    		"RenderPipeline" = "UniversalPipeline"
    	}
        LOD 300
 
        // It seems Blend command is getting overridden later
        // in the processing of  Surface shader.
        // Blend [_SrcBlend] [_DstBlend]
        ZWrite [_ZWrite]
 
    	Pass
		{
			HLSLPROGRAM
	        #pragma target 3.0
	        // TEMPORARY: GLES2.0 temporarily disabled to prevent errors spam on devices without textureCubeLodEXT
	        #pragma exclude_renderers gles
	 
	 
	        #pragma shader_feature _NORMALMAP
	        #pragma shader_feature _ALPHATEST_ON
	        #pragma shader_feature _EMISSION
	        #pragma shader_feature _SPECGLOSSMAP
	        #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON

	        #pragma skip_variants _PARALLAXMAP _DETAIL_MULX2

	        // may not need these (not sure)
	        // #pragma multi_compile_fwdbase
	        // #pragma multi_compile_fog
	 
	        //#pragma surface surfSpecular StandardSpecular vertex:myvert finalcolor:finalSpecular fullforwardshadows // Opaque or Cutout
	        // #pragma surface surfSpecular StandardSpecular vertex:vert finalcolor:finalSpecular fullforwardshadows alpha:fade // Fade
	        // #pragma surface surfSpecular StandardSpecular vertex:vert finalcolor:finalSpecular fullforwardshadows alpha:premul // Transparent

    		#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment
	    
			#pragma multi_compile_instancing
			#pragma multi_compile ROOTON_BLENDOFF ROOTON_BLENDON_CROSSFADEROOTON ROOTON_BLENDON_CROSSFADEROOTOFF ROOTOFF_BLENDOFF ROOTOFF_BLENDON_CROSSFADEROOTON ROOTOFF_BLENDON_CROSSFADEROOTOFF

			#include "Assets/GPUSkinning/Resources/GPUSkinningSkin.hlsl"
			Varyings LitPassVertex(Attributes input)
			{
			    Varyings output = (Varyings)0;

			    UNITY_SETUP_INSTANCE_ID(input);
			    UNITY_TRANSFER_INSTANCE_ID(input, output);
			    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

			    //skinning
			    {
			        float4 normal = float4(input.normalOS, 0);
			        float4 tangent = float4(input.tangentOS.xyz, 0);
			    
			        float4 pos = skin1(input.positionOS, input.uv1, input.uv2);
			        normal = skin1(normal, input.uv1, input.uv2);
			        tangent = skin1(tangent, input.uv1, input.uv2);
			    
			        input.positionOS = pos;
			        input.normalOS = normal.xyz;
			        input.tangentOS = float4(tangent.xyz, input.tangentOS.w);
			    }
			    
			    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

			    // normalWS and tangentWS already normalize.
			    // this is required to avoid skewing the direction during interpolation
			    // also required for per-vertex lighting and SH evaluation
			    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

			    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

			    half fogFactor = 0;
			    #if !defined(_FOG_FRAGMENT)
			        fogFactor = ComputeFogFactor(vertexInput.positionCS.z);
			    #endif

			    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

			    // already normalized from normal transform to WS.
			    output.normalWS = normalInput.normalWS;
			#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
			    real sign = input.tangentOS.w * GetOddNegativeScale();
			    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
			#endif
			#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
			    output.tangentWS = tangentWS;
			#endif

			#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
			    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
			    half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
			    output.viewDirTS = viewDirTS;
			#endif

			    OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
			#ifdef DYNAMICLIGHTMAP_ON
			    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
			#endif
			    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);
			#ifdef _ADDITIONAL_LIGHTS_VERTEX
			    output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
			#else
			    output.fogFactor = fogFactor;
			#endif

			#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
			    output.positionWS = vertexInput.positionWS;
			#endif

			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
			    output.shadowCoord = GetShadowCoord(vertexInput);
			#endif

			    output.positionCS = vertexInput.positionCS;

			    return output;
			}
			ENDHLSL
		}
        // For some reason SHADOWCASTER works. Not ShadowCaster.
        // UsePass "Standard/ShadowCaster"
        //UsePass "Standard/SHADOWCASTER"
    	UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
 
    FallBack Off
    CustomEditor "GPUSkinningStandardShaderGUI"
}