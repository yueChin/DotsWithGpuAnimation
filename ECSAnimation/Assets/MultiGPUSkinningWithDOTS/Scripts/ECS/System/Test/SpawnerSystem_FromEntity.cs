using System.Collections.Generic;
using Unity.Burst;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Transforms;
using UnityEngine;

//Mono挂载，并不直接生成，而是将数据存在该Entity上

[UpdateInGroup(typeof(InitializationSystemGroup))]
public partial class SpawnerSystem_FromEntity : SystemBase
{
    // BeginInitializationEntityCommandBufferSystem is used to create a command buffer which will then be played back
    // when that barrier system executes.
    // Though the instantiation command is recorded in the SpawnJob, it's not actually processed (or "played back")
    // until the corresponding EntityCommandBufferSystem is updated. To ensure that the transform system has a chance
    // to run on the newly-spawned entities before they're rendered for the first time, the SpawnerSystem_FromEntity
    // will use the BeginSimulationEntityCommandBufferSystem to play back its commands. This introduces a one-frame lag
    // between recording the commands and instantiating the entities, but in practice this is usually not noticeable.
    BeginInitializationEntityCommandBufferSystem m_EntityCommandBufferSystem;

    protected override void OnCreate()
    {
        // Cache the BeginInitializationEntityCommandBufferSystem in a field, so we don't have to create it every frame
        m_EntityCommandBufferSystem = World.GetOrCreateSystem<BeginInitializationEntityCommandBufferSystem>();
    }

    protected override void OnUpdate()
    {
        //Instead of performing structural changes directly, a Job can add a command to an EntityCommandBuffer to perform such changes on the main thread after the Job has finished.
        //Command buffers allow you to perform any, potentially costly, calculations on a worker thread, while queuing up the actual insertions and deletions for later.
        EntityCommandBuffer.ParallelWriter commandBuffer = m_EntityCommandBufferSystem.CreateCommandBuffer().AsParallelWriter();

        // Schedule the Entities.ForEach lambda job that will add Instantiate commands to the EntityCommandBuffer.
        // Since this job only runs on the first frame, we want to ensure Burst compiles it before running to get the best performance (3rd parameter of WithBurst)
        // The actual job will be cached once it is compiled (it will only get Burst compiled once).
        Entities
            .WithName("SpawnerSystem_FromEntity")
            .WithBurst(FloatMode.Default, FloatPrecision.Standard, true)
            .ForEach((Entity entity, int entityInQueryIndex, in Spawner_FromEntity spawnerFromEntity, in LocalToWorld location) =>
            {
                for (int x = 0; x < spawnerFromEntity.CountX; x++)
                {
                    for (int y = 0; y < spawnerFromEntity.CountY; y++)
                    {
                        Entity instance = commandBuffer.Instantiate(entityInQueryIndex, spawnerFromEntity.Prefab);

                        // Place the instantiated in a grid with some noise
                        float3 position = math.transform(location.Value,
                            new float3(x * 1.3F, noise.cnoise(new float2(x, y) * 0.21F) * 2, y * 1.3F));
                        commandBuffer.SetComponent(entityInQueryIndex, instance, new Translation {Value = position});
                    }
                }

                commandBuffer.DestroyEntity(entityInQueryIndex, entity);
            }).ScheduleParallel();

        // SpawnJob runs in parallel with no sync point until the barrier system executes.
        // When the barrier system executes we want to complete the SpawnJob and then play back the commands (Creating the entities and placing them).
        // We need to tell the barrier system which job it needs to complete before it can play back the commands.
        m_EntityCommandBufferSystem.AddJobHandleForProducer(Dependency);
    }
}

