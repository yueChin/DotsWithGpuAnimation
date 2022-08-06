using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 判断动画本帧是否可执行的封装
/// </summary>
public class GPUSkinningExecuteOncePerFrame
{
    private int frameCount = -1;

    public bool CanBeExecute()
    {
        if (Application.isPlaying)
        {
            return frameCount != Time.frameCount;
        }
        else
        {
            return true;
        }
    }

    public void MarkAsExecuted()
    {
        if (Application.isPlaying)
        {
            frameCount = Time.frameCount;
        }
    }
}
