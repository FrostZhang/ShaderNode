using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// Copyright (C) $year$ All Rights Reserved.
// Detail：$safeitemname$	$username$	$time$
// Version：1.0.0
public class ShouDianTong : MonoBehaviour, IPostRender
{
    public Material material;
    public MeshFilter meshFilter;
    public Mesh mesh;
    public Light spot;

    public Color color;

    public void Start()
    {
        var r = FindObjectOfType<PosRender>();
        if (r)
        {
            r.Regist(this);
        }
    }

    public void OnPostRender()
    {
        var dir = transform.InverseTransformDirection(transform.forward);
        var lightPos = new Vector4(dir.x, dir.y, -dir.z, 0);
        material.SetVector("litPos", lightPos);
        Mesh mesh = meshFilter.sharedMesh;
        material.SetPass(0);
        if (this.mesh)
        {
            mesh = this.mesh;
        }
        Graphics.DrawMeshNow(mesh, meshFilter.transform.localToWorldMatrix);

        spot.color = color;
        material.SetColor("_Color", color);
    }
}
