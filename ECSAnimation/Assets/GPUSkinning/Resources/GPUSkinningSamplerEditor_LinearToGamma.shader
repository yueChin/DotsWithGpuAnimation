Shader "GPUSkinning/GPUSkinningSamplerEditor_LinearToGamma"
{
	Properties
	{
		_BaseMap ("Texture", 2D) = "white" {}
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			
			sampler2D _BaseMap;
			float4 _BaseMap_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
				return o;
			}
			
			half4 frag (v2f i) : SV_Target
			{
				half4 col = tex2D(_BaseMap, i.uv);
				col.rgb = pow(abs(col.rgb), 1 / 2.2);
				col.a = 1;
				return col;
			}
			ENDHLSL
		}
	}
}
