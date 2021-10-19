addpath("generator");
addpath("gmsh");

unzip('airfoils.zip', 'airfoils');
encoder = train_selig('airfoils', 5, 5, 100, 'MaxEpochs', 10000);

ch_xx = chebyshevs(5);
e1_1 =          0.266;
e1_2 =          0.046;
e1_3 =          0.246;
e1_4 =          0.199;
e1_5 =          0.184;
e2_1 =          0.153;
e2_2 =          0.099;
e2_3 =          0.178;
e2_4 =          0.221;
e2_5 =          0.105;
a1 =            9;
a2 =            37;
x2 =            0.85;
y2 =            0.19;
s2 =            0.6;
el1 = decodeAirfoil(encoder, [e1_1; e1_2; e1_3; e1_4; e1_5], 0.01, ch_xx);
el2 = decodeAirfoil(encoder, [e2_1; e2_2; e2_3; e2_4; e2_5], 0.01, ch_xx);
domainX =       200;
domainY =       100;
AFDensity =     0.01;
wallDensity =   0.5;
z_thickness =   0.1;
bl_thickness =  0.02;
solver_cores =  10;
calculate_case(el1, a1, el2, a2, x2, y2, s2, domainX, domainY, AFDensity, wallDensity, z_thickness, bl_thickness, solver_cores)