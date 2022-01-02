function result = decodeAirfoil(autoencoder, params, multiplier, xx_nodes, numPoints)
    function cleaned = removeDuplicates(ptsVec)
       cleaned = [];
       for i = 2:length(ptsVec)
           if abs(ptsVec(1, i) - ptsVec(1, i-1)) > 1e-10
               cleaned = [cleaned, ptsVec(:, i)];
           end
       end
    end

    half = length(xx_nodes);
    decoded = multiplier*decode(autoencoder, params)';
    
    curve = cscvn2([...
        [1 fliplr(xx_nodes) 0 xx_nodes 1];...
        [0 decoded(1:half) 0 decoded(half + 1:end) 0]]);

%     curve = cscvn([...
%         [0 xx_nodes 1 1 fliplr(xx_nodes) 0];...
%         [0 decoded(half + 1:end) 0 0 decoded(1:half) 0]]);


    tMax = curve.breaks(end);
    tLE = curve.breaks(half+2);
    
    bottomHalf = linspace(tLE, tMax, numPoints/2);
    t = [linspace(0, tLE, numPoints/2), bottomHalf(2:end)];
    points = ppval(curve, t);
    
    result = polyshape(points(1,:), -points(2,:), 'Simplify',false);
end