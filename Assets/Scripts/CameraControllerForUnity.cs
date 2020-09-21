using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class CameraControllerForUnity : MonoBehaviour
{
    public Transform followtarget;
    public Transform ca;
    public Camera came;
    private Vector3 triniPivot;

    [Header("第三人称镜头距离")]
    public float curdis;
    public float targetdis;
    [Header("三 一 moba")]
    public int mode = 0;
    [Header("第三人称镜头角度 注意xy是反的")]
    public float xAngle, yAngle;
    float xspeed = 2;
    float yspeed = 2;

    [Header("第三人称镜头限制")]
    public float limitYmin = 45;
    public float limitYmax = 75;
    [Header("第三人称镜头最远 moba高度")]
    public float heightmax = 3000;

    [Header("第一人称fov")]
    public float targetfov;

    Quaternion rot;
    Quaternion pivotRot;

    void Start()
    {
        triniPivot = transform.rotation.eulerAngles;
        yAngle = triniPivot.x;
        xAngle = triniPivot.y;
        ca.LookAt(transform.position);
        targetdis = curdis = Vector3.Distance(transform.position, ca.position);
        targetfov = came.fieldOfView;
    }

    float mousex;
    float mousey;
    float mousez;
    void LateUpdate()
    {
        if (EventSystem.current && EventSystem.current.IsPointerOverGameObject())
        {
            mousex = 0;
            mousey = 0;
            mousez = 0;
        }
        else
        {
            mousex = Input.GetAxis("Mouse X");
            mousey = Input.GetAxis("Mouse Y");
            mousez = Input.GetAxis("Mouse ScrollWheel");
        }

        #region 旋转
        //当不为moba视角可旋转
        if (Input.GetMouseButton(1) && (mode == 0 || mode == 1))
        {
            xAngle += mousex * xspeed;
            yAngle -= mousey * yspeed;
        }
        rot = Quaternion.Euler(0f, xAngle, 0f);
        yAngle = Mathf.Clamp(yAngle, -limitYmin, limitYmax);
        pivotRot = Quaternion.Euler(yAngle, triniPivot.y, triniPivot.z);
        //m_Pivot.localRotation = Quaternion.Slerp(m_Pivot.localRotation, m_PivotTargetRot, m_TurnSmoothing * 0.02f);
        transform.localRotation = Quaternion.Slerp(transform.localRotation, rot * pivotRot, 5 * 0.02f);
        #endregion

        #region 视角缩进，拉远，跟随
        if (mode == 0 || mode == 2)
        {
            if (mousez != 0)
            {
                //相机离的越远越快
                targetdis = Mathf.Clamp(curdis + mousez * (curdis * 0.66f + 6.6f), 1, heightmax);
            }
            curdis = Mathf.Lerp(curdis, targetdis, 5 * 0.02f);
            ca.position = transform.position - ca.forward.normalized * curdis;
            //跟随
            if (followtarget)
            {
                transform.position = Vector3.Lerp(transform.position, followtarget.position, 1);
                //transform.position = followtarget.position ;
            }
        }
        else if (mode == 1)
        {
            //第一人称跟随
            if (followtarget)
            {
                transform.position = followtarget.position;
                //第一视角锁死下  可变fov
                targetfov += mousez * 3;
            }
            else
            {
                transform.position -= (transform.forward).normalized * mousez * 3;
            }
            ca.position = transform.position + ca.forward.normalized;
        }
        came.fieldOfView = Mathf.Lerp(came.fieldOfView, targetfov, 0.2f);
        #endregion

        #region 视角平移
        if (mode != 2)
        {
            if (Input.GetMouseButton(2))
            {
                if (followtarget)
                    return;
                if (mode == 1)
                {
                    mousex = -mousex;
                    mousey = -mousey;
                }
                Vector3 move = new Vector3(mousex, mousey, 0) * curdis * 0.03f;
                transform.Translate(move, Space.Self);
            }
        }
        else if (mode == 2)
        {
            //moba模式不允许移动y轴
            if (Input.GetMouseButton(2) || Input.GetMouseButton(0))
            {
                if (followtarget)
                    return;
                //Vector3 move = new Vector3(x, 0, y);
                Vector3 forward = transform.forward.normalized;
                forward.y = 0;
                Vector3 right = transform.right.normalized;
                right.y = 0;
                //视角越远 移动越快
                transform.position += forward * curdis * 0.06f * mousey;
                transform.position += right * curdis * 0.03f * mousex;
            }
        }
        #endregion
    }

    public void MobaFollow(Transform target, Vector2 angle, float dis)
    {
        mode = 2;
        followtarget = target;
        xAngle = angle.y;
        yAngle = angle.x;
        targetdis = dis < 1 ? 1 : dis;
        targetfov = 60;
    }

    public void Mobafocus(Vector3 pos, Vector2 angle, float dis)
    {
        mode = 2;
        followtarget = null;
        transform.position = pos;
        xAngle = angle.y;
        yAngle = angle.x;
        targetdis = dis < 1 ? 1 : dis;
        targetfov = 60;
    }

    public void Mobafocus(Vector2 angle, float dis)
    {
        Mobafocus(transform.position, angle, dis);
    }

    public void Thirdfocus(Vector3 pos, Vector2 angle, float dis)
    {
        mode = 0;
        followtarget = null;
        transform.position = pos;
        xAngle = angle.y;
        yAngle = angle.x;
        targetdis = dis < 1 ? 1 : dis;
        targetfov = 60;
    }

    public void Thirdfocus(Vector2 angle, float dis)
    {
        Thirdfocus(transform.position, angle, dis);
    }

    public void ThirdFollow(Transform target, Vector2 angle, float dis)
    {
        mode = 0;
        followtarget = target;
        xAngle = angle.y;
        yAngle = angle.x;
        targetdis = dis < 1 ? 1 : dis;
        targetfov = 60;
    }

    public void Firstfocus()
    {
        mode = 1;
        followtarget = null;
        targetfov = 60;
    }

    public void FirstFllow(Transform target, Vector2 angle)
    {
        mode = 1;
        followtarget = target;
        targetfov = 60;
        xAngle = angle.y;
        yAngle = angle.x;
    }
}
#if UNITY_EDITOR

[CustomEditor(typeof(CameraControllerForUnity))]
public class CameraControllerE : Editor
{
    Transform targetforca;
    Vector2 angle;
    float dis;
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        EditorGUILayout.Space();
        EditorGUILayout.PrefixLabel("以下为测试变量");
        targetforca = EditorGUILayout.ObjectField("target", targetforca, typeof(Transform), true) as Transform;
        angle = EditorGUILayout.Vector2Field("angle", angle);
        dis = EditorGUILayout.FloatField("dis", dis);
        if (GUILayout.Button("第三人称切换"))
        {
            (target as CameraControllerForUnity).ThirdFollow(targetforca, angle, dis);
        }
        if (GUILayout.Button("第一人称切换"))
        {
            (target as CameraControllerForUnity).FirstFllow(targetforca, angle);
        }
        if (GUILayout.Button("moba切换"))
        {
            (target as CameraControllerForUnity).MobaFollow(targetforca, angle, dis);
        }
    }
}

#endif
