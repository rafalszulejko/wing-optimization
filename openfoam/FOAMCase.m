classdef FOAMCase<handle

    properties
        CaseName;
        GeoFileName;
        ResultFileName;
        ParamsFileName;
        
        FoamSetup;
        
        HasErrors = false;
        
        LRef;
        ARef;
        
        GmshGeo;
        
        Cl;
        Cd;
        Cl_Cd;
    end
    
    methods
        function obj = FOAMCase(name, foamsetup, geo, lref)
            if ~isempty(name)
                obj.CaseName = name;
            else
                newname = java.util.UUID.randomUUID.toString;
                obj.CaseName = newname.toCharArray';
            end

            mustBeA(foamsetup, "FOAMSetup")
            obj.FoamSetup = foamsetup;
            
            mustBeA(geo, "Gmsh")
            obj.GmshGeo = geo;
            
            obj.GeoFileName = obj.CaseName + "/case.geo";
            obj.ResultFileName = obj.CaseName + "/results.txt";
            obj.ParamsFileName = obj.CaseName + "/params.txt";
            
            obj.LRef = lref;
            obj.ARef = lref * obj.FoamSetup.ZThickness;
        end

        function obj = solve(obj, ga_params)
            tic
            if isempty(obj.GmshGeo)
                obj.HasErrors = true;
                return
            end
            
            mkdir(obj.CaseName);
            
            if ~isempty(ga_params)
                paramsFile = fopen(obj.ParamsFileName, 'w');
                fprintf(paramsFile, '%g ', ga_params);
                fclose(paramsFile);
            end

            meshFile = fopen(obj.GeoFileName, 'w');
            fprintf(meshFile, '%s', obj.GmshGeo.GeoScript);
            fclose(meshFile);
            
            if system(obj.FoamSetup.BashExecutable + "runcase.sh " + obj.CaseName + " " + obj.FoamSetup.ForceCoeffsWriteInterval + " " + obj.FoamSetup.ForceCoeffsMagUInf + " " + obj.LRef + " " + obj.ARef) ~= 0
                disp("Case " + obj.CaseName + " finished with error.");
                obj.HasErrors = true;
                return;
            end
            
            coefs = readtable(obj.CaseName + "/postProcessing/forceCoeffs1/0/forceCoeffs.dat");

            obj.Cl = table2array(coefs(end, 4));
            obj.Cd = table2array(coefs(end, 3));
            obj.Cl_Cd = obj.Cl/obj.Cd;
            totaltime = toc;

            resultFile = fopen(obj.ResultFileName, 'w');
            fprintf(resultFile, 'CL\t%g\nCD\t%g\nL/D\t%g\ntime\t%g', obj.Cl, obj.Cd, obj.Cl_Cd, totaltime);
            fclose(resultFile);
        end
    end
end

