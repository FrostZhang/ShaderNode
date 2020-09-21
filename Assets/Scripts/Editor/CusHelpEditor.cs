using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using System;

public class CusHelpEditor : EditorWindow
{
    [MenuItem("Tools/Cus")]
    public static void Open()
    {
        GetWindow<CusHelpEditor>().Show();
    }

    private void OnEnable()
    {

    }


    Transform ob1, ob2;
    UnityEngine.Object file;
    private void OnGUI()
    {
        ob1 = EditorGUILayout.ObjectField("预制体", ob1, typeof(Transform), true) as Transform;
        ob2 = EditorGUILayout.ObjectField("主要", ob2, typeof(Transform), true) as Transform;
        if (GUILayout.Button("解析"))
        {
            foreach (Transform item in ob2)
            {
                PaseTrChildByOther(item, ob1, ob1);
            }
        }
        //Read();

        EditorGUI.BeginChangeCheck();
        {
            file = EditorGUILayout.ObjectField("", file, typeof(UnityEngine.Object), false);
        }
        if (EditorGUI.EndChangeCheck())
        {
            var path = AssetDatabase.GetAssetPath(file);
            var guid = AssetDatabase.AssetPathToGUID(path);
        }


        Prefab();
    }

    string path = "Assets";
    private void Prefab()
    {
        path = EditorGUILayout.TextField("路径", path);
        if (GUILayout.Button("制作"))
        {
            if (!Directory.Exists("Assets/old/"))
            {
                Directory.CreateDirectory("Assets/old/");
            }
            Chuli(path, (x) =>
            {
                string newpath = "Assets/old/" + Path.GetFileName(x);
                if (AssetDatabase.MoveAsset(x, newpath) == string.Empty)
                {
                    GameObject prefab = UnityEditor.AssetDatabase.LoadAssetAtPath(newpath,
typeof(GameObject)) as GameObject;
                    x = x.Replace("\\", "/");
                    UnityEditor.PrefabUtility.CreatePrefab(x, prefab);
                }
            });
        }
    }

    private void Chuli(string dir, Action<string> act)
    {
        var files = Directory.GetFiles(dir);
        foreach (var item in files)
        {
            if (Path.GetExtension(item) == ".prefab")
            {
                act(item);
            }
        }
        var dirs = Directory.GetDirectories(dir);
        foreach (var item in dirs)
        {
            Chuli(item, act);
        }
    }


    private static void PaseTrChildByOther(Transform main, Transform prefabpa, Transform prefab)
    {
        var filter = main.GetComponent<MeshFilter>();
        var trs = prefab.GetComponentsInChildren<Transform>();
        if (filter)
        {
            string name = null;
            if (filter.sharedMesh)
            {
                name = filter.sharedMesh.name.Replace(" Instance", string.Empty);
            }
            if (name == null)
            {
                Debug.Log(filter.sharedMesh + " " + filter.mesh);
                return;
            }
            //if (name != main.name)
            {
                var child = trs.FirstOrDefault(x => x.name == name);
                Debug.Log(child);
                if (child)
                {
                    child.name = main.name;
                    child.SetParent(prefabpa);
                    child.gameObject.SetActive(main.gameObject);
                    child.localPosition = main.localPosition;
                    child.localScale = main.localScale;
                    //child.localEulerAngles = GameUnlity.GetLocalRotationOrder(main);
                    foreach (Transform item in main)
                    {
                        PaseTrChildByOther(item, child, prefab);
                    }
                }
            }
        }
    }


}
