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
/// 烘焙后的数据
/// </summary>
public struct BakedData
{
    #region FIELDS

    private readonly string _name;
    // private readonly float _animLen;
    private readonly byte[] _rawAnimMap;
    private readonly int _animMapWidth;
    private readonly int _animMapHeight;
    private readonly string _jsonInfo;

    #endregion

    public BakedData(string name, Texture2D animTex, string jsonInfo)
    {
        _name = name;
        // _animLen = animLen;
        _animMapHeight = animTex.height;
        _animMapWidth = animTex.width;
        _rawAnimMap = animTex.GetRawTextureData();
        _jsonInfo = jsonInfo;
    }

    public int AnimMapWidth => _animMapWidth;

    public string Name => _name;

    // public float AnimLen => _animLen;

    public byte[] RawAnimMap => _rawAnimMap;

    public int AnimMapHeight => _animMapHeight;
    public string JsonInfo => _jsonInfo;
}