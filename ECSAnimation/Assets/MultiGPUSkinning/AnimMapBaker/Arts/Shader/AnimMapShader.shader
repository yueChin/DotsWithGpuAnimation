/*
Created by jiadong chen
http://www.chenjd.me
*/

Shader "chenjd/AnimMapShader"
{
    Properties
    {
        _BaseMap ("Texture", 2D) = "white" { }
        _AnimMap ("AnimMap", 2D) = "white" { }
        _AnimLen ("Anim Length", Float) = 0
    }
    SubShader
    {
        Tags 
        {
             "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;

            TEXTURE2D(_AnimMap);
            SAMPLER(sampler_AnimMap);
            float4 _AnimMap_TexelSize;//x == 1/width

            float _AnimLen;

            
            v2f vert(appdata v, uint vid: SV_VertexID)//vid对应的就是
            {
                UNITY_SETUP_INSTANCE_ID(v);

                float f = _Time.y / _AnimLen;

                fmod(f, 1.0);

                float animMap_x = (vid + 0.5) * _AnimMap_TexelSize.x;
                float animMap_y = f;

                float4 pos = SAMPLE_TEXTURE2D_LOD(_AnimMap,sampler_AnimMap, float4(animMap_x, animMap_y, 0, 0),0);

                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                o.vertex = TransformObjectToHClip(pos);
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, i.uv);
                return col;
            }
            ENDHLSL
            
        }
    }
}
