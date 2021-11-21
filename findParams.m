function ga_values = findParams(encoder, n, paramsFile)
    addpath('openfoam')
    addpath('generator')
    addpath('gmsh')
    
    load(paramsFile, 'defaultsetup')
    defaultsetup.caseSetup();
    
    ch_xx = chebyshevs(5);
    
    function result = calculate_case_total(arg)
        [e1m, e2m, Ltot] = twoairfoils(decodeAirfoil(encoder, arg(1:n)', 0.01, ch_xx), ...
            arg(n+1), ...
            decodeAirfoil(encoder, arg(n+2:2*n+1)', 0.01, ch_xx), ...
            arg(2*n+2), arg(2*n+3), arg(2*n+4), arg(2*n+5));
        
        if validateAirfoils(e1m, e2m, bl_thickness) == false
            result = 0;
            return
        end
        
        foamCase = FOAMCase(string.empty, defaultsetup, meshScript(e1m, e2m, domainX, domainY, AFDensity, wallDensity, z_thickness), Ltot);
        
        foamCase.solve();
        
        result = - foamCase.Cl * foamCase.Cl_Cd;
    end

    parpool('local', 8)
    %e11,e12,e13,e14,e15,a1,e21,e22,e23,e24,e25,a2,x2,y2,s2
    options = optimoptions('ga','PlotFcn', @gaplotbestf, 'MaxGenerations', 500, 'MaxStallGenerations', 500, 'useParallel', true, 'Display', 'iter');

    ga_values = ga(@calculate_case_total, ...
        15, [], [], [], [], [0 ; 0  ; 0 ; 0 ; 0 ; 0; 0 ; 0 ; 0 ; 0 ; 0 ; 0; 0; 0; 0.1], [1 ; 1  ; 1 ; 1 ; 1 ;20; 1 ; 1 ; 1 ; 1 ; 1 ;60;0.25;0.15; 1], ...
        [], options); 
end

