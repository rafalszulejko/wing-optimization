function isOk = validateAirfoils(e1, e2, bl_thickness, check_angle)
    isOk = true;
    
    if ~issimplified(e1) || ~issimplified(e2)
        isOk = false;
        return
    end
    
%     if overlaps(polybuffer(e1, 2*bl_thickness), e2)
%         isOk = false;
%         return
%     end
    
    if check_angle && e2.Vertices(1,2) < e2.Vertices(ceil(length(e2.Vertices)/2),2)
        isOk = false;
        return
    end
end

