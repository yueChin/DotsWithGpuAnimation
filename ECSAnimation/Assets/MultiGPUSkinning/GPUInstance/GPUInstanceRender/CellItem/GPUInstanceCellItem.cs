using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace GFrame.GPUInstance
{
    //一个cellitem表示一段动画比如跑，走啥的
    public class GPUInstanceCellItem
    {
        public Vector3 pos;
        public Quaternion rotation;
        public Vector3 scale;

        public int cellIndex;
    }
}