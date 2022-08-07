using Unity.Entities;
using UnityEngine;

public struct Spawner_FromEntity : IComponentData
{
    public int CountX;
    public int CountY;
    public Entity Prefab;
}

public struct Spawner_FromEntity2 : IComponentData
{
    public int CountX;
    public int CountY;
    public Entity Prefab;
    public BlobAssetReference<Entity> Attach;
}