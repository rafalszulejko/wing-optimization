function [element1, element2, Ltot] = twoairfoils_new(e1, e2, gap, overlap, e2scale)
    element1 = e1;
    element2 = scale(e2, e2scale);
    
    verticesLength = length(element1.Vertices);
    trailingEdgeTop = element1.Vertices(verticesLength, :) - element1.Vertices(verticesLength - 1, :);
    trailingEdgeTopAngle = rad2deg(atan(trailingEdgeTop(2)/trailingEdgeTop(1)));
    
    [xi, yi] = polyxpoly(overlap*ones(1,2), [-1 1], element2.Vertices(:,1), element2.Vertices(:,2));
    
    [bottomIntersectionPointY, bottomIntersectionPointIndex] = min(yi);
    
    bottomIntersectionPointX = xi(bottomIntersectionPointIndex);
    
    [~,~,nearestVertexToIntersectionIndex] = nearestvertex(element2,bottomIntersectionPointX,bottomIntersectionPointY);
    
    nearestVertexToIntersection = element2.Vertices(nearestVertexToIntersectionIndex, :);
    
    angle = rad2deg(atan((nearestVertexToIntersection(2) - bottomIntersectionPointY)/(nearestVertexToIntersection(1) - bottomIntersectionPointX)));

    element2 = rotate(element2, -angle, [bottomIntersectionPointX bottomIntersectionPointY]);
    
    [xbb, ybb] = boundingbox(element1);
    
    element2 = translate(element2, xbb(2) - bottomIntersectionPointX, -bottomIntersectionPointY);

    element2 = translate(element2, 0, gap);
    
    element2 = rotate(element2, trailingEdgeTopAngle, [xbb(2) ybb(2)]);
    
    [xbb, ybb] = boundingbox([element1 element2]);
    Ltot = sqrt(xbb(2)^2 + ybb(2)^2);
end

