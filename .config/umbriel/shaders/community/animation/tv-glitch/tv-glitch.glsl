// tv-glitch für Umbriel (animation-Preset, GLSL ES 1.00)
// Port des Burn-My-Windows-Effekts tv-glitch.frag
// SPDX-FileCopyrightText: Simon Schneegans <code@simonschneegans.de>
// SPDX-License-Identifier: GPL-3.0-or-later

// Ersatz für die BMW-Uniforms:
const vec4  COLOR    = vec4(1.0, 1.0, 1.0, 1.0);  // uColor
const float SCALE    = 1.0;                       // uScale
const float STRENGTH = 1.0;                       // uStrength
const float SPEED    = 1.0;                       // uSpeed
const float DURATION = 0.3;                       // uDuration in Sekunden (= duration_ms / 1000)

const float BLUR_WIDTH = 0.01;
const float TB_TIME    = 0.7;
const float LR_TIME    = 0.4;
const float LR_DELAY   = 0.6;
const float FF_TIME    = 0.1;
const float SCALING    = 0.5;

// --- Ersatz für common.glsl ---------------------------------------------------------

float easeInQuad(float t) {
  return t * t;
}

float easeOutQuad(float t) {
  return 1.0 - (1.0 - t) * (1.0 - t);
}

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

vec2 mod289v2(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 mod289v3(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289v3(((x * 34.0) + 1.0) * x);
}

// 2D Simplex Noise (Ashima Arts / Ian McEwan, MIT), Ergebnis in [0, 1].
float simplex2D(vec2 v) {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);
  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod289v2(i);
  vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
  vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
  m = m * m;
  m = m * m;
  vec3 x  = 2.0 * fract(p * C.www) - 1.0;
  vec3 h  = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
  vec3 g;
  g.x  = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 0.5 + 0.5 * (130.0 * dot(m, g));
}

vec4 getInputColor(vec2 p) {
  return umbriel_sample(clamp(p, 0.0, 1.0));
}

// --- Effekt -------------------------------------------------------------------------

vec4 animation(vec2 uv) {
  bool opening = umbriel_direction > 0.0;
  float uProgress = umbriel_clamped_progress;

  // TV-Effekt früher/später in der Animation.
  float tOffset    = opening ? 0.0 : 1.0;
  float tvProgress = clamp(uProgress * 2.0 - tOffset, 0.0, 1.0);
  tvProgress = opening ? 1.0 - easeOutQuad(tvProgress) : easeOutQuad(tvProgress);

  // Fenster vertikal zusammenstauchen.
  float scale = 1.0 / mix(1.0, SCALING, tvProgress) - 1.0;
  vec2 coords = uv;
  coords.y    = coords.y * (scale + 1.0) - scale * 0.5;

  // Glitch-Teil.
  float progress = easeInQuad(opening ? 1.0 - uProgress : uProgress);
  float time     = progress * DURATION * SPEED;
  float strength = STRENGTH * progress;
  float displace = 1000.0 * strength / umbriel_size.x;
  float yPos     = SCALE * umbriel_size.y * (coords.y + umbriel_random_seed.x * 10.0);

  float noise = clamp(simplex2D(vec2(time, yPos * 0.002)) - 0.5, 0.0, 1.0);
  noise += (simplex2D(vec2(time * 10.0, yPos * 0.05)) - 0.5) * 0.15;

  float xPos  = clamp(coords.x - displace * noise * noise, 0.0, 1.0);
  vec4 oColor = getInputColor(vec2(xPos, coords.y));

  // Interferenzlinien.
  vec3 interference          = COLOR.rgb * hash12(vec2(yPos * time));
  float interferenceStrength = noise * min(strength, 1.0);
  oColor.rgb = mix(oColor.rgb, interference, COLOR.a * interferenceStrength);

  // Körniges Rauschen.
  vec3 grain          = COLOR.rgb * simplex2D(umbriel_size * coords + vec2(time * 100.0));
  float grainStrength = 0.2 * min(strength, 1.0);
  oColor.rgb          = mix(oColor.rgb, grain, COLOR.a * grainStrength);

  // Zeilenmuster alle 4 Pixel.
  if (floor(mod(yPos * 0.25, 2.0)) == 0.0) {
    oColor.rgb = mix(oColor.rgb, COLOR.rgb, COLOR.a * (0.15 * noise));
  }

  // Grün-/Blau-Kanal verschieben.
  float offset = 0.1 * noise * displace;
  oColor.g     = mix(oColor.g, getInputColor(vec2(xPos + offset, coords.y)).g, 0.25);
  oColor.b     = mix(oColor.b, getInputColor(vec2(xPos - offset, coords.y)).b, 0.25);

  // Fenster per TV-Effekt ausblenden.
  float tbProg = smoothstep(0.0, 1.0, clamp(tvProgress / TB_TIME, 0.0, 1.0));
  float lrProg = smoothstep(0.0, 1.0, clamp((tvProgress - LR_DELAY) / LR_TIME, 0.0, 1.0));
  float ffProg = smoothstep(0.0, 1.0, clamp((tvProgress - 1.0 + FF_TIME) / FF_TIME, 0.0, 1.0));

  float tb = coords.y * 2.0;
  tb       = tb < 1.0 ? tb : 2.0 - tb;

  float lr = coords.x * 2.0;
  lr       = lr < 1.0 ? lr : 2.0 - lr;

  float tbMask = 1.0 - smoothstep(0.0, 1.0, clamp((tbProg - tb) / BLUR_WIDTH, 0.0, 1.0));
  float lrMask = 1.0 - smoothstep(0.0, 1.0, clamp((lrProg - lr) / BLUR_WIDTH, 0.0, 1.0));
  float ffMask = 1.0 - smoothstep(0.0, 1.0, ffProg);

  oColor.rgb = mix(oColor.rgb, COLOR.rgb * oColor.a, COLOR.a * smoothstep(0.0, 1.0, tvProgress));
  float mask = tbMask * lrMask * ffMask;

  // Umbriel erwartet premultiplied RGBA.
  return oColor * mask;
}
