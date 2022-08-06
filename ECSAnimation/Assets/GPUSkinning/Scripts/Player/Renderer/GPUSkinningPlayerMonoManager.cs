using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//没明白为什么要多一个管理类
public class GPUSkinningPlayerMonoManager
{
    private List<GPUSkinningRender> m_RendererList = new List<GPUSkinningRender>();

    public void Register(GPUSkinningAnimation anim, Mesh mesh, Material originalMtrl, TextAsset textureRawData, GPUSkinningPlayerMono player, out GPUSkinningRender resources)
    {
        resources = null;

        if (anim == null || originalMtrl == null || textureRawData == null || player == null)
        {
            return;
        }

        GPUSkinningRender tempResource = null;

        int numItems = m_RendererList.Count;
        for(int i = 0; i < numItems; ++i)
        {
            if(m_RendererList[i].anim.guid == anim.guid)
            {
                tempResource = m_RendererList[i];
                break;
            }
        }

        if(tempResource == null)
        {
            tempResource = new GPUSkinningRender();
            m_RendererList.Add(tempResource);
        }

        if(tempResource.anim == null)
        {
            tempResource.anim = anim;
        }

        if(tempResource.mesh == null)
        {
            tempResource.mesh = mesh;
        }

        tempResource.InitMaterial(originalMtrl, HideFlags.None);

        if(tempResource.texture == null)
        {
            tempResource.texture = GPUSkinningUtil.CreateTexture2D(textureRawData, anim);
        }

        if (!tempResource.players.Contains(player))
        {
            tempResource.players.Add(player);
            tempResource.AddCullingBounds();
        }

        resources = tempResource;
    }

    public void Unregister(GPUSkinningPlayerMono player)
    {
        if(player == null)
        {
            return;
        }

        int numItems = m_RendererList.Count;
        for(int i = 0; i < numItems; ++i)
        {
            int playerIndex = m_RendererList[i].players.IndexOf(player);
            if(playerIndex != -1)
            {
                m_RendererList[i].players.RemoveAt(playerIndex);
                m_RendererList[i].RemoveCullingBounds(playerIndex);
                if(m_RendererList[i].players.Count == 0)
                {
                    m_RendererList[i].Destroy();
                    m_RendererList.RemoveAt(i);
                }
                break;
            }
        }
    }
}
