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
/// 保存需要烘焙的动画的相关数据
/// </summary>
public struct AnimToBakeData
{
    #region FIELDS

    private int _vertexCount;
    private int _mapWidth;
    private readonly List<AnimationState> _animClips;
    private string _name;

    private Animation _animation;
    private SkinnedMeshRenderer _skin;

    public List<AnimationState> AnimationClips => _animClips;
    public int MapWidth => _mapWidth;
    public string Name => _name;

    #endregion

    public AnimToBakeData(Animation anim, SkinnedMeshRenderer smr, string goName)
    {
        _vertexCount = smr.sharedMesh.vertexCount;
        _mapWidth = Mathf.NextPowerOfTwo(_vertexCount);
        _animClips = new List<AnimationState>(anim.Cast<AnimationState>());
        _animation = anim;
        _skin = smr;
        _name = goName;
    }

    #region METHODS

    public void AnimationPlay(string animName)
    {
        _animation.Play(animName);
    }

    public void SampleAnimAndBakeMesh(ref Mesh m)
    {
        SampleAnim();
        BakeMesh(ref m);
    }

    private void SampleAnim()
    {
        if (_animation == null)
        {
            Debug.LogError("animation is null!!");
            return;
        }

        _animation.Sample();
    }

    private void BakeMesh(ref Mesh m)
    {
        if (_skin == null)
        {
            Debug.LogError("skin is null!!");
            return;
        }

        _skin.BakeMesh(m);
    }


    #endregion

}