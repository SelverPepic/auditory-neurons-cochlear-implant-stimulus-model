% fit recovery function
load('test_recovery.mat')
ECAP = ECAP_amp2_avr;
tIPI = tIPI;
%fun = @(T0,tau,A) ((tIPI<=T0) .* 0 + (tIPI>T0) .* A.*(1-exp(-(tIPI-T0)./tau)) );
fun = @(T_rec,tau_rec,A_rec,tau_fac,A_fac) ( A_fac.*exp(-tIPI./tau_fac) + (tIPI<=T_rec) .* 0 + (tIPI>T_rec) .* A_rec.*(1-exp(-(tIPI-T_rec)./tau_rec)) );

%x0 = [0.25, 0.4, 0.9];
%x = lsqnonlin(fun,x0);
T_rec = 0.1:0.02:0.5;
tau_rec = 0.1:0.02:2;
A_rec = 0.8:0.02:1.2;
tau_fac = 0.01:0.02:0.4;
A_fac = 0.1:0.02:1.2;
%%
error = ones(length(T_rec),length(tau_rec),length(A_rec),length(tau_fac),length(A_fac));

for i=1:length(T_rec)
    for j = 1:length(tau_rec)
        for k = 1:length(A_rec)
            
            for l = 1:length(tau_fac)
                for m = 1:length(A_fac)
                    val = fun(T_rec(i),tau_rec(j),A_rec(k),tau_fac(l),A_fac(m))-ECAP;
                    error(i,j,k,l,m) = val*val';
                end
            end
            
        end
    end
end

%%
lin_index = find( error == min(min(min(min(min(error))))) );
[I,J,K,L,M] = ind2sub(size(error),lin_index(1));
err = min(min(min(min(min(error)))))
values = [T_rec(I), tau_rec(J), A_rec(K),tau_fac(L),A_fac(M)]

% compare
plot(tIPI,fun(T_rec(I),tau_rec(J),A_rec(K),tau_fac(L),A_fac(M)));
hold on;
plot(tIPI,ECAP,'o');