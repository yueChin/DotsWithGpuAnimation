using System.Collections.Generic;
using Unity.Collections;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Rendering;
using Unity.Transforms;
using UnityEngine;

namespace MultiGPUSkinningWithDOTS.Scripts.ECS.System.Test
{

    public class SpawnerAuthoring_FromEntity : MonoBehaviour, IDeclareReferencedPrefabs, IConvertGameObjectToEntity
    {
        public GameObject Prefab;
        public int CountX;
        public int CountY;

        // Referenced prefabs have to be declared so that the conversion system knows about them ahead of time
        public void DeclareReferencedPrefabs(List<GameObject> referencedPrefabs)
        {
            referencedPrefabs.Add(Prefab);
        }

        // Lets you convert the editor data representation to the entity optimal runtime representation
        public void Convert(Entity entity, EntityManager dstManager, GameObjectConversionSystem conversionSystem)
        {
            Spawner_FromEntity2 spawnerData = new Spawner_FromEntity2
            {
                // The referenced prefab will be converted due to DeclareReferencedPrefabs.
                // So here we simply map the game object to an entity reference to that prefab.
                //Prefab = conversionSystem.GetPrimaryEntity(Prefab),
                CountX = CountX,
                CountY = CountY,
            };
            
            DataSave save = this.GetComponent<DataSave>();
            EntityArchetype treeType = dstManager.CreateArchetype(
                typeof(RenderMesh), // Rendering mesh
                typeof(LocalToWorld), // Needed for rendering
                typeof(Translation), // Transform position
                typeof(Rotation), // Transform rotation
                typeof(Scale), // Transform scale (version with X, Y and Z)          
                typeof(RenderBounds), //Bounds to tell the Renderer where it is
                typeof(MeshLODComponent) //The actual LOD Component
            );

            Entity childOfGroup = dstManager.CreateEntity(treeType);
            RenderMesh renderMesh = new RenderMesh
            {
                mesh = save.LODMesh,
                material = save.DrawMaterial,
                subMesh = 0,
                castShadows = UnityEngine.Rendering.ShadowCastingMode.Off,
                receiveShadows = false,
            };
            
            RenderBounds bounds = new RenderBounds
            {
                Value = GetBoxRenderBounds(new float3(1, 1, 1))
            };


            dstManager.SetSharedComponentData(childOfGroup, renderMesh);

            dstManager.SetComponentData(childOfGroup, new LocalToWorld() { Value = float4x4.TRS(float3.zero, quaternion.identity, new float3(1, 1, 1)) });
            dstManager.SetComponentData(childOfGroup, new Translation() { Value = float3.zero });
            dstManager.SetComponentData(childOfGroup, bounds);

            spawnerData.Prefab = childOfGroup;
            dstManager.AddComponentData(entity, spawnerData);
            //dstManager.AddComponent<MeshRenderer>(childOfGroup);
        }
        
        AABB GetBoxRenderBounds(float3 size)
        {
            AABB aabb = new AABB();
            aabb.Center = float3.zero;
            aabb.Extents = size;
            return aabb;
        }
        
        // public struct Asset
        // {
        //     public float3 position;
        // }
        //
        // public struct WaypointBlobAsset
        // {
        //     public BlobArray<Waypoint> blobArray;
        // }
        //
        // BlobAssetReference<Entity> GeneratorEntityArr(Entity baseData)
        // {
        //     using (BlobBuilder blobBuilder = new BlobBuilder(Unity.Collections.Allocator.Temp))
        //     {
        //         ref WaypointBlobAsset waypointBlobAsset = ref blobBuilder.ConstructRoot<WaypointBlobAsset>();
        //         BlobBuilderArray<Waypoint> blobBuilderArray = blobBuilder.Allocate(ref waypointBlobAsset.blobArray, 8);
        //
        //
        //
        //         blobBuilderArray[0] = new Waypoint { position = new float3(10, 0, 0) };
        //         blobBuilderArray[1] = new Waypoint { position = new float3(10, 0, 10) };
        //         blobBuilderArray[2] = new Waypoint { position = new float3(0, 0, 10) };
        //         blobBuilderArray[3] = new Waypoint { position = new float3(-10, 0, 10) };
        //         blobBuilderArray[4] = new Waypoint { position = new float3(-10, 0, 0) };
        //         blobBuilderArray[5] = new Waypoint { position = new float3(-10, 0, -10) };
        //         blobBuilderArray[6] = new Waypoint { position = new float3(0, 0, -10) };
        //         blobBuilderArray[7] = new Waypoint { position = new float3(10, 0, -10) };
        //
        //         blobAssetReference = blobBuilder.CreateBlobAssetReference<WaypointBlobAsset>(Unity.Collections.Allocator.Persistent);
        //     }
        // }
    }
}