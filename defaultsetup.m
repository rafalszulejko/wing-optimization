addpath('openfoam')
addpath('generator')
addpath('gmsh')

u = 10;

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

domain = Domain(20, 10, 0.1, 1, 0.1);

encoder = train_selig('airfoils', chebyshevs(5), 5, 100, 'MaxEpochs', 10000);

