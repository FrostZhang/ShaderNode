using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Test : MonoBehaviour
{
    public CameraControllerForUnity ca;

    public Transform p1, p2, p3;
    void Start()
    {
        ca.ThirdFollow(transform, new Vector2(35, 0), 15);
    }

    // Update is called once per frame
    void Update()
    {
        transform.position += transform.forward.normalized * 50 * Time.deltaTime;
    }

    private void OnDrawGizmos()
    {
        var vs = BezierUtils.GetBeizerList(p1.position, p3.position, p2.position, 10);
        for (int i = 0; i < vs.Length; i++)
        {
            if (i != vs.Length - 1)
            {
                Gizmos.color = Color.red;
                Gizmos.DrawLine(vs[i], vs[i + 1]);
            }
        }
    }
}
