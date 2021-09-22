function write_geo(filename, e1, e2, width, height, af_density, wall_density, z_thickness)
%WRITE_GEO Write airfols and rectangular domain into GMSH .geo file
%   Detailed explanation goes here
    assert(~isfile(filename));
    assert(isa(e1, 'polyshape'));
    assert(isa(e2, 'polyshape'));
    pointcounter = 1;
    linecounter = 1;
    loopcounter = 1;
    surfacecounter = 1;
    
    file = fopen(filename, 'w');
    
    function writepoint(p, density)
        fprintf(file, 'Point(%d) = {%f, %f, 0, %f};\n', pointcounter, p(1), p(2), density);
        pointcounter = pointcounter + 1;
    end

    function writeline(p1, p2)
        fprintf(file, 'Line(%d) = {%d, %d};\n', linecounter, p1, p2);
        linecounter = linecounter + 1;
    end

    function writeloop(points)
        fprintf(file, 'Line loop(%d) = {', loopcounter);
        loopcounter = loopcounter + 1;
        
        for a = 1:length(points) - 1
            fprintf(file, '%d, ', points(a));
        end
        
        fprintf(file, '%d};\n', points(length(points)));
    end

    function writesurface(curves)
        fprintf(file, 'Plane Surface(%d) = {', surfacecounter);
        surfacecounter = surfacecounter + 1;
        
        for a = 1:length(curves) - 1
            fprintf(file, '%d, ', curves(a));
        end
        
        fprintf(file, '%d};\n', curves(length(curves)));
    end

    function extrude(surface, height, layers, vectorName)
        fprintf(file, '%s[] = Extrude {0, 0, %g} {\n\tSurface{%s};\n\tLayers{%d};\n\tRecombine;\n};\n', vectorName, height, surface, layers);
    end

    function physicalsurface(name, value)
        fprintf(file, 'Physical Surface("%s") = %s;\n', name, value);
    end

    function physicalsurface_range(name, vector, rangeFrom, rangeTo)
        fprintf(file, 'Physical Surface("%s") = %s[{%d:%d}];\n', name, vector, rangeFrom, rangeTo);
    end

    function physicalvolume(name, value)
        fprintf(file, 'Physical Volume("%s") = %s;\n', name, value);
    end

    %% points

    writepoint([-width/2, height/2], wall_density);
    writepoint([width/2, height/2], wall_density);
    writepoint([width/2, -height/2], wall_density);
    writepoint([-width/2, -height/2], wall_density);

    e1_length = length(e1.Vertices);
    e2_length = length(e2.Vertices);
    
    fprintf(file, '\n//A1\n');
    
    for i = 1:e1_length
        writepoint(e1.Vertices(i, :), af_density);
    end
    
    fprintf(file, '\n//A2\n');
    
    for i = 1:e2_length
        writepoint(e2.Vertices(i, :), af_density);
    end
    
    %% lines
    
    writeline(1, 4);    %Line 1 -> inlet
    writeline(2, 3);    %Line 2 -> outlet
    writeline(1, 2);    %Line 3 -> top wall
    writeline(3, 4);    %Line 4 -> bottom wall
    
    fprintf(file, '\n//A1\n');
    
    for i = 1:e1_length-1
        writeline(4 + i, 5 + i);
    end
    
    writeline(4 + e1_length, 5);
    
    fprintf(file, '\n//A2\n');
    
    for i = 1:e2_length-1
        writeline(4 + e1_length + i, 5+e1_length + i);
    end
    
    writeline(4 + e1_length + e2_length, 5 + e1_length);
    
    %% loops, surfaces and others
    
    writeloop([3 2 4 -1]);
    writeloop(5:4+e1_length);
    writeloop(5+e1_length:4+e1_length+e2_length);
    
    writesurface([1 2 3]);
    
    extrude("1", z_thickness, 1, "surfaceVector");
    
    physicalsurface("frontAndBack", "{surfaceVector[0], 1}");
    physicalvolume("volume", "surfaceVector[1]");
    physicalsurface("walls", "{surfaceVector[2], surfaceVector[4]}");
    physicalsurface("outlet", "surfaceVector[3]");
    physicalsurface("inlet", "surfaceVector[5]");
    physicalsurface_range("airfoil", "surfaceVector", 6, 5 + e1_length + e2_length)
    
    fclose(file);
end

