/*
 * 用来烘焙动作贴图。烘焙对象使用animation组件，并且在导入时设置Rig为Legacy
 */
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;
using System.IO;

/// <summary>
/// 烘焙器
/// </summary>
public class AnimMapBaker
{

    #region FIELDS

    private AnimToBakeData? _animData = null;
    private Mesh _bakedMesh;
    private readonly List<Vector3> _vertices = new List<Vector3>();
    private readonly List<BakedData> _bakedDataList = new List<BakedData>();

    #endregion

    #region METHODS

    public void SetAnimData(GameObject go)
    {
        if (go == null)
        {
            Debug.LogError("go is null!!");
            return;
        }

        Animation anim = go.GetComponent<Animation>();
        SkinnedMeshRenderer smr = go.GetComponentInChildren<SkinnedMeshRenderer>();

        if (anim == null || smr == null)
        {
            Debug.LogError("anim or smr is null!!");
            return;
        }
        _bakedMesh = new Mesh();
        _animData = new AnimToBakeData(anim, smr, go.name);
    }

    public List<BakedData> Bake()
    {
        if (_animData == null)
        {
            Debug.LogError("bake data is null!!");
            return _bakedDataList;
        }

        int totalHeight = 0;
        AnimDataInfo animDataInfo = new AnimDataInfo();
        //所有动作生成在一个动作图上面
        Debug.LogError($"AnimationClips.Count: {_animData.Value.AnimationClips.Count}");
        for (int i = 0; i < _animData.Value.AnimationClips.Count; i++)
        {
            AnimationState animationState = _animData.Value.AnimationClips[i];

            if (!animationState.clip.legacy)//因为是顶点动画所以只能是legacy
            {
                Debug.LogError(string.Format($"{animationState.clip.name} is not legacy!!"));
                continue;
            }
            Debug.LogError($"animationState.clip.frameRate: {animationState.clip.frameRate}       animationState.length:{ animationState.length}");
            int startHeight = totalHeight;
            int frameHeight = (int)(animationState.clip.frameRate * animationState.length);//得到动画总帧数
            totalHeight += frameHeight;

            float perFrameTime = animationState.length / frameHeight;
            AnimMapClip animMapClip = new AnimMapClip
            {
                startHeight = startHeight,
                height = frameHeight,
                // animMapClip.perFrameTime = perFrameTime;
                animLen = animationState.clip.length,
                name = animationState.name
            };
            animDataInfo.animMapClips.Add(animMapClip);
        }

        // totalHeight = Mathf.NextPowerOfTwo(totalHeight);
        animDataInfo.maxHeight = totalHeight;
        Texture2D animTex = new Texture2D(_animData.Value.MapWidth, totalHeight, TextureFormat.RGBAHalf, true)
        {
            name = string.Format($"{_animData.Value.Name}.animMap")
        };

        Debug.LogError(totalHeight);

        for (int i = 0; i < animDataInfo.animMapClips.Count; i++)
        {
            BakePerAnimClip(_animData.Value.AnimationClips[i], ref animTex, animDataInfo.animMapClips[i]);
        }
        animTex.Apply();
        //在生成一个动画信息文本
        string animInfoJson = JsonUtility.ToJson(animDataInfo);
        Debug.LogError(animInfoJson);

        _bakedDataList.Add(new BakedData(animTex.name, animTex, animInfoJson));
        return _bakedDataList;
    }

    private void BakePerAnimClip(AnimationState curAnim, ref Texture2D texture, AnimMapClip animMapClip)
    {
        float sampleTime = 0;
        float perFrameTime = 0;
        perFrameTime = curAnim.length / animMapClip.height;//得到单位时间的帧数
        _animData.Value.AnimationPlay(curAnim.name);

        for (int i = animMapClip.startHeight; i < animMapClip.startHeight + animMapClip.height; i++)
        {
            curAnim.time = sampleTime;

            _animData.Value.SampleAnimAndBakeMesh(ref _bakedMesh);
            for (int j = 0; j < _bakedMesh.vertexCount; j++)
            {
                Vector3 vertex = _bakedMesh.vertices[j];
                texture.SetPixel(j, i, new Color(vertex.x, vertex.y, vertex.z));
            }
            sampleTime += perFrameTime;
        }
        // texture.Apply();
    }
    #endregion


}

[System.Serializable]
public class AnimDataInfo
{
    public int maxHeight;
    public List<AnimMapClip> animMapClips = new List<AnimMapClip>();
}

[System.Serializable]
public struct AnimMapClip
{
    //起始高度
    public int startHeight;
    public int height;
    public string name;
    // public float perFrameTime;
    public float animLen;
}
