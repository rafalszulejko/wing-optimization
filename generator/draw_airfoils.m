function draw_airfoils(casename, e1 ,e2)
    pf = figure;
    p = plot([e1 e2], 'FaceColor', 'black', 'FaceAlpha', 1);
    [xbb, ybb] = boundingbox([e1 e2]);
    xlim(xbb);
    ylim(ybb);
    axis equal;
    saveas(pf, casename + "/geometry.png");
    close(pf);
end

