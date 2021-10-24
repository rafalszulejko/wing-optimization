function ga_values = findParams(encoder, domainX, domainY, AFDensity, wallDensity, z_thickness, bl_thickness, solver_cores)
    ch_xx = chebyshevs(5);
    
    function result = calculate_case_total(arg)
            result = calculate_case(...
                decodeAirfoil(encoder, [arg(1); arg(2); arg(3); arg(4); arg(5)], 0.01, ch_xx), arg(6), ...
                decodeAirfoil(encoder, [arg(7); arg(8); arg(9); arg(10); arg(11)], 0.01, ch_xx), arg(12), arg(13), arg(14), arg(15), ...
                domainX, domainY, AFDensity, wallDensity, z_thickness, bl_thickness, solver_cores, arg);
    end

    parpool('local', 8)
    %e11,e12,e13,e14,e15,a1,e21,e22,e23,e24,e25,a2,x2,y2,s2
    options = optimoptions('ga','PlotFcn', @gaplotbestf, 'MaxGenerations', 500, 'MaxStallGenerations', 500, 'useParallel', true, 'Display', 'iter');

    ga_values = ga(@calculate_case_total, ...
        15, [], [], [], [], [0 ; 0  ; 0 ; 0 ; 0 ; 0; 0 ; 0 ; 0 ; 0 ; 0 ; 0; 0; 0; 0.1], [1 ; 1  ; 1 ; 1 ; 1 ;20; 1 ; 1 ; 1 ; 1 ; 1 ;60;0.25;0.15; 1], ...
        [], options); 
end

