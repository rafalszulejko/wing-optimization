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
                obj.CaseName = java.util.UUID.randomUUID.toString;
            end

            mustBeA(foamsetup, "FOAMSetup")
            obj.FoamSetup = foamsetup;
            
            mustBeA(geo, "Gmsh")
            obj.GmshGeo = geo;
            
            obj.GeoFileName = name + "/case.geo";
            obj.ResultFileName = name + "/results.txt";
            obj.ParamsFileName = name + "/params.txt";
            
            obj.LRef = lref;
            obj.ARef = lref * obj.FoamSetup.ZThickness;
        end

        function obj = solve(obj)
            if isempty(obj.GmshGeo)
                obj.HasErrors = true;
                return
            end
            
            mkdir(obj.CaseName);
            
            paramsFile = fopen(paramsFileName, 'w');
            fprintf(paramsFile, '%g ', ga_params);
            fclose(paramsFile);

            meshFile = fopen(geoFileName, 'w');
            fprintf(meshFile, '%s', meshScript(element1, element2, domainX, domainY, AFDensity, wallDensity, z_thickness));
            fclose(meshFile);
            
            if system(obj.FoamSetup.BashExecutable + "runcase.sh " + caseName + " " + obj.FoamSetup.ForceCoeffsWriteInterval + " " + obj.FoamSetup.ForceCoeffsMagUInf + " " + obj.LRef + " " + obj.ARef) ~= 0
                disp("Case " + caseName + " finished with error.");
                obj.HasErrors = true;
                return;
            end
            
            coefs = readtable(caseName + "/postProcessing/forceCoeffs1/0/forceCoeffs.dat");

            obj.Cl = table2array(coefs(end, 4));
            obj.Cd = table2array(coefs(end, 3));
            obj.Cl_Cd = obj.Cl/obj.Cd;
            totaltime = toc;

            resultFile = fopen(resultFileName, 'w');
            fprintf(resultFile, 'CL\t%g\nCD\t%g\nL/D\t%g\ntime\t%g', cl, cd, result, totaltime);
            fclose(resultFile);
        end
    end
end

