function result = decodeAirfoil_new(autoencoder, params, multiplier, xx_nodes, numPoints)

    half = length(xx_nodes);
    decodedCamberAndThickness = multiplier*decode(autoencoder, params)';
    camberNodes = decodedCamberAndThickness(1:length(decodedCamberAndThickness)/2);
    thicknesses = decodedCamberAndThickness(length(decodedCamberAndThickness)/2 + 1 : end);
    decoded = [camberNodes + thicknesses, camberNodes - thicknesses];
    
    curve = cscvn2([...
        [1 fliplr(xx_nodes) 0 xx_nodes 1];...
        [0 decoded(1:half) 0 decoded(half + 1:end) 0]]);

    tMax = curve.breaks(end);
    tLE = curve.breaks(half+2);
    
    bottomHalf = linspace(tLE, tMax, numPoints/2);
    t = [linspace(0, tLE, numPoints/2), bottomHalf(2:end)];
    points = ppval(curve, t);
    
    result = polyshape(points(1,:), -points(2,:), 'Simplify',false);
end