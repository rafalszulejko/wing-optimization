function script = meshScript(e1, e2, width, height, af_density, wall_density, z_thickness)
    g = Gmsh;
    
    %% points

    g.point([-0.2*width, height/2], wall_density);
    g.point([0.8*width, height/2], wall_density);
    g.point([0.8*width, -height/2], wall_density);
    g.point([-0.2*width, -height/2], wall_density);

    e1_length = length(e1.Vertices);
    e2_length = length(e2.Vertices);
    
    for i = 1:e1_length
        g.point(e1.Vertices(i, :), af_density);
    end
    
    for i = 1:e2_length
        g.point(e2.Vertices(i, :), af_density);
    end
    
    %% lines
    
    g.line(1, 4);    %Line 1 -> inlet
    g.line(2, 3);    %Line 2 -> outlet
    g.line(1, 2);    %Line 3 -> top wall
    g.line(3, 4);    %Line 4 -> bottom wall
    
    for i = 1:e1_length-1
        g.line(4 + i, 5 + i);
    end
    
    g.line(4 + e1_length, 5);

    for i = 1:e2_length-1
        g.line(4 + e1_length + i, 5+e1_length + i);
    end
    
    g.line(4 + e1_length + e2_length, 5 + e1_length);
    
    %% loops, surfaces and others
    
    g.loop([3 2 4 -1]);
    g.loop(5:4+e1_length);
    g.loop(5+e1_length:4+e1_length+e2_length);
    
    g.surface([1 2 3]);
    
    g.boundarylayer([5:3+e1_length, 5+e1_length:3+e1_length+e2_length], 0.05, 0.001, 0.02, 1.1, 1);
    g.box(-(0.2*0.2*width), 0.25*width, -1, 2, 0.1, 5,  0.25*width);
    g.box(-1, 2, -0.5*height, 0.5*height, 0.1, 5, 0.25*width);
    g.min([1 2 3]);
    g.setBackgroundField(4);
    
    g.extrude("1", z_thickness, 1, "surfaceVector");
    
    g.physicalsurface("frontAndBack", "{surfaceVector[0], 1}");
    g.physicalvolume("volume", "surfaceVector[1]");
    g.physicalsurface("walls", "{surfaceVector[2], surfaceVector[4]}");
    g.physicalsurface("outlet", "surfaceVector[3]");
    g.physicalsurface("inlet", "surfaceVector[5]");
    g.physicalsurface_range("airfoil", "surfaceVector", 6, 5 + e1_length + e2_length)
    
    script = g.GeoScript;
end