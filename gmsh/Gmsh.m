classdef Gmsh<handle
    %GMSH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        GeoScript
        PointCounter
        LineCounter
        LoopCounter
        SurfaceCounter
        FieldCounter
    end
    
    methods
        function obj = Gmsh()
            obj.GeoScript = "";
            obj.PointCounter = 1;
            obj.LineCounter = 1;
            obj.LoopCounter = 1;
            obj.SurfaceCounter = 1;
            obj.FieldCounter = 1;
        end

        function obj = point(obj, p, density)
            obj.GeoScript = obj.GeoScript + sprintf('Point(%d) = {%f, %f, 0, %f};\n', obj.PointCounter, p(1), p(2), density);
            obj.PointCounter = obj.PointCounter + 1;
        end

        function obj = line(obj, p1, p2)
            obj.GeoScript = obj.GeoScript + sprintf('Line(%d) = {%d, %d};\n', obj.LineCounter, p1, p2);
            obj.LineCounter = obj.LineCounter + 1;
        end
        
        function obj = circle(obj, p1, p2, p3)
            obj.GeoScript = obj.GeoScript + sprintf('Circle(%d) = {%d, %d, %d};\n', obj.LineCounter, p1, p2, p3);
            obj.LineCounter = obj.LineCounter + 1;
        end

        function obj = loop(obj, points)
            obj.GeoScript = obj.GeoScript + sprintf('Line loop(%d) = {', obj.LoopCounter);
            
            for a = 1:length(points) - 1
                obj.GeoScript = obj.GeoScript + sprintf('%d, ', points(a));
            end

            obj.GeoScript = obj.GeoScript + sprintf('%d};\n', points(end));
            
            obj.LoopCounter = obj.LoopCounter + 1;
        end

        function obj = surface(obj, curves)
            obj.GeoScript = obj.GeoScript + sprintf('Plane Surface(%d) = {', obj.SurfaceCounter);

            for a = 1:length(curves) - 1
                obj.GeoScript = obj.GeoScript + sprintf('%d, ', curves(a));
            end

            obj.GeoScript = obj.GeoScript + sprintf('%d};\n', curves(end));
            obj.SurfaceCounter = obj.SurfaceCounter + 1;
        end

        function obj = extrude(obj, surface, height, layers, vectorName)
            obj.GeoScript = obj.GeoScript + sprintf('%s[] = Extrude {0, 0, %g} {\n\tSurface{%s};\n\tLayers{%d};\n\tRecombine;\n};\n\n', vectorName, height, surface, layers);
        end

        function obj = physicalsurface(obj, name, value)
            obj.GeoScript = obj.GeoScript + sprintf('Physical Surface("%s") = %s;\n', name, value);
        end

        function obj = physicalsurface_range(obj, name, vector, rangeFrom, rangeTo)
            obj.GeoScript = obj.GeoScript + sprintf('Physical Surface("%s") = %s[{%d:%d}];\n', name, vector, rangeFrom, rangeTo);
        end

        function obj = physicalvolume(obj, name, value)
            obj.GeoScript = obj.GeoScript + sprintf('Physical Volume("%s") = %s;\n', name, value);
        end

        function obj = boundarylayer(obj, edgelist, hfar, hwall_n, thickness, ratio, Quads, fanPoints, fanEdges)
            obj.GeoScript = obj.GeoScript + sprintf('\nField[%d] = BoundaryLayer;\nField[%d].EdgesList = {', obj.FieldCounter, obj.FieldCounter);

            for a = 1:length(edgelist) - 1
                obj.GeoScript = obj.GeoScript + sprintf('%d, ', edgelist(a));
            end

            obj.GeoScript = obj.GeoScript + sprintf('%d};\nField[%d].hfar = %g;\nField[%d].hwall_n = %g;\nField[%d].thickness = %g;\nField[%d].ratio = %g;\nField[%d].Quads = %d;\nField[%d].FanPointsList = {', ...
                edgelist(end), ...
                obj.FieldCounter, hfar, ...
                obj.FieldCounter, hwall_n, ...
                obj.FieldCounter, thickness, ...
                obj.FieldCounter, ratio, ...
                obj.FieldCounter, Quads, ...
                obj.FieldCounter);

            for a = 1:length(fanPoints) - 1
                obj.GeoScript = obj.GeoScript + sprintf('%d, ', fanPoints(a));
            end
            
            obj.GeoScript = obj.GeoScript + sprintf('%d};\nBoundaryLayer Field = %d;\n\n', fanPoints(end), obj.FieldCounter);
            
            obj.GeoScript = obj.GeoScript + sprintf('Mesh.BoundaryLayerFanElements = %g;\n\n', fanEdges);
            
            obj.FieldCounter = obj.FieldCounter + 1;
        end

        function obj = box(obj, xmin, xmax, ymin, ymax, vin, vout, thickness)
            obj.GeoScript = obj.GeoScript + sprintf('\nField[%d] = Box;\nField[%d].Thickness = %g;\nField[%d].VIn = %g;\nField[%d].VOut = %g;\nField[%d].XMax = %d;\nField[%d].XMin = %d;\nField[%d].YMax = %d;\nField[%d].YMin = %d;\n', ...
                obj.FieldCounter, ...
                obj.FieldCounter, thickness, ...
                obj.FieldCounter, vin, ...
                obj.FieldCounter, vout, ...
                obj.FieldCounter, xmax, ...
                obj.FieldCounter, xmin, ...
                obj.FieldCounter, ymax, ...
                obj.FieldCounter, ymin);

            obj.FieldCounter = obj.FieldCounter + 1;
        end

        function obj = min(obj, fieldlist)
            obj.GeoScript = obj.GeoScript + sprintf('\nField[%d] = Min;\nField[%d].FieldsList = {', obj.FieldCounter, obj.FieldCounter);

            for a = 1:length(fieldlist) - 1
                obj.GeoScript = obj.GeoScript + sprintf('%d, ', fieldlist(a));
            end

            obj.GeoScript = obj.GeoScript + sprintf('%d};\n', fieldlist(end));

            obj.FieldCounter = obj.FieldCounter + 1;
        end
        
        function obj = setBackgroundField(obj, fieldId)
            obj.GeoScript = obj.GeoScript + sprintf('\nBackground Field = %d;\n', fieldId);
        end
        
        function obj = comment(obj, commentValue)
            obj.GeoScript = obj.GeoScript + commentValue;
        end
        
        function obj = distanceField(obj, pointsList)
            obj.GeoScript = obj.GeoScript + sprintf('\nField[%d] = Distance;\nField[%d].PointsList = {', obj.FieldCounter, obj.FieldCounter);
            
            for a = 1:length(pointsList) - 1
                obj.GeoScript = obj.GeoScript + sprintf('%d, ', pointsList(a));
            end

            obj.GeoScript = obj.GeoScript + sprintf('%d};\n', pointsList(end));

            obj.FieldCounter = obj.FieldCounter + 1;
        end
        
        function obj = mathEvalField(obj, fun)
            obj.GeoScript = obj.GeoScript + sprintf('\nField[%d] = MathEval;\nField[%d].F = Sprintf("%s");\n', obj.FieldCounter, obj.FieldCounter, fun);
            
            obj.FieldCounter = obj.FieldCounter + 1;
        end
        
        function obj = transfiniteCurve(obj, edgeList, val, nonlintype, nonlinval)
            obj.GeoScript = obj.GeoScript + sprintf('Transfinite Curve {');
            
            for a = 1:length(edgeList) - 1
                obj.GeoScript = obj.GeoScript + sprintf('%d, ', edgeList(a));
            end
            
            obj.GeoScript = obj.GeoScript + sprintf('%d} = %d', edgeList(end), val);

            obj.GeoScript = obj.GeoScript + sprintf(' Using %s %d', nonlintype, nonlinval);
            
            obj.GeoScript = obj.GeoScript + sprintf(';\n');
        end
    end
end