% Script to generate a plot of neurons firing vs. time

% data with two stimulus pulses with small IPI
%load('2018_11_8_14_2_20_data.mat') 
tspike = p.dt:p.dt:p.tmax;
neuronfired = zeros(p.niter,p.nneurons);

%%
figure

% plot 1
subplot(2,1,1)
axis([0 p.tmax 1 p.nneurons])
%c = [ [1 0 0];  [1 1 0]; [0 1 0]; [0 1 1]; [0 0 1]; [1 0 1]];
%c = colormap(colorcube);
c = [ [0 1 0]; [1 0 0]; [0 0 1];];
hold on;

for k = 1:p.nneurons    
    sp = spiketimes{k};
    for i=1:length(sp)
        neuronfired(round(sp(i)/p.dt),k) = ...
            neuronfired(round(sp(i)/p.dt),k) + 1;
        npulse = ceil((sp(i)-s.to)/s.tIPI);
        marker_col = c(mod(npulse,size(c,1))+1,:);
        plot(sp(i),k,'o','MarkerEdgeColor',marker_col,'MarkerFaceColor',marker_col);
    end
end

%subplot(2,1,2)
%axis([0 p.tmax 0 s.A])
%plot(p.t,s.mod*s.A);