function result = calculate_case(e1, a1, e2, a2, x2, y2, s2, domainX, domainY, AFDensity, wallDensity, z_thickness, bl_thickness, solver_cores)
    caseName = datestr(now, 'yyyymmdd_HHMMSS');
    geoFileName = caseName + "/case.geo";
    
    [element1, element2] = twoairfoils(e1, a1, e2, a2, x2, y2, s2);
    
    if overlaps(polybuffer(element1, 2*bl_thickness), element2)
        result = 0;
        return
    end
    
    mkdir(caseName);
    
    meshFile = fopen(geoFileName, 'w');
    fprintf(meshFile, '%s', meshScript(element1, element2, domainX, domainY, AFDensity, wallDensity, z_thickness));
    fclose(meshFile);
    
    if system("wsl bash -i runcase.sh " + caseName + " " + solver_cores) ~= 0
        error("Case " + caseName + " finished with error.");
    end
    
    coefs = readtable(caseName + "/postProcessing/forceCoeffs1/0/forceCoeffs.dat");
    result = table2array(coefs(end, 4))/table2array(coefs(end, 3));
    
    plot_result(caseName, element1, element2, result);
end