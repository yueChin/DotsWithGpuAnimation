using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Unity.Entities;
using Aoi.ECS;

public sealed class SwitchAnimBtn : MonoBehaviour
{
    public void OnClickBtn()
    {
        ECS_AnimatorEntityRenderingSystem renderingSys = World.DefaultGameObjectInjectionWorld.GetExistingSystem<ECS_AnimatorEntityRenderingSystem>();
        if (null != renderingSys)
        {
            renderingSys.SwitchAnim();
        }
    }
}