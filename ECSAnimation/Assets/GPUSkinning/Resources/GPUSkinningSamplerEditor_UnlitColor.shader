Shader "GPUSkinning/GPUSkinningSamplerEditor_UnlitColor"
{
	Properties
	{
		_BaseColor("Color", Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags 
		{
			 "RenderType"="Opaque" 
			"RenderPipeline" = "UniversalPipeline"
		}
		LOD 100

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			//#include "UnityCG.cginc"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			//#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/API/D3D11.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
			
			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			sampler2D _BaseMap;
			float4 _BaseMap_ST;

			half4 _BaseColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				return _BaseColor;
			}
			ENDHLSL
		}
	}
}
