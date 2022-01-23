function ga_values = findParams(encoder, hiddenLayerLength)
    
    addpath('openfoam')
    addpath('generator')
    addpath('gmsh')

    n = hiddenLayerLength;
    ch_xx = chebyshevs(n);
    u = 30;
    Args = {'0_0_0_0_0_0_0_0_0_0'};
    Result = {0};
    pastResults = table(Result, 'RowNames',Args);
    
    function Population = initialValidPopulation(GenomeLength, FitnessFcn, options)
        Population = zeros(options.PopulationSize, GenomeLength);
        
        for i = 1:options.PopulationSize
            Population(i, :) = randomValidCase(GenomeLength);
        end
    end

    function out = randomValidCase(length)
        while true
            arg = 0.5*rand(1, length);
            [e1s, e2s, ~] = twoairfoils_new(decodeAirfoil(encoder, arg(1:n)', 0.01, ch_xx, 200), ...
                decodeAirfoil(encoder, arg(n+1:2*n)', 0.01, ch_xx, 200), ...
                0.02, 0.05, 0.4);

            if validateAirfoils (e1s, e2s, 0.005) == true
                out = arg;
                return;
            end
        end
    end

    function [state,options,optchanged] = checkPopulation(options,state,flag)
        if ~strcmp(flag, 'iter')
            return;
        end

        zeroCount = 0;
        zeroIndices = [];
        for i = 1:length(state.Score)
            if state.Score(i) == 0
                zeroCount = zeroCount + 1;
                zeroIndices = [zeroIndices, i];
            end
        end

        if zeroCount > length(state.Score)/2 || mod(state.Generation, 5) == 0
            disp("Resetting dead population members to random valid values")
            for i = 1:zeroCount
                state.Population(i, :) = randomValidCase(min(size(state.Population))); %% assumed that population is larger than hidden layer length!!!
            end
        end

        optchanged = false;
    end

    function result = calculate_case(arg)
        args_concated = sprintf('%f_', arg);
        
        if ~isempty(pastResults.(args_concated))
            result = pastResults({args_concated},{'Result'}).(1);
            return;
        end

        [e1m, e2m, Ltot] = twoairfoils_new(decodeAirfoil(encoder, arg(1:n)', 0.01, ch_xx, 200), ...
            decodeAirfoil(encoder, arg(n+1:2*n)', 0.01, ch_xx, 200), ...
            0.02, 0.05, 0.4);
        
        if validateAirfoils(e1m, e2m, 0.005) == false
            result = 0;
            return
        end

        foamCase = FOAMCase(u, meshScript(e1m, e2m, 20, 3.6, 0.005, 0.0002, 0.005, 1.2, 1, 0.1), Ltot, "ConsoleOutput", false, "FileOutput", true, "GAParams", arg);
        
        foamCase.solve();
        
        if foamCase.HasErrors
            result = 0;
        else
            result = - foamCase.Cl * foamCase.Cl_Cd;
        end

        cellResult = {'Args', result};
        pastResults = [pastResults; cellResult];
    end

    options = optimoptions('ga', 'MaxGenerations', 500, 'MaxStallGenerations', 500, 'CreationFcn', @initialValidPopulation, 'OutputFcn',@checkPopulation);

    ga_values = ga(@calculate_case, ...
        2*n, [], [], [], [], zeros(2*n, 1), 0.5*ones(2*n, 1), ...
        [], options); 
end

