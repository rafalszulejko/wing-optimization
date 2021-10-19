function draw_airfoils(casename, e1 ,e2)
    pf = figure;
    p = plot([e1 e2], 'FaceColor', 'black', 'FaceAlpha', 1);
    xlim([-0.2 1.2]);
    ylim([-0.2 0.6]);
    axis equal;
    saveas(pf, casename + "/geometry.png");
    close(pf);
end

