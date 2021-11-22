classdef Domain
    
    properties
        Width
        Height
        Depth
        WallDensity
        AFDensity
        BLThickness
    end
    
    methods
        function obj = Domain(width, height, depth, walldensity, afdensity)
            obj.Width = width;
            obj.Height = height;
            obj.Depth = depth;
            obj.WallDensity = walldensity;
            obj.AFDensity = afdensity;
        end
    end
end

