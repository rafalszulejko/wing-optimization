function element = naca4digit(maxcamber, maxcamberpos, thickness, n_points, flipped)
%NACA4DIGIT generates xy coordinates of a  NACA 4-digit airfoil
%   assertions are self-explanatory
%   maxcamber, maxcamberpos and thickness are  expressed in percents
    mustBePositive([maxcamber maxcamberpos thickness n_points])
    mustBeLessThanOrEqual(maxcamber, 9.5)
    mustBeLessThanOrEqual(maxcamberpos, 90)
    mustBeLessThanOrEqual(thickness, 40)
    mustBeLessThanOrEqual(n_points, 400)
    assert(islogical(flipped), 'The airfoil must be either normal(false) or flipped(true)')
    
    maxcamberpos = maxcamberpos/100;
    maxcamber = maxcamber/100;
    thickness = thickness/100;
    
    function yc = camberline(x)
        if x < maxcamberpos
            yc = (maxcamber/(maxcamberpos^2))*(2*maxcamberpos*x - x^2);
        else
            yc = (maxcamber/((1 - maxcamberpos)^2))*(1 - 2*maxcamberpos + 2*maxcamberpos*x - x^2);
        end
    end

    function dycdx = slope(x)
        if x < maxcamberpos
            dycdx = (2*maxcamber/(maxcamberpos^2))*(maxcamberpos - x);
        else
            dycdx = (2*maxcamber/((1 - maxcamberpos)^2))*(maxcamberpos - x);
        end
    end

    function yt = thickness_d(x)
        yt = (thickness/0.2)*(0.2969*(x^0.5) - 0.126*x - 0.3516*(x^2) + 0.2843*(x^3) - 0.1036*(x^4));
    end

    X = zeros(2*floor(n_points/2), 1);
    Y = zeros(2*floor(n_points/2), 1);

    for i = 1:floor(n_points/2)
        beta = pi * i / floor(n_points/2);
        x = (1 + cos(beta))/2;
        theta = atan(slope(x));
        thickness_x = thickness_d(x);
        
        % upper surface
        X(i) = x - thickness_x * sin(theta);
        Y(i) = camberline(x) + thickness_x * cos(theta);
        
        % lower surface
        X(2*floor(n_points/2) - i + 1) = x + thickness_x * sin(theta);
        Y(2*floor(n_points/2) - i + 1) = camberline(x) - thickness_x * cos(theta);
    end
    
    if flipped
        Y = -Y;
    end
    
    element = polyshape(X, Y, 'Simplify', false);
    element.Vertices(n/2 + 1,:) = [];
end