classdef FOAMSetup<handle
    % FOAMSetup setup once, use multiple times

    properties
        ZThickness;
        
        ToleranceP;
        ToleranceU;
        ToleranceNuTilda;
        
        ForceCoeffsWriteInterval;
        ForceCoeffsMagUInf;
        ForceCoeffsLRef;
        ForceCoeffsARef;
        
        UInternalField = [0 0 0];
        
        Subdomains = 0;
        
        FileOutput = false;
        
        BashExecutable;        
        GmshExecutablePath;

        SetupScript = "set -e\n";
    end
    
    methods
        function obj = FOAMSetup()
        end

        function obj = appendSetupScript(obj, str)
            obj.SetupScript = obj.SetupScript + sprintf('%s\n', str);
        end
        
        function obj = exportVariable(obj, name, value)
            if isnumeric(value)
                obj.appendSetupScript(sprintf('export %s="%g"', name, value));
            else
                obj.appendSetupScript(sprintf('export %s="%s"', name, value));
            end
        end
        
        function obj = envSubst(obj, file)
            obj.appendSetupScript(sprintf('envsubst < openfoam/template/%s > case/%s', file, file));
        end
        
        function obj = prepareRunScript(obj)
            
        end
        
        function obj = prepare(obj)
            obj.SetupScript = "";
            obj.appendSetupScript("cp -r openfoam/template/* case/");

            obj.exportVariable("TOLERANCE_P", obj.ToleranceP);
            obj.exportVariable("TOLERANCE_U", obj.ToleranceU);
            obj.exportVariable("TOLERANCE_NUTILDA", obj.ToleranceNuTilda);
            
            obj.exportVariable("INTERNALFIELD", mat2str(obj.UInternalField));
            
            obj.envSubst("0/U");
            
            
            obj.envSubst("system/fvSolution");
            
            obj.exportVariable("GMSH_PATH", obj.GmshExecutablePath);

            obj.exportVariable("SUBDOMAINS", obj.Subdomains);
            obj.envSubst("system/decomposeParDict");
            
            if obj.FileOutput == true
                obj.exportVariable("LOG_GMSH", ">> $1/log/gmsh.log");
                obj.exportVariable("LOG_GMSH_TO_FOAM", ">> $1/log/gmshToFoam.log");
                obj.exportVariable("LOG_CHANGE_DICTIONARY", ">> $1/log/changeDictionary.log");
                obj.exportVariable("LOG_DECOMPOSEPAR", ">> $1/log/decomposePar.log");
                obj.exportVariable("LOG_SIMPLEFOAM", ">> $1/log/simpleFoam.log");
                obj.exportVariable("LOG_RECONSTRUCTPAR", ">> $1/log/reconstructPar.log");
            end

            obj.appendSetupScript("envsubst < openfoam/runcase.sh > runcase.sh");
            
            if isfolder('case')
                rmdir('case', 's');
            end
            
            mkdir('case');
            
            setupScriptFile = fopen('setup.sh', 'w');
            fprintf(setupScriptFile, '%s', obj.SetupScript);
            fclose(setupScriptFile);
            
            if system(obj.BashExecutable + "setup.sh") ~= 0
                error("Saving FOAM template failed");
            end

            delete('setup.sh');
        end
        
        function obj = clean(obj)
            rmdir('case', 's');
            delete('runcase.sh');
        end
    end
end

