function result = decodeAirfoil(autoencoder, params, multiplier, xx_nodes)
    half = length(xx_nodes);
    decoded = multiplier*decode(autoencoder, params)';
    
    curve = cscvn([...
        [1 fliplr(xx_nodes) 0 xx_nodes 1];...
        [0 decoded(1:half) 0 decoded(half + 1:end) 0]]);
    
    points = fnplt(curve);
    points(:,[6 17 31 45 56 63 69 80 94 108 119 123]) = [];
    
    result = polyshape(points(1,:), -points(2,:));
end