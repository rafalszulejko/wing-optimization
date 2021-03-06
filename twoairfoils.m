function twoairfoils(m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2, n)
    [e1x, e1y] = naca4digit(m1, p1, xx1, n, true);
    element1 = rotate(polyshape(e1x, e1y, 'Simplify', false), a1, [0 0]);
    
    [e2x, e2y] = naca4digit(m2, p2, xx2, n, true);
    element2 = translate(...
        scale(...
        rotate(...
        polyshape(e2x, e2y, 'Simplify', false), a2, [0 0]), s2), [x2 y2]);
    
    pf = figure;
    p = plot([element1 element2], 'FaceColor', 'black', 'FaceAlpha', 1);
    xlim([-1 2]);
    ylim([-0.5 1]);
    axis equal;
end