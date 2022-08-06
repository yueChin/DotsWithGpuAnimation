using UnityEngine;
using System.Collections;

/// <summary>
/// gpu动画，骨骼集 和 动画clip集合 还有lod，包围盒巴拉巴拉
/// </summary>
public class GPUSkinningAnimation : ScriptableObject
{
    public string guid = null;

    public string animationName = null;

    public GPUSkinningBone[] bones = null;

    public int rootBoneIndex = 0;

    public GPUSkinningClip[] clips = null;

    public Bounds bounds;

    public int textureWidth = 0;

    public int textureHeight = 0;

    public float[] lodDistances = null;

    public Mesh[] lodMeshes = null;

    public float sphereRadius = 1.0f;
}
