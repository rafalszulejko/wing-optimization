function result = calculate_case(m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2, n, domainX, domainY, AFDensity, wallDensity, z_thickness)
    caseName = datestr(now, 'yyyymmdd_HHMMSS') + "_" + sprintf('%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d', m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2);
    geoFileName = caseName + "/case.geo";
    mshFileName = caseName + "/case.msh";
    [e1, e2] = twoairfoils(m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2, n);
    e1.Vertices(51,:) = [];
    e2.Vertices(51,:) = [];
    mkdir(casename);
    write_geo(geoFileName, e1, e2, domainX, domainY, AFDensity, wallDensity, z_thickness);
    system("gmsh " + geoFile + " -2 -o + " + mshFileName);
    system("gmshToFoam " + mshFileName);
    
end

