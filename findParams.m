function ga_values = findParams(encoder, n, foamSetup, domainConfig)
    foamSetup.prepare();

    ch_xx = chebyshevs(n);
    
    function result = calculate_case(arg)
        [e1m, e2m, Ltot] = twoairfoils(decodeAirfoil(encoder, arg(1:n)', 0.01, ch_xx), ...
            arg(n+1), ...
            decodeAirfoil(encoder, arg(n+2:2*n+1)', 0.01, ch_xx), ...
            arg(2*n+2), arg(2*n+3), arg(2*n+4), arg(2*n+5));
        
        if validateAirfoils(e1m, e2m, domainConfig.BLThickness) == false
            result = 0;
            return
        end
        
        foamCase = FOAMCase(string.empty, foamSetup, meshScript(e1m, e2m, domainConfig), Ltot);
        
        foamCase.solve();
        
        result = - foamCase.Cl * foamCase.Cl_Cd;
    end

    parpool('local', 8)
    %e11,e12,e13,e14,e15,a1,e21,e22,e23,e24,e25,a2,x2,y2,s2
    options = optimoptions('ga', 'MaxGenerations', 500, 'MaxStallGenerations', 500, 'useParallel', true, 'Display', 'iter');

    ga_values = ga(@calculate_case, ...
        15, [], [], [], [], [0 ; 0  ; 0 ; 0 ; 0 ; 0; 0 ; 0 ; 0 ; 0 ; 0 ; 0; 0; 0; 0.1], [1 ; 1  ; 1 ; 1 ; 1 ;20; 1 ; 1 ; 1 ; 1 ; 1 ;60;0.25;0.15; 1], ...
        [], options); 
end

