<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from "vue";

const props = defineProps<{ dark: boolean }>();
const el = ref<HTMLCanvasElement | null>(null);

const VERT = "attribute vec2 a;void main(){gl_Position=vec4(a,0.,1.);}";
const FRAG = `precision mediump float;
uniform vec2 r;uniform float t;uniform vec2 m;uniform float d;
float h(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float n(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);
  return mix(mix(h(i),h(i+vec2(1,0)),f.x),mix(h(i+vec2(0,1)),h(i+vec2(1,1)),f.x),f.y);}
float fbm(vec2 p){float v=0.,a=.5;for(int i=0;i<5;i++){v+=a*n(p);p*=2.03;a*=.5;}return v;}
void main(){
  vec2 uv=gl_FragCoord.xy/r;
  vec2 p=uv*vec2(r.x/r.y,1.)*0.95;
  float tt=t*.045;
  vec2 q=vec2(fbm(p+tt),fbm(p+vec2(5.2,1.3)-tt));
  vec2 w=vec2(fbm(p+4.*q+vec2(1.7,9.2)+tt*1.4),fbm(p+4.*q+vec2(8.3,2.8)-tt));
  float f=fbm(p+2.4*w);
  float spot=smoothstep(.55,0.,distance(uv*vec2(r.x/r.y,1.),m*vec2(r.x/r.y,1.)));
  vec3 c1=vec3(1.,.45,.22);vec3 c2=vec3(.56,.43,1.);vec3 c3=vec3(1.,.72,.5);
  vec3 col=mix(c1,c2,clamp(w.x*1.5-.2,0.,1.));
  col=mix(col,c3,clamp(q.y*q.y*1.2,0.,1.)*.5);
  float a=smoothstep(.32,.9,f)*(.75+spot*.7);
  a*=smoothstep(.0,.55,uv.y);
  vec3 base=d>.5?vec3(.043,.039,.035):vec3(.984,.969,.953);
  vec3 o=d>.5?base+col*a*.85:mix(base,col,a*.42);
  gl_FragColor=vec4(o,1.);
}`;

let gl: WebGLRenderingContext | null = null;
let raf = 0;
let start = 0;
let visible = true;
let io: IntersectionObserver | null = null;
const mouse = [0.5, 0.6];
const target = [0.5, 0.6];
let uR: WebGLUniformLocation | null, uT: WebGLUniformLocation | null, uM: WebGLUniformLocation | null, uD: WebGLUniformLocation | null;

function compile(type: number, src: string) {
  const s = gl!.createShader(type)!;
  gl!.shaderSource(s, src);
  gl!.compileShader(s);
  return s;
}

function resize() {
  const c = el.value;
  if (!c || !gl) return;
  // Half resolution: the shader is soft anyway and this keeps laptops cool.
  const scale = Math.min(window.devicePixelRatio || 1, 2) * 0.5;
  c.width = Math.max(1, Math.floor(c.clientWidth * scale));
  c.height = Math.max(1, Math.floor(c.clientHeight * scale));
  gl.viewport(0, 0, c.width, c.height);
}

function onMove(e: PointerEvent) {
  const c = el.value;
  if (!c) return;
  const b = c.getBoundingClientRect();
  target[0] = (e.clientX - b.left) / b.width;
  target[1] = 1 - (e.clientY - b.top) / b.height;
}

function frame(now: number) {
  raf = requestAnimationFrame(frame);
  if (!visible || !gl) return;
  mouse[0] += (target[0] - mouse[0]) * 0.04;
  mouse[1] += (target[1] - mouse[1]) * 0.04;
  gl.uniform2f(uR, el.value!.width, el.value!.height);
  gl.uniform1f(uT, (now - start) / 1000);
  gl.uniform2f(uM, mouse[0], mouse[1]);
  gl.uniform1f(uD, props.dark ? 1 : 0);
  gl.drawArrays(gl.TRIANGLES, 0, 3);
}

onMounted(() => {
  const c = el.value!;
  gl = c.getContext("webgl", { antialias: false, alpha: false, powerPreference: "low-power" });
  if (!gl) return;
  const prog = gl.createProgram()!;
  gl.attachShader(prog, compile(gl.VERTEX_SHADER, VERT));
  gl.attachShader(prog, compile(gl.FRAGMENT_SHADER, FRAG));
  gl.linkProgram(prog);
  gl.useProgram(prog);
  const buf = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buf);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW);
  const loc = gl.getAttribLocation(prog, "a");
  gl.enableVertexAttribArray(loc);
  gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);
  uR = gl.getUniformLocation(prog, "r");
  uT = gl.getUniformLocation(prog, "t");
  uM = gl.getUniformLocation(prog, "m");
  uD = gl.getUniformLocation(prog, "d");
  resize();
  window.addEventListener("resize", resize);
  window.addEventListener("pointermove", onMove, { passive: true });
  io = new IntersectionObserver(([e]) => (visible = e.isIntersecting));
  io.observe(c);
  start = performance.now();
  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    start -= 40000;
    frame(performance.now());
    cancelAnimationFrame(raf);
  } else {
    raf = requestAnimationFrame(frame);
  }
});

watch(
  () => props.dark,
  () => {
    if (gl && !raf) frame(performance.now());
  },
);

onBeforeUnmount(() => {
  cancelAnimationFrame(raf);
  window.removeEventListener("resize", resize);
  window.removeEventListener("pointermove", onMove);
  io?.disconnect();
  gl?.getExtension("WEBGL_lose_context")?.loseContext();
});
</script>

<template>
  <canvas ref="el" aria-hidden="true" />
</template>
