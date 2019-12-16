function [output] = NLmeansfilter(input, t, f, h)
[m, n] = size(input);
output = zeros(m, n);
input2 = padarray(input, [f, f], 'replicate');
kernel = fspecial('gaussian', [2 * f + 1, 2 * f + 1], 1);
halt = waitbar(0);
for i = 1:m
    for j = 1:n
        waitbar(i / m, halt);
        i1 = i + f;
        j1 = j + f;
        W1 = input2(i1 - f:i1 + f, j1 - f:j1 + f);
        average = 0;
        sweight = 0;
        rmin = max(i1 - t,f + 1);
        rmax = min(i1 + t,m + f);
        smin = max(j1 - t,f + 1);
        smax = min(j1 + t,n + f);
        for r = rmin:rmax
            for s = smin:smax
                if(r == i1 && s == j1)
                    continue;
                end
                W2 = input2(r - f:r + f, s - f:s + f);
                d = sum(sum(kernel .* ((W1 - W2) .^ 2)));
                w = exp(-d / (h ^ 2));      
                sweight = sweight + w;
                average = average + w * input2(r, s);
            end
        end
        average = average + input2(i1, j1);
        sweight = sweight + 1;
        output(i, j) = average / sweight;
    end
end
close(halt);
