function err = ViscoErrFuncIncDist(a, data)
N = (size(a,2) - 1) / 2;
dataSize = size(data,1);
err = 0; n = 1 : N;
g0 = a(1,1); t = a(1,2:N+1); g = a(1,N+2:(2*N) + 1);
for j = 1:dataSize 
    %Calculates the Prony error for a given set of inputs.
     w = data(j,1); %g1 = data(j,2); g2 = data(j,3);
     rhs = 0; rhs2 = 0;
    lhs = g0 * (1 - sum(g(1,n)));
    for i = 1:N
        rhs = rhs + (g0 * (g(1,i)*(t(1,i)^2)*(w^2))/(1 + ((t(1,i)^2)*(w^2))));
    end
    err1 = (lhs + rhs);
    for i = 1:N
        rhs2 = rhs2 + (g0 * (g(1,i)*t(1,i)*w)/(1 + ((t(1,i)^2)*(w^2))));
    end
    err2 = rhs2;
    err = err + (((err1/data(j,2)) - 1)^2) + (((err2/data(j,3)) - 1)^2);
end
end