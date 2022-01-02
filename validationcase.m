addpath('openfoam')
addpath('generator')
addpath('gmsh')

%% airfoil and general setup from NACA TR 573

points = readmatrix('generator/naca23012_240.dat');

mainAf = polyshape(points(:, 1), points(:, 2));
flap = scale(mainAf, 0.2);

A = 0.25*0.2;
Aprim = 0.032;
B = 0.1*0.2;
Bprim = 0.054;

flap = rotate(translate(flap, 1-(A-Aprim), - Bprim + B), -20, [1 + Aprim, -Bprim]);
plot([mainAf, flap])

Re = 730000;
l = 12*0.0254;
nu = 1.4207e-5;
u = Re*nu/l;

%% FOAM setup

foamsetup = FOAMSetup();

foamsetup.ToleranceP = "1e-6";
foamsetup.ToleranceU = "1e-6";
foamsetup.ToleranceNuTilda = "1e-6";

foamsetup.ForceCoeffsWriteInterval = 10;
foamsetup.ForceCoeffsMagUInf = u;

foamsetup.UInternalField = [u 0 0];

foamsetup.Subdomains = 2;

foamsetup.FileOutput = false;

foamsetup.BashExecutable = "wsl bash -i ";
foamsetup.GmshExecutablePath = "~/gmsh-git-Linux64/bin/gmsh ";

foamsetup.ZThickness = 0.1;

%foamsetup.prepare();

%% solution

[xbb, ybb] = boundingbox([mainAf, flap]);

Ltot = sqrt(max(xbb.^2) + max(ybb.^2))*l;

foamCase = FOAMCase("validation", foamsetup, meshScript(mainAf, flap, 30, 2, 4, 3, 0.005, 0.0002, 0.005, 1.2, 1, 0.1), Ltot);