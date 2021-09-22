function result = calculate_case(m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2, n, domainX, domainY, AFDensity, wallDensity, z_thickness)
    caseName = datestr(now, 'yyyymmdd_HHMMSS') + "_" + sprintf('%g_%g_%g_%g_%g_%g_%g_%g_%g_%g_%g', m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2);
    geoFileName = caseName + "/case.geo";
    
    [e1, e2] = twoairfoils(m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2, n);
    if overlaps(e1, e2)
        result = 0;
        return
    end
    
    e1.Vertices(51,:) = [];
    e2.Vertices(51,:) = [];
    
    mkdir(caseName);
    %copyfile('case/*', caseName + "/")
    
    write_geo(geoFileName, e1, e2, domainX, domainY, AFDensity, wallDensity, z_thickness);
    
    system("wsl bash -i runcase.sh " + caseName);
    
    coefs = readtable(caseName + "/postProcessing/forceCoeffs1/0/forceCoeffs.dat");
    result = coefs.Cl(end)/coefs.Cd(end);
end