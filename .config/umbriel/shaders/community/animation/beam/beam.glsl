// Faxxxmaster 2026
// shower für Umbriel (animation-Preset, GLSL ES 1.00)
// Port eines Burn-My-Windows-Effekts (Shower/Streaks/Atoms)
// SPDX-FileCopyrightText: Simon Schneegans <code@simonschneegans.de>
// SPDX-License-Identifier: GPL-3.0-or-later

// Fallback-Color (Noctalia-Theme: accent_primary / accent_secondary), falls keine Palette aktiv ist.
const vec3  COLOR_A  = vec3(0.910, 0.482, 0.392);  // #e87b64
const vec3  COLOR_B  = vec3(0.898, 0.706, 0.302);  // #e5b44d
const float SCALE    = 1.0;                    // uScale
const float DURATION = 0.3;                    // uDuration in Sekunden (= duration_ms / 1000)

const float SHOWER_TIME  = 0.3;
const float SHOWER_WIDTH = 0.3;
const float STREAK_TIME  = 0.6;
const float EDGE_FADE    = 50.0;

// --- Ersatz für common.glsl ---------------------------------------------------------

float easeOutQuad(float t) {
  return 1.0 - (1.0 - t) * (1.0 - t);
}

vec2 mod289v2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 mod289v3(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289v4(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute3(vec3 x) { return mod289v3(((x * 34.0) + 1.0) * x); }
vec4 permute4(vec4 x) { return mod289v4(((x * 34.0) + 1.0) * x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

// 2D Simplex Noise (Ashima Arts / Ian McEwan, MIT), Ergebnis in [0, 1].
float simplex2D(vec2 v) {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy));
  vec2 x0 = v - i + dot(i, C.xx);
  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod289v2(i);
  vec3 p = permute3(permute3(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
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
  return clamp(0.5 + 0.5 * (130.0 * dot(m, g)), 0.0, 1.0);
}

// 3D Simplex Noise (Ashima Arts / Ian McEwan, MIT), Ergebnis in [0, 1].
float simplex3D(vec3 v) {
  const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
  vec3 i  = floor(v + dot(v, C.yyy));
  vec3 x0 = v - i + dot(i, C.xxx);
  vec3 g  = step(x0.yzx, x0.xyz);
  vec3 l  = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy;
  vec3 x3 = x0 - D.yyy;
  i = mod289v3(i);
  vec4 p = permute4(permute4(permute4(i.z + vec4(0.0, i1.z, i2.z, 1.0))
                             + i.y + vec4(0.0, i1.y, i2.y, 1.0))
                    + i.x + vec4(0.0, i1.x, i2.x, 1.0));
  float n_ = 0.142857142857;
  vec3 ns  = n_ * D.wyz - D.xzx;
  vec4 j   = p - 49.0 * floor(p * ns.z * ns.z);
  vec4 x_  = floor(j * ns.z);
  vec4 y_  = floor(j - 7.0 * x_);
  vec4 x   = x_ * ns.x + ns.yyyy;
  vec4 y   = y_ * ns.x + ns.yyyy;
  vec4 h   = 1.0 - abs(x) - abs(y);
  vec4 b0  = vec4(x.xy, y.xy);
  vec4 b1  = vec4(x.zw, y.zw);
  vec4 s0  = floor(b0) * 2.0 + 1.0;
  vec4 s1  = floor(b1) * 2.0 + 1.0;
  vec4 sh  = -step(h, vec4(0.0));
  vec4 a0  = b0.xzyw + s0.xzyw * sh.xxyy;
  vec4 a1  = b1.xzyw + s1.xzyw * sh.zzww;
  vec3 p0  = vec3(a0.xy, h.x);
  vec3 p1  = vec3(a0.zw, h.y);
  vec3 p2  = vec3(a1.xy, h.z);
  vec3 p3  = vec3(a1.zw, h.w);
  vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
  m = m * m;
  float n = 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
  return clamp(0.5 + 0.5 * n, 0.0, 1.0);
}

float simplex2DFractal(vec2 p) {
  float f = 0.5333 * simplex2D(p);
  f += 0.2667 * simplex2D(2.0 * p);
  f += 0.1333 * simplex2D(4.0 * p);
  f += 0.0667 * simplex2D(8.0 * p);
  return f;
}

// 0 am Rand, 1 in der Mitte; fadeWidth relativ zur Fenstergröße.
float getRelativeEdgeMask(vec2 uv, float fadeWidth) {
  float mask = smoothstep(0.0, 1.0, clamp(uv.x / fadeWidth, 0.0, 1.0));
  mask *= smoothstep(0.0, 1.0, clamp((1.0 - uv.x) / fadeWidth, 0.0, 1.0));
  mask *= smoothstep(0.0, 1.0, clamp(uv.y / fadeWidth, 0.0, 1.0));
  mask *= smoothstep(0.0, 1.0, clamp((1.0 - uv.y) / fadeWidth, 0.0, 1.0));
  return mask;
}

// 0 am Rand, 1 ab 'padding' logischen Pixeln Abstand (Näherung des BMW-Originals).
float getAbsoluteEdgeMask(vec2 uv, float padding) {
  vec2 px = uv * umbriel_size;
  float d = min(min(px.x, umbriel_size.x - px.x), min(px.y, umbriel_size.y - px.y));
  return smoothstep(0.0, 1.0, clamp(d / padding, 0.0, 1.0));
}

vec3 paletteColor(float t, vec3 fallback) {
  return umbriel_palette_count > 0 ? umbriel_palette_at(t).rgb : fallback;
}

// --- Effekt -------------------------------------------------------------------------

// x: Shower-Partikel, y: Streaks, z: Atome, w: Fenster-Deckkraft
vec4 getMasks(float progress, vec2 uv, bool opening) {
  float showerProgress = progress / SHOWER_TIME;
  float streakProgress = clamp((progress - SHOWER_TIME) / STREAK_TIME, 0.0, 1.0);
  float fadeProgress   = clamp((progress - SHOWER_TIME) / (1.0 - SHOWER_TIME), 0.0, 1.0);

  float t = uv.y;

  float showerMask =
    1.0 - smoothstep(0.0, 1.0, abs(showerProgress - t - SHOWER_WIDTH) / SHOWER_WIDTH);

  float streakMask = (showerProgress - t - SHOWER_WIDTH) > 0.0 ? 1.0 : 0.0;

  float atomMask = getRelativeEdgeMask(uv, 0.2);
  atomMask       = max(0.0, atomMask - showerMask);
  atomMask *= streakMask;
  atomMask *= sqrt(1.0 - fadeProgress * fadeProgress);

  showerMask += 0.05 * streakMask;
  streakMask = max(streakMask, showerMask);

  float edgeFade = getAbsoluteEdgeMask(uv, EDGE_FADE);
  streakMask *= edgeFade;
  showerMask *= edgeFade;

  float fade = smoothstep(0.0, 1.0, 1.0 + t - 2.0 * streakProgress);
  streakMask *= fade;
  showerMask *= fade;

  float windowMask = pow(1.0 - fadeProgress, 2.0);
  if (opening) {
    windowMask = 1.0 - windowMask;
  }

  return vec4(showerMask, streakMask, atomMask, windowMask);
}

vec4 animation(vec2 uv0) {
  bool opening    = umbriel_direction > 0.0;
  // Beim Schließen von unten nach oben: Effekt-Koordinaten vertikal spiegeln.
  vec2 uv = opening ? uv0 : vec2(uv0.x, 1.0 - uv0.y);
  float uProgress = umbriel_clamped_progress;
  float progress  = easeOutQuad(uProgress);

  vec4 masks = getMasks(progress, uv, opening);

  // Palette: 0.0 = accent_primary, 1.0 = accent_secondary (Fallback: Konstanten oben).
  vec3 colA = paletteColor(0.0, COLOR_A);
  vec3 colB = paletteColor(1.0, COLOR_B);

  // Premultiplied -> straight alpha für die Berechnung.
  vec4 src    = umbriel_sample(uv0);
  vec4 oColor = vec4(src.rgb / max(src.a, 0.0001), src.a);

  // Fenster zu Effektfarbe / Transparenz auflösen.
  oColor.rgb = mix(colA, oColor.rgb, 0.5 * masks.w + 0.5);
  oColor.a   = oColor.a * masks.w;

  // Führende Shower-Partikel.
  vec2 showerUV = uv + vec2(0.0, -0.7 * progress / SHOWER_TIME);
  showerUV *= 0.02 * umbriel_size / SCALE;
  float shower = pow(simplex2D(showerUV), 10.0);
  oColor.rgb += colA * shower * masks.x;
  oColor.a += shower * masks.x;

  // Nachlaufende Streaks.
  vec2 streakUV = uv + vec2(0.0, -progress / SHOWER_TIME);
  streakUV *= vec2(0.05 * umbriel_size.x, 0.001 * umbriel_size.y) / SCALE;
  float streaks = simplex2DFractal(streakUV) * 0.5;
  oColor.rgb += colA * streaks * masks.y;
  oColor.a += streaks * masks.y;

  // Glitzernde Atome.
  vec2 atomUV = uv + vec2(0.0, -0.025 * progress / SHOWER_TIME);
  atomUV *= 0.2 * umbriel_size / SCALE;
  float atoms = pow(simplex3D(vec3(atomUV, uProgress * DURATION)), 5.0);
  oColor.rgb += colB * atoms * masks.z;
  oColor.a += atoms * masks.z;

  // Zurück nach premultiplied.
  float a = clamp(oColor.a, 0.0, 1.0);
  return vec4(clamp(oColor.rgb, 0.0, 1.0) * a, a);
}
