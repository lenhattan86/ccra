function [ouput] = randomFunction( max, min, size)
    ouput = round(min + (max-min).*rand(size,1));
    if ouput==0
        ouput = 1;
    end
end

