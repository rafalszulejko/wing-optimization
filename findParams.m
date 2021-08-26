function [m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2] = findParams(n_points, domain_X, domain_Y, z_thickness)
    ga_values = ga(@(m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2) calculate_case(m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2, n_points, domain_X, domain_Y, z_thickness), 11); 
    [m1, p1, xx1, a1, m2, p2, xx2, a2, x2, y2, s2] = ga_values;
end

