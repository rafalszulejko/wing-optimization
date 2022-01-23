classdef FOAMCase<handle

    properties
        CaseName;
        GeoFileName;
        ResultFileName;
        ParamsFileName;
        
        ToleranceP;
        ToleranceU;
        ToleranceNuTilda;

        ResidualP;
        ResidualU;
        ResidualNuTilda;
        
        ForceCoeffsWriteInterval;
        ForceCoeffsMagUInf;
        
        UInternalField;
        
        Subdomains;
        
        FileOutput;
        ConsoleOutput;
        
        BashExecutable;        
        GmshExecutable;
        
        HasErrors = false;
        
        LRef;
        ARef;
        
        GmshGeo;
        
        Cl;
        Cd;
        Cl_Cd;
        TotalTime;
    end
    
    methods
        function obj = FOAMCase(U, geo, lref, options)
            arguments
                U double
                geo Gmsh
                lref double
                options.CaseName = java.util.UUID.randomUUID.toString.toCharArray'
                options.ZThickness = 0.1;
                options.ToleranceP = '1e-6'
                options.ToleranceU = '1e-6'
                options.ToleranceNuTilda = '1e-6'
                options.ResidualP = '1e-5'
                options.ResidualU = '1e-5'
                options.ResidualNuTilda = '1e-5'
                options.ForceCoeffsWriteInterval = 10
                options.Subdomains = 2
                options.BashExecutable = "bash -i"
                options.GmshExecutable = "gmsh"
                options.FileOutput = false;
                options.ConsoleOutput = true;
                options.GAParams = [];
            end

            obj.GmshGeo = geo;
            
            obj.CaseName = options.CaseName;
            obj.GeoFileName = obj.CaseName + "/case.geo";
            obj.ResultFileName = obj.CaseName + "/results.txt";
            obj.ParamsFileName = obj.CaseName + "/params.txt";

            obj.ToleranceP = options.ToleranceP;
            obj.ToleranceU = options.ToleranceU;
            obj.ToleranceNuTilda = options.ToleranceNuTilda;

            obj.ResidualP = options.ResidualP;
            obj.ResidualU = options.ResidualU;
            obj.ResidualNuTilda = options.ResidualNuTilda;
            
            obj.ForceCoeffsWriteInterval = options.ForceCoeffsWriteInterval;
            obj.ForceCoeffsMagUInf = U;
            obj.LRef = lref;
            obj.ARef = lref * options.ZThickness;

            obj.UInternalField = [U 0 0];

            obj.Subdomains = options.Subdomains;

            obj.FileOutput = options.FileOutput;
            obj.ConsoleOutput = options.ConsoleOutput;

            obj.BashExecutable = options.BashExecutable;
            obj.GmshExecutable = options.GmshExecutable;

            obj.copyAndFillTemplate();
            obj.writeParams(options.GAParams);
            if ~isempty(obj.GmshGeo)
                obj.writeGmshScript();
            end
        end

        function obj = copyAndFillTemplate(obj)
            if ~isfolder(obj.CaseName)
                mkdir(obj.CaseName);
            end

            copyfile("openfoam/template/", obj.CaseName);

            if ~isfile("runcase.sh")
                copyfile("openfoam/runcase.sh", ".");
            end

            uinternalstr = mat2str(obj.UInternalField);
            
            obj.replaceInFile(obj.CaseName + "/0/U", '${INTERNALFIELD}', convertCharsToStrings(uinternalstr(2:end-1)));

            obj.replaceInFile(obj.CaseName + "/system/fvSolution", ...
                {'${TOLERANCE_P}', '${TOLERANCE_U}', '${TOLERANCE_NUTILDA}', '${RESIDUAL_P}', '${RESIDUAL_U}', '${RESIDUAL_NUTILDA}'}, ...
                {obj.ToleranceP, obj.ToleranceU, obj.ToleranceNuTilda, obj.ResidualP, obj.ResidualU, obj.ResidualNuTilda});

            obj.replaceInFile(obj.CaseName + "/system/decomposeParDict", '${SUBDOMAINS}', num2str(obj.Subdomains));

            obj.replaceInFile(obj.CaseName + "/system/controlDict", ...
                {'${FORCECOEFFS_INTERVAL}', '${FORCECOEFFS_MAGUINF}', '${FORCECOEFFS_LREF}', '${FORCECOEFFS_AREF}'}, ...
                {num2str(obj.ForceCoeffsWriteInterval), num2str(obj.ForceCoeffsMagUInf), num2str(obj.LRef), num2str(obj.ARef)});

        end

        function replaceInFile(obj, filename, old, new)
            srcText = fileread(filename);
            file = fopen(filename, 'w');
            fprintf(file, '%s', replace(srcText, old, new));
            fclose(file);
        end

        function obj = writeParams(obj, GAParams)
            if ~isempty(GAParams)
                paramsFile = fopen(obj.ParamsFileName, 'w');
                fprintf(paramsFile, '%g ', GAParams);
                fclose(paramsFile);
            end
        end

        function obj = writeGmshScript(obj)
            meshFile = fopen(obj.GeoFileName, 'w');
            fprintf(meshFile, '%s', obj.GmshGeo.GeoScript);
            fclose(meshFile);
        end

        function obj = writeResults(obj)
            coefs = readtable(obj.CaseName + "/postProcessing/forceCoeffs1/0/forceCoeffs.dat");

            obj.Cl = mean(table2array(coefs(end-5:end, 4)));
            obj.Cd = mean(table2array(coefs(end-5:end, 3)));
            obj.Cl_Cd = obj.Cl/obj.Cd;
            
            resultFile = fopen(obj.ResultFileName, 'w');
            fprintf(resultFile, 'CL\t%g\nCD\t%g\nL/D\t%g\ntime\t%g', obj.Cl, obj.Cd, obj.Cl_Cd, obj.TotalTime);
            fclose(resultFile);
        end

        function obj = solve(obj)
            if obj.FileOutput && obj.ConsoleOutput
                log = " | tee " + obj.CaseName + "/log.log 2>&1";
            elseif obj.FileOutput
                log = " > " + obj.CaseName + "/log.log 2>&1";
            elseif obj.ConsoleOutput
                log = "";
            else
                log = " > /dev/null 2>&1";
            end

            disp("Solving case " + obj.CaseName);
            tic

            if system(obj.BashExecutable + " runcase.sh " + obj.CaseName + " " + obj.Subdomains + log) ~= 0
                disp("Case " + obj.CaseName + " finished with error.");
                obj.HasErrors = true;
                toc
                return;
            end

            obj.TotalTime = toc;

            if ~obj.HasErrors
                obj.writeResults();
            end
        end
    end
end

