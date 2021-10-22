function result = calculate_case(e1, a1, e2, a2, x2, y2, s2, domainX, domainY, AFDensity, wallDensity, z_thickness, bl_thickness, solver_cores)
    tic
    
    if issimplified(e1) || issimplified(e2)
        result = 0;
        return
    end

    caseName = datestr(now, 'yyyymmdd_HHMMSS');
    geoFileName = caseName + "/case.geo";
    resultFileName = caseName + "/results.txt";
    
    [element1, element2] = twoairfoils(e1, a1, e2, a2, x2, y2, s2);
    
    if overlaps(polybuffer(element1, 2*bl_thickness), element2)
        result = 0;
        return
    end
    
    mkdir(caseName);
    draw_airfoils(caseName, element1, element2);
    
    meshFile = fopen(geoFileName, 'w');
    fprintf(meshFile, '%s', meshScript(element1, element2, domainX, domainY, AFDensity, wallDensity, z_thickness));
    fclose(meshFile);
    
    if system("wsl bash -i runcase.sh " + caseName + " " + solver_cores) ~= 0
        error("Case " + caseName + " finished with error.");
    end
    
    coefs = readtable(caseName + "/postProcessing/forceCoeffs1/0/forceCoeffs.dat");

    cl = table2array(coefs(end, 4));
    cd = table2array(coefs(end, 3));
    result = cl/cd;
    totaltime = toc;
    
    resultFile = fopen(resultFileName, 'w');
    fprintf(resultFile, 'CL\t%g\nCD\t%g\nL/D\t%g\ntime\t%g', cl, cd, result, totaltime);
    fclose(resultFile);
end