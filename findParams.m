function ga_values = findParams(encoder, hiddenLayerLength, foamSetup)
    foamSetup.prepare();
    
    n = hiddenLayerLength;
    ch_xx = chebyshevs(n);
    
    function Population = initialValidPopulation(GenomeLength, FitnessFcn, options)
        Population = zeros(GenomeLength, 2*n);
        
        for i = 1:GenomeLength
            while true
                arg = 0.5*rand(1, 2*n);
                [e1s, e2s, ~] = twoairfoils_new(decodeAirfoil(encoder, arg(1:n)', 0.01, ch_xx, 200), ...
                decodeAirfoil(encoder, arg(n+1:2*n)', 0.01, ch_xx, 200), ...
                0.02, 0.05, 0.4);

                if validateAirfoils (e1s, e2s, 0.005) == true
                    figure;
                    plot([e1s, e2s]);
                    Population(i, :) = arg;
                    break;
                end
            end
        end
    end
    
    function result = calculate_case(arg)
        [e1m, e2m, Ltot] = twoairfoils_new(decodeAirfoil(encoder, arg(1:n)', 0.01, ch_xx, 200), ...
            decodeAirfoil(encoder, arg(n+1:2*n)', 0.01, ch_xx, 200), ...
            0.02, 0.05, 0.4);
        
        if validateAirfoils(e1m, e2m, 0.005) == false
            result = 0;
            return
        end
        
        foamCase = FOAMCase(string.empty, foamSetup, meshScript(e1m, e2m, 30, 2, 4, 3, 0.005, 0.0002, 0.005, 1.2, 1, 0.1), Ltot);
        
        foamCase.solve(arg);
        
        if foamCase.HasErrors
            result = 0;
        end
        
        result = - foamCase.Cl * foamCase.Cl_Cd;
    end

    %parpool('local', 8)
    %e11,e12,e13,e14,e15,e21,e22,e23,e24,e25
    options = optimoptions('ga', 'MaxGenerations', 500, 'MaxStallGenerations', 500, 'Display', 'iter', 'CreationFcn', @initialValidPopulation);

    ga_values = ga(@calculate_case, ...
        2*n, [], [], [], [], [0 ; 0  ; 0 ; 0 ; 0 ; 0; 0 ; 0 ; 0 ; 0], 0.5*[1 ; 1  ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1], ...
        [], options); 
end

