Shader "XHH/AnimMapShader"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _AnimMap ("AnimMap", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        Cull off

        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            //开启gpu instancing
            #pragma multi_compile_instancing


            //#include "UnityCG.cginc"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Macros.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
            
            struct appdata
            {
                float2 uv: TEXCOORD0;
                float4 pos: POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
                float f: TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;

            TEXTURE2D(_AnimMap);
            SAMPLER(sampler_AnimMap);
            float4 _AnimMap_TexelSize;//x == 1/width

            UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
            UNITY_DEFINE_INSTANCED_PROP(float, _AnimRate1)
            UNITY_DEFINE_INSTANCED_PROP(float, _AnimRate2)
            UNITY_DEFINE_INSTANCED_PROP(float, _AnimLerp)
            UNITY_INSTANCING_BUFFER_END(UnityPerMaterial);
            // float _AnimRate;
            
            half remap(half x, half t1, half t2, half s1, half s2)
            {
                return(x - t1) / (t2 - t1) * (s2 - s1) + s1;
            }

            v2f vert(appdata v, uint vid: SV_VertexID)//vid对应的就是
            {
                UNITY_SETUP_INSTANCE_ID(v);

                float animMap_y1 = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _AnimRate1);
                float animMap_y2 = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _AnimRate2);
                float animLerp = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _AnimLerp);

                float animMap_x = (vid + 0.5) * _AnimMap_TexelSize.x;
                
                float4 pos1 = SAMPLE_TEXTURE2D_LOD(_AnimMap,sampler_AnimMap, float4(animMap_x, animMap_y1, 0, 0),0);
                float4 pos2 = SAMPLE_TEXTURE2D_LOD(_AnimMap,sampler_AnimMap, float4(animMap_x, animMap_y2, 0, 0),0);

                float4 pos = lerp(pos1, pos2, animLerp);

                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.vertex = TransformObjectToHClip(pos.xyz);
                o.f = animLerp;
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                // return i.f;
                half4 col = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, i.uv);
                return col;
            }
            ENDHLSL
            
        }
    }
}
