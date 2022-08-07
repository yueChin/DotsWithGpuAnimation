using Unity.Burst;
using Unity.Collections;
using Unity.Entities;
using Unity.Jobs;
using Unity.Mathematics;
using Unity.Rendering;
using Unity.Transforms;
using UnityEngine.Rendering;
using Random = Unity.Mathematics.Random;

/// <summary>
/// Author:Aoicocoon
/// Date:20200907
/// 实体渲染系统
/// </summary>
namespace Aoi.ECS
{
    [UpdateInGroup(typeof(SimulationSystemGroup))]
    [UpdateAfter(typeof(ECS_AnimatorEntityFrameDataCalcSystem))]
    public partial class ECS_AnimatorEntityRenderingSystem : SystemBase
    {
        private bool m_switchAnimIsDirty = false;

        public void SwitchAnim()
        {
            m_switchAnimIsDirty = true;
        }
        protected override void OnUpdate()
        {
            if (m_switchAnimIsDirty)
            {
                Random random = new Random((uint)UnityEngine.Time.frameCount);
                m_switchAnimIsDirty = false;

                Entities.WithName("ECS_AnimatorEntityRenderingSystem_switchAnim")
                .WithBurst(Unity.Burst.FloatMode.Default, Unity.Burst.FloatPrecision.Standard)
                .ForEach((ref AnimationData animData) =>
                {
                  animData.AnimationIndex = random.NextInt(0, animData.AnimCount);
                  animData.StartTime = random.NextFloat(0.0f, 1.0f);
                }).ScheduleParallel();
            }
        }
    }
}
