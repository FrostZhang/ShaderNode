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
				public class VolumetricFogPosT : MonoBehaviour, IVolumetricFogRenderComponent {
	
								public VolumetricFog fog { get; set; }

								void OnRenderImage (RenderTexture source, RenderTexture destination) {
												if (fog != null && fog.enabled) {
																if (fog.renderOpaque && fog.transparencyMode == TRANSPARENT_PASS_MODE.BlendPass) {
																				fog.DoOnPostRenderBlend (source, destination);
																} else {
																				fog.DoOnRenderImage (source, destination);
																}
												} else {
																Graphics.Blit(source, destination);
												}
								}

								public void DestroySelf () {
												DestroyImmediate (this);
								}

				}

}