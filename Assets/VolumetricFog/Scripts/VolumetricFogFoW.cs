//------------------------------------------------------------------------------------------------------------------
// Volumetric Fog & Mist
// Created by Ramiro Oliva (Kronnect)
//------------------------------------------------------------------------------------------------------------------
#define VOLUMETRIC_FOG_AND_MIST_PRESENT

using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

#if GAIA_PRESENT
using Gaia;
#endif


namespace VolumetricFogAndMist {

				public partial class VolumetricFog : MonoBehaviour {

								#region Fog of War settings

								[SerializeField]
								bool _fogOfWarEnabled;

								public bool fogOfWarEnabled {
												get { return _fogOfWarEnabled; }
												set {
																if (value != _fogOfWarEnabled) {
																				_fogOfWarEnabled = value;
																				FogOfWarUpdateTexture ();
																				UpdateMaterialProperties ();
																				isDirty = true;
																}
												}
								}

								[SerializeField]
								Vector3 _fogOfWarCenter;

								public Vector3 fogOfWarCenter {
												get { return _fogOfWarCenter; }
												set {
																if (value != _fogOfWarCenter) {
																				_fogOfWarCenter = value;
																				UpdateMaterialProperties ();
																				isDirty = true;
																}
												}
								}

								[SerializeField]
								Vector3 _fogOfWarSize = new Vector3 (1024, 0, 1024);

								public Vector3 fogOfWarSize {
												get { return _fogOfWarSize; }
												set {
																if (value != _fogOfWarSize) {
																				if (value.x > 0 && value.z > 0) {
																								_fogOfWarSize = value;
																								UpdateMaterialProperties ();
																								isDirty = true;
																				}
																}
												}
								}

								[SerializeField]
								int _fogOfWarTextureSize = 256;

								public int fogOfWarTextureSize {
												get { return _fogOfWarTextureSize; }
												set {
																if (value != _fogOfWarTextureSize) {
																				if (value > 16) {
																								_fogOfWarTextureSize = value;
																								FogOfWarUpdateTexture ();
																								UpdateMaterialProperties ();
																								isDirty = true;
																				}
																}
												}
								}

								[SerializeField]
								float _fogOfWarRestoreDelay = 0;

								public float fogOfWarRestoreDelay {
												get { return _fogOfWarRestoreDelay; }
												set {
																if (value != _fogOfWarRestoreDelay) {
																				_fogOfWarRestoreDelay = value;
																				isDirty = true;
																}
												}
								}

		
								[SerializeField]
								float _fogOfWarRestoreDuration = 2f;

								public float fogOfWarRestoreDuration {
												get { return _fogOfWarRestoreDuration; }
												set {
																if (value != _fogOfWarRestoreDuration) {
																				_fogOfWarRestoreDuration = value;
																				isDirty = true;
																}
												}
								}


								#endregion

								Texture2D fogOfWarTexture;
								Color32[] fogOfWarColorBuffer;

								class FogOfWarTransition {
												public bool enabled;
												public int x, y;
												public float startTime, startDelay;
												public float duration;
												public byte initialAlpha;
												public byte targetAlpha;
								}

								List<FogOfWarTransition> fowTransitionList;

								#region Fog Of War

								void FogOfWarInit () {
												fowTransitionList = new List<FogOfWarTransition> ();
								}

								void FogOfWarUpdateTexture () {
												if (!_fogOfWarEnabled)
																return;
												int size = GetScaledSize (_fogOfWarTextureSize, 1.0f);
												fogOfWarTexture = new Texture2D (size, size, TextureFormat.Alpha8, false);
												fogOfWarTexture.hideFlags = HideFlags.DontSave;
												fogOfWarTexture.filterMode = FilterMode.Bilinear;
												fogOfWarTexture.wrapMode = TextureWrapMode.Clamp;
												ResetFogOfWar ();
								}

		
								void FogOfWarUpdate () {
												if (!_fogOfWarEnabled)
																return;
												int fc = fowTransitionList.Count;
												int tw = fogOfWarTexture.width;
												bool hasChanged = false;
												for (int k = 0; k < fc; k++) {
																FogOfWarTransition fw = fowTransitionList [k];
																if (!fw.enabled)
																				continue;
																float elapsed = Time.time - fw.startTime - fw.startDelay;
																if (elapsed > 0) {
																				float t = fw.duration <= 0 ? 1 : elapsed / fw.duration;
																				t = Mathf.Clamp01 (t);
																				byte alpha = (byte)Mathf.Lerp (fw.initialAlpha, fw.targetAlpha, t);
																				int colorPos = fw.y * tw + fw.x;
																				fogOfWarColorBuffer [colorPos].a = alpha;
																				fogOfWarTexture.SetPixel (fw.x, fw.y, fogOfWarColorBuffer [colorPos]);
																				hasChanged = true;
																				if (t >= 1f) {
																								fw.enabled = false;
																								// Add clearance slot if needed
																								if (fw.targetAlpha < 255 && _fogOfWarRestoreDelay > 0) {
																												AddFowOfWarTransitionSlot (fw.x, fw.y, fw.targetAlpha, 255, _fogOfWarRestoreDelay, _fogOfWarRestoreDuration);
																								}
																				}
																}
												}
												if (hasChanged)
																fogOfWarTexture.Apply ();
								}

								/// <summary>
								/// Instantly changes the alpha value of the fog of war at world position. It takes into account FogOfWarCenter and FogOfWarSize.
								/// Note that only x and z coordinates are used. Y (vertical) coordinate is ignored.
								/// </summary>
								/// <param name="worldPosition">in world space coordinates.</param>
								/// <param name="radius">radius of application in world units.</param>
								public void SetFogOfWarAlpha (Vector3 worldPosition, float radius, float fogNewAlpha) {
												SetFogOfWarAlpha (worldPosition, radius, fogNewAlpha, 1f);
								}


								/// <summary>
								/// Changes the alpha value of the fog of war at world position creating a transition from current alpha value to specified target alpha. It takes into account FogOfWarCenter and FogOfWarSize.
								/// Note that only x and z coordinates are used. Y (vertical) coordinate is ignored.
								/// </summary>
								/// <param name="worldPosition">in world space coordinates.</param>
								/// <param name="radius">radius of application in world units.</param>
								/// <param name="fogNewAlpha">target alpha value.</param>
								/// <param name="duration">duration of transition in seconds (0 = apply fogNewAlpha instantly).</param>
								public void SetFogOfWarAlpha (Vector3 worldPosition, float radius, float fogNewAlpha, float duration) {
												if (fogOfWarTexture == null)
																return;

												float tx = (worldPosition.x - _fogOfWarCenter.x) / _fogOfWarSize.x + 0.5f;
												if (tx < 0 || tx > 1f)
																return;
												float tz = (worldPosition.z - _fogOfWarCenter.z) / _fogOfWarSize.z + 0.5f;
												if (tz < 0 || tz > 1f)
																return;

												int tw = fogOfWarTexture.width;
												int th = fogOfWarTexture.height;
												int px = (int)(tx * tw);
												int pz = (int)(tz * th);
												int colorBufferPos = pz * tw + px;
												byte newAlpha8 = (byte)(fogNewAlpha * 255);
												Color32 existingColor = fogOfWarColorBuffer [colorBufferPos];
												if (newAlpha8 != existingColor.a) { // just to avoid over setting the texture in an Update() loop
																float tr = radius / _fogOfWarSize.z;
																int delta = Mathf.FloorToInt (th * tr);
																for (int r = pz - delta; r <= pz + delta; r++) {
																				if (r > 0 && r < th - 1) {
																								for (int c = px - delta; c <= px + delta; c++) {
																												if (c > 0 && c < tw - 1) {
																																int distance = Mathf.FloorToInt (Mathf.Sqrt ((pz - r) * (pz - r) + (px - c) * (px - c)));
																																if (distance <= delta) {
																																				colorBufferPos = r * tw + c;
																																				Color32 colorBuffer = fogOfWarColorBuffer [colorBufferPos];
																																				byte targetAlpha = (byte)Mathf.Lerp (newAlpha8, colorBuffer.a, (float)distance / delta);
																																				if (duration > 0) {
																																								AddFowOfWarTransitionSlot (c, r, colorBuffer.a, targetAlpha, 0, duration);
																																				} else {
																																								colorBuffer.a = targetAlpha;
																																								fogOfWarColorBuffer [colorBufferPos] = colorBuffer;
																																								fogOfWarTexture.SetPixel (c, r, colorBuffer);
																																								if (_fogOfWarRestoreDuration > 0) {
																																												AddFowOfWarTransitionSlot (c, r, targetAlpha, 255, _fogOfWarRestoreDelay, _fogOfWarRestoreDuration);
																																								}
																																				}
																																}
																												}
																								}
																				}
																}
																fogOfWarTexture.Apply ();
												}
								}

								public void ResetFogOfWarAlpha (Vector3 worldPosition, float radius) {
												if (fogOfWarTexture == null)
																return;
			
												float tx = (worldPosition.x - _fogOfWarCenter.x) / _fogOfWarSize.x + 0.5f;
												if (tx < 0 || tx > 1f)
																return;
												float tz = (worldPosition.z - _fogOfWarCenter.z) / _fogOfWarSize.z + 0.5f;
												if (tz < 0 || tz > 1f)
																return;
			
												int tw = fogOfWarTexture.width;
												int th = fogOfWarTexture.height;
												int px = (int)(tx * tw);
												int pz = (int)(tz * th);
												int colorBufferPos = pz * tw + px;
												float tr = radius / _fogOfWarSize.z;
												int delta = Mathf.FloorToInt (th * tr);
												for (int r = pz - delta; r <= pz + delta; r++) {
																if (r > 0 && r < th - 1) {
																				for (int c = px - delta; c <= px + delta; c++) {
																								if (c > 0 && c < tw - 1) {
																												int distance = Mathf.FloorToInt (Mathf.Sqrt ((pz - r) * (pz - r) + (px - c) * (px - c)));
																												if (distance <= delta) {
																																colorBufferPos = r * tw + c;
																																Color32 colorBuffer = fogOfWarColorBuffer [colorBufferPos];
																																colorBuffer.a = 255;
																																fogOfWarColorBuffer [colorBufferPos] = colorBuffer;
																																fogOfWarTexture.SetPixel (c, r, colorBuffer);
																												}
																								}
																				}
																}
																fogOfWarTexture.Apply ();
												}
								}


								public void ResetFogOfWar () {
												if (fogOfWarTexture == null)
																return;
												int h = fogOfWarTexture.height;
												int w = fogOfWarTexture.width;
												int newLength = h * w;
												if (fogOfWarColorBuffer == null || fogOfWarColorBuffer.Length != newLength) {
																fogOfWarColorBuffer = new Color32[newLength];
												}
												Color32 opaque = new Color32 (255, 255, 255, 255);
												for (int k = 0; k < newLength; k++)
																fogOfWarColorBuffer [k] = opaque;
												fogOfWarTexture.SetPixels32 (fogOfWarColorBuffer);
												fogOfWarTexture.Apply ();
												fowTransitionList.Clear ();
												isDirty = true;
								}

								/// <summary>
								/// Gets or set fog of war state as a Color32 buffer. The alpha channel stores the transparency of the fog at that position (0 = no fog, 1 = opaque).
								/// </summary>
								public Color32[] fogOfWarTextureData { 
												get { 
																return fogOfWarColorBuffer;
												} 
												set {
																fogOfWarEnabled = true;
																fogOfWarColorBuffer = value;
																if (value == null || fogOfWarTexture == null)
																				return;
																if (value.Length != fogOfWarTexture.width * fogOfWarTexture.height)
																				return;
																fogOfWarTexture.SetPixels32 (fogOfWarColorBuffer);
																fogOfWarTexture.Apply ();
												}
								}


								void AddFowOfWarTransitionSlot (int x, int y, byte initialAlpha, byte targetAlpha, float delay, float duration) {
												int fc = fowTransitionList.Count;
												FogOfWarTransition fw = null;
												for (int k = 0; k < fc; k++) {
																FogOfWarTransition fi = fowTransitionList [k];
																if (fi.x == x && fi.y == y) {
																				fw = fi;
																				break;
																} else if (!fi.enabled) {
																				fw = fi;
																}
												}
												if (fw == null) {
																fw = new FogOfWarTransition ();
																fowTransitionList.Add (fw);
												}
												fw.x = x;
												fw.y = y;
												fw.duration = duration;
												fw.startTime = Time.time;
												fw.startDelay = delay;
												fw.initialAlpha = initialAlpha;
												fw.targetAlpha = targetAlpha;
												fw.enabled = true;
								}


								#endregion
				}

}