function result = chebyshevs(n)
    result = zeros(1, n);
    
    for i = 1:n
        result(i) = cos(pi*(2*i-1)/(2*n));
    end
    
    result = -(result - 1)/2;
end