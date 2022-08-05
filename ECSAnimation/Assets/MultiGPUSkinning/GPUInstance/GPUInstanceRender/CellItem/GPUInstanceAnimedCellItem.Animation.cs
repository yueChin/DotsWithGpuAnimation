using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace GFrame.GPUInstance
{
    public partial class GPUInstanceAnimedCellItem : GPUInstanceCellItem
    {
        private class Animation
        {
            public float animStartRate { set; get; }
            public float animEndRate { set; get; }
            public float animRate { set; get; }

            private float m_Speed;

            public void InitTime(AnimMapClip clip)
            {
                animStartRate = (float)clip.startHeight / (float)s_AnimDataInfo.maxHeight;
                float totalRate = (float)clip.height / (float)s_AnimDataInfo.maxHeight;
                animEndRate = animStartRate + totalRate;
                m_Speed = 1.0f / clip.animLen * (animEndRate - animStartRate);
                Replay();
            }

            public bool IsEnd()
            {
                // return animRate>=1;
                return animRate >= animEndRate;
            }

            public void Trick()
            {
                animRate += Time.deltaTime * m_Speed;
            }

            public void Replay()
            {
                // animRate=0;
                animRate = animStartRate;
            }

        }
    }
}