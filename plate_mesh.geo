// =============================================================================
//  Author: Rong Jin
// =============================================================================
// -------------------- Full plate, 5 patches --------------------

SetFactory("OpenCASCADE");
Mesh.RecombineAll = 1;

// ===== parameters =====
Lx = 10;  Ly = 10;  t = 0.35;   // cm
ax = 2.0; ay = 2.0;            // core half-size (=> core 4×4 cm)

NxCore = 80;    // divisions along core top/bottom & outer top/bottom (x-dir)
NyCore = 80;    // divisions along core left/right  & outer left/right  (y-dir)

NLayers = 8;    // layers from outer boundary -> core (one strip per side)
rGrad   = 1.5;  // geometric grading toward core; 2.0 = 每进一层减半

Nz = 8;         // constant layers through thickness

// ===== points =====
A = newp; Point(A) = {-Lx/2, -Ly/2, 0};
B = newp; Point(B) = { Lx/2, -Ly/2, 0};
C = newp; Point(C) = { Lx/2,  Ly/2, 0};
D = newp; Point(D) = {-Lx/2,  Ly/2, 0};

I = newp; Point(I) = {-ax, -ay, 0};
J = newp; Point(J) = { ax, -ay, 0};
K = newp; Point(K) = { ax,  ay, 0};
L = newp; Point(L) = {-ax,  ay, 0};

// ===== lines =====
// outer rectangle
lAB = newl; Line(lAB) = {A,B};
lBC = newl; Line(lBC) = {B,C};
lCD = newl; Line(lCD) = {C,D};
lDA = newl; Line(lDA) = {D,A};

// core rectangle
lIJ = newl; Line(lIJ) = {I,J};
lJK = newl; Line(lJK) = {J,K};
lKL = newl; Line(lKL) = {K,L};
lLI = newl; Line(lLI) = {L,I};

// connectors (outer -> core)
mAI = newl; Line(mAI) = {A,I};
mBJ = newl; Line(mBJ) = {B,J};
mCK = newl; Line(mCK) = {C,K};
mDL = newl; Line(mDL) = {D,L};

// ===== 2D patches (5) =====
// core
cl_core = newl; Curve Loop(cl_core) = {lIJ, lJK, lKL, lLI};
s_core = news; Plane Surface(s_core) = {cl_core};
Transfinite Surface{s_core} = {I,J,K,L}; Recombine Surface{s_core};

// south strip (outer bottom -> core bottom)
cl_s = newl; Curve Loop(cl_s) = { lAB,  mBJ, -lIJ, -mAI };
s_s = news; Plane Surface(s_s) = {cl_s};
Transfinite Surface{s_s} = {A,B,J,I}; Recombine Surface{s_s};

// east strip
cl_e = newl; Curve Loop(cl_e) = { lBC,  mCK, -lJK, -mBJ };
s_e = news; Plane Surface(s_e) = {cl_e};
Transfinite Surface{s_e} = {B,C,K,J}; Recombine Surface{s_e};

// north strip
cl_n = newl; Curve Loop(cl_n) = { lCD,  mDL, -lKL, -mCK };
s_n = news; Plane Surface(s_n) = {cl_n};
Transfinite Surface{s_n} = {C,D,L,K}; Recombine Surface{s_n};

// west strip
cl_w = newl; Curve Loop(cl_w) = { lDA,  mAI, -lLI, -mDL };
s_w = news; Plane Surface(s_w) = {cl_w};
Transfinite Surface{s_w} = {D,A,I,L}; Recombine Surface{s_w};

// ===== transfinite on curves =====
// Opposite edges must have same counts (structured requirement):
Transfinite Curve{lAB, lCD, lIJ, lKL} = NxCore;  // x-direction
Transfinite Curve{lBC, lDA, lJK, lLI} = NyCore;  // y-direction

// Radial grading: from outer boundary -> core, toward
// The directions of the connecting lines: A->I, B->J, C->K, D->L
Transfinite Curve{mAI, mBJ, mCK, mDL} = NLayers Using Progression (1./rGrad);

// ===== extrude to 3D (hexa) =====
all2D[] = {s_core, s_s, s_e, s_n, s_w};
vols[] = {};
nS = #all2D[];
For ii In {0:nS-1}
  tmp[] = Extrude {0,0,t} { Surface{all2D[ii]}; Layers{Nz}; Recombine; };
  vols[] += {tmp[1]};
EndFor

// ===== physical groups (optional) =====
Physical Surface("Bottom") = all2D[];
Physical Volume("Plate")   = vols[];
