﻿using UnityEngine;
using UnityEngine.UI;
using System.Collections;

namespace VolumetricFogAndMist {
				public class DemoWalk : MonoBehaviour {

								Text status;

								void Start () {
												// This is for the sprite test: enable shadows on the elephant - SpriteRenderer has shadows disabled by default
												GameObject elephant = GameObject.Find ("Elephant");
												if (elephant != null) {
																elephant.GetComponent<Renderer> ().shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
												}

												status = GameObject.Find("Status").GetComponent<Text>();
								}


								void Update () {
												VolumetricFog fog = VolumetricFog.instance;
												if (Input.GetKeyDown (KeyCode.F)) {
																switch (fog.preset) {
																case FOG_PRESET.Custom:
																case FOG_PRESET.Clear:
																				fog.preset = FOG_PRESET.Mist;
																				break;
																case FOG_PRESET.Mist:
																				fog.preset = FOG_PRESET.WindyMist;
																				break;
																case FOG_PRESET.WindyMist:
																				fog.preset = FOG_PRESET.GroundFog;
																				break;
																case FOG_PRESET.GroundFog:
																				fog.preset = FOG_PRESET.FrostedGround;
																				break;
																case FOG_PRESET.FrostedGround:
																				fog.preset = FOG_PRESET.FoggyLake;
																				break;
																case FOG_PRESET.FoggyLake:
																				fog.preset = FOG_PRESET.Fog;
																				break;
																case FOG_PRESET.Fog:
																				fog.preset = FOG_PRESET.HeavyFog;
																				break;
																case FOG_PRESET.HeavyFog:
																				fog.preset = FOG_PRESET.LowClouds;
																				break;
																case FOG_PRESET.LowClouds:
																				fog.preset = FOG_PRESET.SeaClouds;
																				break;
																case FOG_PRESET.SeaClouds:
																				fog.preset = FOG_PRESET.Smoke;
																				break;
																case FOG_PRESET.Smoke:
																				fog.preset = FOG_PRESET.ToxicSwamp;
																				break;
																case FOG_PRESET.ToxicSwamp:
																				fog.preset = FOG_PRESET.SandStorm1;
																				break;
																case FOG_PRESET.SandStorm1:
																				fog.preset = FOG_PRESET.SandStorm2;
																				break;
																case FOG_PRESET.SandStorm2:
																				fog.preset = FOG_PRESET.Mist;
																				break;
																}
												} else if (Input.GetKeyDown (KeyCode.T)) {
																fog.enabled = !fog.enabled;
												}

												status.text = "Current fog preset: " + VolumetricFog.instance.GetCurrentPresetName();
								}

				}
}