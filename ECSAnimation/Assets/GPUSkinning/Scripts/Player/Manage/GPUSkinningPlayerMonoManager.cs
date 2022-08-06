using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//没明白为什么要多一个管理类
public class GPUSkinningPlayerMonoManager
{
    private List<GPUSkinningPlayerResources> m_ResourceList = new List<GPUSkinningPlayerResources>();

    public void Register(GPUSkinningAnimation anim, Mesh mesh, Material originalMtrl, TextAsset textureRawData, GPUSkinningPlayerMono player, out GPUSkinningPlayerResources resources)
    {
        resources = null;

        if (anim == null || originalMtrl == null || textureRawData == null || player == null)
        {
            return;
        }

        GPUSkinningPlayerResources tempResource = null;

        int numItems = m_ResourceList.Count;
        for(int i = 0; i < numItems; ++i)
        {
            if(m_ResourceList[i].anim.guid == anim.guid)
            {
                tempResource = m_ResourceList[i];
                break;
            }
        }

        if(tempResource == null)
        {
            tempResource = new GPUSkinningPlayerResources();
            m_ResourceList.Add(tempResource);
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

        int numItems = m_ResourceList.Count;
        for(int i = 0; i < numItems; ++i)
        {
            int playerIndex = m_ResourceList[i].players.IndexOf(player);
            if(playerIndex != -1)
            {
                m_ResourceList[i].players.RemoveAt(playerIndex);
                m_ResourceList[i].RemoveCullingBounds(playerIndex);
                if(m_ResourceList[i].players.Count == 0)
                {
                    m_ResourceList[i].Destroy();
                    m_ResourceList.RemoveAt(i);
                }
                break;
            }
        }
    }
}
