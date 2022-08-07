using System.Collections.Generic;
using Unity.Burst;
using Unity.Entities;
using Unity.Jobs;
using Unity.Transforms;
using Unity.Mathematics;
using Unity.Rendering;
using UnityEngine;
using Random = Unity.Mathematics.Random;

/// <summary>
/// Author:Aoicocoon
/// Date:20200907
/// 实体生成系统
/// </summary>
namespace Aoi.ECS
{
    
    [UpdateInGroup(typeof(InitializationSystemGroup))]
    public partial class ECS_AnimatorEntitySpawnerSystem : SystemBase
    {
        BeginInitializationEntityCommandBufferSystem m_EntityCommandBufferSystem;

        protected override void OnCreate()
        {
            base.OnCreate();
            m_EntityCommandBufferSystem = World.GetOrCreateSystem<BeginInitializationEntityCommandBufferSystem>();
        }

        protected override void OnUpdate()
        {
            EntityCommandBuffer.ParallelWriter command = m_EntityCommandBufferSystem.CreateCommandBuffer().AsParallelWriter();

            //Instantiate 士兵预制体
            Entities.WithName("ECS_AnimatorEntitySpawnerSystem")
                .WithBurst(Unity.Burst.FloatMode.Default, Unity.Burst.FloatPrecision.Standard, true)
                .ForEach((Entity entity, int entityInQueryIndex, int nativeThreadIndex, in ECS_AnimatorSpawner spawner, in LocalToWorld location) =>
                {
                    int x = 0, y = 0;
                    //for (x = 0; x < spawner.CountX; x++)
                    {
                        //for (y = 0; y < spawner.CountY; y++)
                        {
                            Entity instance = command.Instantiate(entityInQueryIndex, spawner.PrefabEntity);
                            //Debug.LogError($"{11111111111}");
                            //Aniamtor出生位置
                            float3 position = math.transform(location.Value, new float3(x * 1.3F, 0, y * 1.3F));
                            command.SetComponent(entityInQueryIndex, instance, new Translation() { Value = position });

                            //模型部件分拆 需要独立实例化，比如骑兵的 马和人 是2个attach
                            for (int attach = 0; attach < spawner.AttachCount; attach++)
                            {
                                //初始化每个attach的 lod 网格
                                Entity lodEntity = Entity.Null;
                                for (int lod = 0; lod < 2; lod++)
                                {
                                    lodEntity = command.Instantiate(entityInQueryIndex, spawner.AttachLOD.Value.ArrayData[attach * 2 + lod]);

                                    //建立 MeshLODComponent-> 到 MeshLODGroup 的父子级关系
                                    command.SetComponent(entityInQueryIndex, lodEntity, new MeshLODComponent { Group = instance, LODMask = spawner.GetLODMask(lod) });
                                    //建立 AnimatorAttach-> 到 Animator 的父子级关系
                                    command.AddComponent(entityInQueryIndex, lodEntity, new ECS_SkinnedMatrixAnimatorAttach() { Parent = instance, AttachIndex = attach });
                                    command.AddComponent(entityInQueryIndex, lodEntity, new ECS_FrameDataMaterialPropertyComponent());
                                } 
                            }
                        }
                    }

                    //清理预制体
                    command.DestroyEntity(entityInQueryIndex, entity);
                    // command.DestroyEntity(entityInQueryIndex, spawner.Prefab);

                    for (int lod = 0; lod < spawner.AttachLOD.Value.ArrayData.Length; lod++)
                    {
                        command.DestroyEntity(entityInQueryIndex, spawner.AttachLOD.Value.ArrayData[lod]);
                    }
                }).ScheduleParallel();
            
            m_EntityCommandBufferSystem.AddJobHandleForProducer(this.Dependency);
        }
    }
}
