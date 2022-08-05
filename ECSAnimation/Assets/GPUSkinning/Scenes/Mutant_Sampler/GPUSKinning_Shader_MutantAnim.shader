Shader "GPUSkinning/GPUSkinning_Unlit_MutantAnim"
{
	Properties
	{
		_BaseMap ("Texture", 2D) = "white" {}
	}

	HLSLINCLUDE

	ENDHLSL

	SubShader
	{
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalPipeline"
        }
		LOD 200

		Pass
		{
			HLSLINCLUDE
			//#include "UnityCG.cginc"
			#include "Assets/GPUSkinning/Resources/GPUSkinningInclude.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 uv2 : TEXCOORD1;
				float4 uv3 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _BaseMap;
			float4 _BaseMap_ST;

			v2f vert(appdata v)
			{
				UNITY_SETUP_INSTANCE_ID(v);

				v2f o;
				
				float4 pos = skin2(v.vertex, v.uv2, v.uv3);
				o.vertex = TransformObjectToHClip(pos);
				o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half4 col = tex2D(_BaseMap, i.uv);
				return col;
			}
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma multi_compile ROOTON_BLENDOFF ROOTON_BLENDON_CROSSFADEROOTON ROOTON_BLENDON_CROSSFADEROOTOFF ROOTOFF_BLENDOFF ROOTOFF_BLENDON_CROSSFADEROOTON ROOTOFF_BLENDON_CROSSFADEROOTOFF
			ENDHLSL
		}
	}
}
