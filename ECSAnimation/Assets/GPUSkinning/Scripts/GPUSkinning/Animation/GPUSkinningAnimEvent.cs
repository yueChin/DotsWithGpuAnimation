using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// 帧事件封装
/// </summary>
[System.Serializable]
public class GPUSkinningAnimEvent : System.IComparable<GPUSkinningAnimEvent>
{
    public int frameIndex = 0;

    public int eventId = 0;

    public int CompareTo(GPUSkinningAnimEvent other)
    {
        return frameIndex > other.frameIndex ? -1 : 1;
    }
}
