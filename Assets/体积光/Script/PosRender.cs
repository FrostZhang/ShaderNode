using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Copyright (C) $year$ All Rights Reserved.
// Detail：$safeitemname$	$username$	$time$
// Version：1.0.0
public class PosRender : MonoBehaviour
{
    public Light lit;
    public MeshFilter[] meshFilters;
    public Shader shader;
    public Material[] materials;
    public Mesh lightmesh;

    public List<IPostRender> postRenders = new List<IPostRender>();
    void Awake()
    {
        materials = new Material[meshFilters.Length];
        for (int i = 0; i < materials.Length; i++)
        {
            materials[i] = new Material(shader);
        }
    }

    public void Regist(IPostRender postRender)
    {
        postRenders.Add(postRender);
    }

    public void Remove(IPostRender postRender)
    {
        postRenders.Remove(postRender);
    }

    void OnPostRender()
    {
        if (!enabled)
        {
            return;
        }
        foreach (var item in postRenders)
        {
            item.OnPostRender();
        }
        Vector4 lightPos;
        if (lit.type == LightType.Directional)
        {
            Vector3 dir = lit.transform.forward;
            dir = lit.transform.InverseTransformDirection(dir);
            lightPos = new Vector4(dir.x, dir.y, -dir.z, 0);
        }
        else
        {
            Vector3 dir = lit.transform.forward;
            dir = lit.transform.InverseTransformPoint(dir);
            lightPos = new Vector4(dir.x, dir.y, -dir.z, 1);
        }
        for (int i = 0; i < meshFilters.Length; i++)
        {
            DrawShaft(meshFilters[i], lightPos, materials[i]);
        }
    }

    private void DrawShaft(MeshFilter meshFilter, Vector4 lightPos, Material material)
    {
        material.SetVector("litPos", lightPos);
        Mesh mesh = meshFilter.sharedMesh;
        material.SetPass(0);
        Graphics.DrawMeshNow(mesh, meshFilter.transform.localToWorldMatrix);
    }
}
