%addpath("generator");
%addpath("gmsh");

%unzip('airfoils.zip', 'airfoils');
%encoder = train_selig('airfoils', 5, 5, 100, 'MaxEpochs', 10000);

% these values work only in combinaton with autoencoder!!!
% autoencoder training is not deterministic so please check .mlx live
% script if the shape even makes sense
ch_xx = chebyshevs(5);
e1_1 = 0.257;
e1_2 = 0.153;
e1_3 = 0.092;
e1_4 = 0.367;
e1_5 = 0.117;
e2_1 = 0.251;
e2_2 = 0.099;
e2_3 = 0.178;
e2_4 = 0.428;
e2_5 = 0.068;
a1 = 9;
a2 = 38;
x2 = 0.16;
y2 = 0.02;
s2 = 0.6;
el1 = decodeAirfoil(encoder, [e1_1; e1_2; e1_3; e1_4; e1_5], 0.01, ch_xx);
el2 = decodeAirfoil(encoder, [e2_1; e2_2; e2_3; e2_4; e2_5], 0.01, ch_xx);
domainX =       20;
domainY =       10;
AFDensity =     0.01;
wallDensity =   0.5;
z_thickness =   0.1;
bl_thickness =  0.02;
solver_cores =  2;
calculate_case(el1, a1, el2, a2, x2, y2, s2, domainX, domainY, AFDensity, wallDensity, z_thickness, bl_thickness, solver_cores)