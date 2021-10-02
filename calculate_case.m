function result = calculate_case(m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2, n, domainX, domainY, AFDensity, wallDensity, z_thickness, bl_thickness)
    caseName = datestr(now, 'yyyymmdd_HHMMSS') + "_" + sprintf('%g_%g_%g_%g_%g_%g_%g_%g_%g_%g_%g', m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2);
    geoFileName = caseName + "/case.geo";
    
    [e1, e2] = twoairfoils(m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2, n);
    if overlaps(polybuffer(e1, 2*bl_thickness), e2)
        result = 0;
        return
    end
    
    mkdir(caseName);
    
    write_geo(geoFileName, e1, e2, domainX, domainY, AFDensity, wallDensity, z_thickness);
    
    if system("wsl bash -i runcase.sh " + caseName) ~= 0
        error("Case " + caseName + " finished with error.");
    end
    
    coefs = readtable(caseName + "/postProcessing/forceCoeffs1/0/forceCoeffs.dat");
    result = table2array(coefs(end, 4))/table2array(coefs(end, 3));
    
    plot_result(caseName, e1, e2, result);
end