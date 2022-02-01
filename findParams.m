function ga_values = findParams(encoder, hiddenLayerLength, population)
    
    addpath('openfoam')
    addpath('generator')
    addpath('gmsh')

    n = hiddenLayerLength;
    ch_xx = chebyshevs(n);
    u = 35.763;
    pastResults = zeros(1, 2*n+1);
    uuids = string.empty(0,2);
    
    function Population = initialValidPopulation(GenomeLength, FitnessFcn, options)
        Population = zeros(options.PopulationSize, GenomeLength);
        
        for i = 1:options.PopulationSize
            Population(i, :) = randomValidCase(GenomeLength);
            disp(sprintf('%f_', Population(i, :)));
        end
    end

    function out = randomValidCase(length)
        while true
            arg = 0.5*rand(1, length);
            [e1s, e2s, ~] = twoairfoils_new(decodeAirfoil_new(encoder, arg(1:n)', 0.01, ch_xx, 200), ...
                decodeAirfoil_new(encoder, arg(n+1:2*n)', 0.01, ch_xx, 200), ...
                0.02, 0.05, 0.4, 0.254);

            if validateAirfoils (e1s, e2s, 0.0025, true) == true
                out = arg;
                return;
            end
        end
    end

    function [state,options,optchanged] = checkPopulation(options,state,flag)
        optchanged = false;
        

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

        fprintf('Generation %d: %d dead members\n', state.Generation, zeroCount);

        if zeroCount > length(state.Score)/3 || mod(state.Generation, 5) == 0
            disp("Resetting dead population members to random valid values")
            for i = 1:zeroCount
                state.Population(zeroIndices(i), :) = randomValidCase(2*n);
                state.Score(zeroIndices(i)) = calculate_case(state.Population(zeroIndices(i), :));
            end
        end
    end

    function logResult(arg, result, uuid)
        pastResults = [pastResults; [arg, result]];
        if ~isempty(uuid)
            uuids = [uuids; [sprintf("%f_", arg), string(uuid)]];
        end
    end

    function result = calculate_case(arg)
        alreadyExistsId = find(sum(pastResults(:,1:2*n) == arg, 2)/(2*n) == 1);

        if ~isempty(alreadyExistsId)
            result = pastResults(alreadyExistsId, 2*n+1);
            return;
        end

        [e1m, e2m, Ltot] = twoairfoils_new(decodeAirfoil_new(encoder, arg(1:n)', 0.01, ch_xx, 200), ...
            decodeAirfoil_new(encoder, arg(n+1:2*n)', 0.01, ch_xx, 200), ...
            0.02, 0.05, 0.4, 0.254);
        
        if validateAirfoils(e1m, e2m, 0.0025, false) == false
            disp("Failed case during calculate_case validation")
            result = 0;
            logResult(arg, 0, string.empty());
            return
        end

        geoscript = meshScript(e1m, e2m, 3, 3.6, 0.003, 0.00002, 0.0025, 1.2, 1, 0.1);
        foamCase = FOAMCase(u, geoscript, Ltot, "Subdomains", 12 , "ConsoleOutput", false, "FileOutput", true, "GAParams", arg);
        
        foamCase.solve();
        
        if foamCase.HasErrors
            result = 0;
        else
            result = - foamCase.Cl * foamCase.Cl_Cd;
        end

        logResult(arg, result, foamCase.CaseName);
    end

    options = optimoptions('ga', ...
        'CreationFcn', @initialValidPopulation, ...
        'CrossoverFcn', 'crossoverscattered', ...
        'OutputFcn', @checkPopulation, ...
        'PlotFcn', {'gaplotscores', 'gaplotbestf', 'gaplotbestindiv'}, ...
        'PopulationSize', population, ...
        'Display', 'diagnose', ...
        'MaxStallGenerations', 10);

    ga_values = ga(@calculate_case, ...
        2*n, [], [], [], [], zeros(2*n, 1), [0.9 0.9 0.9 0.9 0.4 0.9 0.9 0.9 0.9 0.4], ...
        [], options);

    save(sprintf('results_%s.mat', datestr(now, 'yyyymmdd_HHMMSS')), 'ga_values', 'pastResults', 'uuids');
end

