//------------------------------------------------------------------------------------------------------------------
// Volumetric Fog & Mist
// Created by Ramiro Oliva (Kronnect)
//------------------------------------------------------------------------------------------------------------------
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;


namespace VolumetricFogAndMist {

				[ExecuteInEditMode]
				[RequireComponent (typeof(Camera), typeof(VolumetricFog))]
				public class VolumetricFogPreT : MonoBehaviour, IVolumetricFogRenderComponent {

								public VolumetricFog fog { get; set; }

								void OnPreRender () {
												if (fog != null)
																fog.DoOnPreRender ();
								}

								[ImageEffectOpaque]
								void OnRenderImage (RenderTexture source, RenderTexture destination) {
												if (fog != null && fog.enabled) {
																fog.DoOnRenderImage (source, destination);
												} else {
																Graphics.Blit(source, destination);
												}
								}

								IEnumerator OnPostRender () {
												if (fog != null && fog.renderOpaque && fog.transparencyMode == TRANSPARENT_PASS_MODE.ScreenDirect) {
																// Apply a second pass only over the transparent objects
																yield return new WaitForEndOfFrame ();
																if (fog != null)
																				fog.DoOnPostRender ();
												} 
								}

								public void DestroySelf() {
												DestroyImmediate(this);
								}


				}

}