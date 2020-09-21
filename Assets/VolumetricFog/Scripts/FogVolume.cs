using UnityEngine;
using System.Collections;

namespace VolumetricFogAndMist {
				public class FogVolume : MonoBehaviour {

								const float GRAY = 227f / 255f;

								[Tooltip ("Enables alpha transition.")]
								public bool enableAlphaTransition = true;

								[Tooltip ("Target alpha for fog when camera enters this fog volume")]
								[Range (0, 1)]
								public float targetFogAlpha = 0.5f;
								[Tooltip ("Target alpha for sky haze when camera enters this fog volume")]
								[Range (0, 1)]
								public float targetSkyHazeAlpha = 0.5f;

								[Tooltip ("Enables fog color transition.")]
								public bool enableFogColorTransition;

								[Tooltip ("Target fog color 1 when gamera enters this fog folume")]
								public Color targetFogColor = new Color (GRAY, GRAY, GRAY);

								[Tooltip ("Enables fog specular color transition.")]
								public bool enableFogSpecularColorTransition;

								[Tooltip ("Target fog color 2 when gamera enters this fog folume")]
								public Color targetFogSpecularColor = new Color (GRAY, GRAY, GRAY);

								[Tooltip ("Enables light color transition.")]
								public bool enableLightColorTransition;

								[Tooltip ("Target light color when gamera enters this fog folume")]
								public Color targetLightColor = Color.white;

								[Tooltip ("Set this to zero for changing fog alpha immediately upon enter/exit fog volume.")]
								public float transitionDuration = 3.0f;

								[Tooltip ("Set collider that will trigger this fog volume. If not set, this fog volume will react to any collider which has the main camera. If you use a third person controller, assign the character collider here.")]
								public Collider targetCollider;

								bool cameraInside;
								VolumetricFog fog;

								void Start () {
												fog = VolumetricFog.instance;
								}

								void OnTriggerEnter (Collider other) {
												if (cameraInside)
																return;
												// Check if other collider has the main camera attached
												if (other == targetCollider || other.gameObject.transform.GetComponentInChildren<Camera> () == fog.fogCamera) {
																cameraInside = true;
																if (enableAlphaTransition) {
																				fog.SetTargetAlpha (targetFogAlpha, targetSkyHazeAlpha, transitionDuration);
																}
																if (enableFogColorTransition) {
																				fog.SetTargetColor (targetFogColor, transitionDuration);
																}
																if (enableFogSpecularColorTransition) {
																				fog.SetTargetSpecularColor (targetFogSpecularColor, transitionDuration);
																}
																if (enableLightColorTransition) {
																				fog.SetTargetLightColor (targetLightColor, transitionDuration);
																}
												}
								}

								void OnTriggerExit (Collider other) {
												if (!cameraInside)
																return;
												if (other == targetCollider || other.gameObject.transform.GetComponentInChildren<Camera> () == fog.fogCamera) {
																cameraInside = false;
																if (enableAlphaTransition)
																				fog.ClearTargetAlpha (transitionDuration);
																if (enableFogColorTransition)
																				fog.ClearTargetColor (transitionDuration);
																if (enableFogSpecularColorTransition)
																				fog.ClearTargetSpecularColor (transitionDuration);
																if (enableLightColorTransition)
																				fog.ClearTargetLightColor (transitionDuration);
												}
								}

				}

}