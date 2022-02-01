function g = meshScript(main, flap, R, exponent, hfar, hwall_n, thickness, ratio, Quads, zDepth)
    %% C-shaped unstructured mesh script with two airfoils and cell size specified by a function based on distance from airfoils. Need to disable point mesh sizing in gmsh to proceed. 

    g = Gmsh;
    
    %% points

    g.point([0 0], 1);
    g.point([0 R], 1);
    g.point([1.2*R R], 1);
    g.point([1.2*R -R], 1);
    g.point([0 -R], 1);

    main_length = length(main.Vertices);
    flap_length = length(flap.Vertices);
    
    mainFirstPointIndex = g.PointCounter;
    
    for i = 1:main_length
        g.point(main.Vertices(i, :), 1);
    end
    
    flapFirstPointIndex = g.PointCounter;
    
    for i = 1:flap_length
        g.point(flap.Vertices(i, :), 1);
    end
    
    %% lines
    
    g.circle(2,1,5); %Arc 1 -> inlet
    g.line(2, 3);    %Line 2 -> outlet
    g.line(3, 4);    %Line 3 -> top wall
    g.line(4, 5);    %Line 4 -> bottom wall
    
    mainFirstEdgeLineIndex = g.LineCounter;
    
    for i = mainFirstPointIndex:mainFirstPointIndex + main_length - 2
        g.line(i, i + 1);
    end
    
    g.line(mainFirstPointIndex + main_length - 1, mainFirstPointIndex);

    flapFirstEdgeLineIndex = g.LineCounter;
    
    for i = flapFirstPointIndex:flapFirstPointIndex + flap_length - 2
        g.line(i, i + 1);
    end
    
    g.line(flapFirstPointIndex + flap_length - 1, flapFirstPointIndex);
    
    %% loops, surfaces and others
    
    g.loop([3 2 4 -1]);
    g.loop(mainFirstEdgeLineIndex:mainFirstEdgeLineIndex + main_length - 1);
    g.loop(flapFirstEdgeLineIndex:flapFirstEdgeLineIndex + flap_length - 1);
    
    g.surface([1 2 3]);
    
%     g.transfiniteCurve(mainFirstEdgeLineIndex:mainFirstEdgeLineIndex + main_length - 1, refineMain, "Progression", 1);
%     g.transfiniteCurve(flapFirstEdgeLineIndex:flapFirstEdgeLineIndex + flap_length - 1, refineFlap, "Progression", 1);
    
    boundaryLayerFieldId = g.FieldCounter;
    g.boundarylayer(mainFirstEdgeLineIndex:mainFirstEdgeLineIndex + main_length + flap_length - 1, hfar, hwall_n, thickness, ratio, Quads, [mainFirstPointIndex, flapFirstPointIndex], 20);
    
    distanceFieldId = g.FieldCounter;
    g.distanceField(mainFirstPointIndex:mainFirstPointIndex + main_length + flap_length - 1);
    
    mathEvalFieldId = g.FieldCounter;
    g.mathEvalField(sprintf('min(%g*(F%g+1-%g)^%g, 1)', hfar, distanceFieldId, thickness, exponent));
    
    minFieldId = g.FieldCounter;
    g.min([boundaryLayerFieldId mathEvalFieldId]);
    g.setBackgroundField(minFieldId);
    
    g.extrude("1", zDepth, 1, "surfaceVector");
    
    g.physicalsurface("frontAndBack", "{surfaceVector[0], 1}");
    g.physicalvolume("volume", "surfaceVector[1]");
    g.physicalsurface("walls", "{surfaceVector[3], surfaceVector[5]}");
    g.physicalsurface("outlet", "surfaceVector[2]");
    g.physicalsurface("inlet", "surfaceVector[4]");
    g.physicalsurface_range("airfoil", "surfaceVector", mainFirstEdgeLineIndex + 1, mainFirstEdgeLineIndex + main_length + flap_length);
end