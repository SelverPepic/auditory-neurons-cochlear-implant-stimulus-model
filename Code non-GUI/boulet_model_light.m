%%% Population Integrate & fire model
%%% Master thesis, Selver Pepic
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA
%%% Based on the model in J.Boulet PhD thesis
%%% v1 09.07.2018
%%% v2 26.09.2018
%%% v3 30.09.2018
%%% v4 02.10.2018
%%% v5 23.10.2018
%function spiketimes = boulet_model_main(A,dt);

% Script that calculates the neural response for parameters defined in
% boulet_parameters and stimulus defined in boulet_stimulation
    % INPUTS: boulet_parameters, boulet_stimulation
    % OUTPUTS:
        % v - voltage response
        % spiketimes
        
% Light version modifications:
    % vth and x_th/RS are not saved at each timestep
    % single precision instead of double precision variables are used
    

%% setup
% loads stimulation type
run boulet_stimulation
Istim = single(Istim);
% choose stimulation type and enable/disable spatial spread in the file

%% initial conditions
v = vrest * ones(niter,nneurons,'single');
vth = vth0 * ones(1,nneurons,'single');
x_th = ones(1,nneurons,'single'); % x = x_r * x_sra * (1+y_fac) * (1+y_acc);
    x_th_ref = ones(1,nneurons,'single');
    x_th_SRA = ones(1,nneurons,'single');
    y_th_fac = zeros(1,nneurons,'single');
    y_th_acc = zeros(1,nneurons,'single');
    y_th_acc_slow = zeros(1,nneurons,'single');
    z = zeros(1,nneurons,'single'); % time shifted stimulus, used for fac and acc
x_RS = ones(1,nneurons,'single'); % x = x_r * x_sra * (1+y_fac) * (1+y_acc);
    x_RS_ref = ones(1,nneurons,'single');
    x_RS_SRA = ones(1,nneurons,'single');
    y_RS_fac = zeros(1,nneurons,'single');
    y_RS_acc = zeros(1,nneurons,'single');
    y_RS_acc_slow = zeros(1,nneurons,'single');

spiketimes = cell(1,nneurons); % array of spike times
spikelast = -10*tmax * ones(1,nneurons,'single');
% sets the time of last spike "long time ago" - prevents errors in code later
firing = zeros(1,nneurons,'single');
tRRP = zeros(1,nneurons,'single');

%% loop
tic
for i = 1:niter-1
    
        % check simulation progress
        step = round(niter/10);
        if (i-1)/step == round((i-1)/step)
            disp(strcat(num2str((i-1)/step*10),'% done'))
        end
        
    % linear RC membrane model
    % Euler forward
    v(i+1,:) = v(i,:) + 1/C .* (Istim(i,:)-(v(i,:)-vrest)./R).*dt; 
        % midpoint
    %v(i+1,:) = v(i,:) + 1/(1+0.5*dt/R/C)* 1/C .* ( 0.5*(Istim(i,:)+Istim(i+1,:))-(v(i,:)-vrest)./R ).*dt;
    % RK4
        %k1 = dt .* (Istim(i,:)-(v(i,:)-vrest)./R)/C;
        %v2 = v(i,:) + dt*k1/2;
        %k2 = dt .* (0.5*(Istim(i,:)+Istim(i+1,:)) - (v2-vrest)./R)/C;
        %v3 = v(i,:) + dt.*k2/2;
        %k3 = dt .* (0.5*(Istim(i,:)+Istim(i+1,:)) - (v3-vrest)./R)/C;
        %v4 = v(i,:) + dt.*k3;
        %k4 = dt .* (Istim(i+1,:)-(v4-vrest)./R)/C;
        %v(i+1,:) = v(i,:) + (k1+2.*k2+2.*k3+k4)./6;
    
    % update threshold x function
    x_th = x_th_ref .* x_th_SRA ... 
       .* (1+y_th_fac) .* (1+y_th_acc) .* (1+y_th_acc_slow);
    vth = vth0 .* x_th;
        
    % update noise x function
    % x_sigma_ref = x_RS_ref * x_th_ref;
    % x_sigma_SRA = x_RS_SRA * x_th_SRA;
    % x_sigma_fac = x_RS_fac * x_th_fac;
    % x_sigma_acc = x_RS_acc * x_th_acc;
    % x_sigma_acc_slow = x_RS_acc_slow * x_th_acc_slow;
    % x sigma = x_sigma_ref * x_sigma_fac ...
    % x_sigma = x_RS * x_th;
    
    if noise_mem
        x_RS = x_RS_ref .* x_RS_SRA ... 
           .* (1+y_RS_fac) .* (1+y_RS_acc) .* (1+y_RS_acc_slow);
        vth = vth + vth_sigma(i,:) .* x_RS .* x_th;
    end
    
    %%% BEGIN of nonlinear effects (spike, ref, SRA, fac, acc)
    % spike and reset
    firing = zeros(1,nneurons,'single');
    firing(v(i,:)>vth) = 1; % if v>vth, mark neuron as firing
    spikelast(firing==1) = t(i);
    for k=find(firing) % find = indices equal to one (of neurons firing)
        spiketimes{k} = [spiketimes{k}, t(i)];
    end
    v(i,firing==1) = vspike;
    v(i+1,firing==1) = vreset;
    
    % REF recovery function
    if ref
        tRRP = t(i) - spikelast - T_ARP; % neuron in RRP or ARP?
        x_th_ref(tRRP<=0) = Inf;
        x_th_ref(tRRP>0) = 1./( 1-exp(-tRRP(tRRP>0)./tau_RRP(tRRP>0)) );
        if noise_ref
            x_RS_ref(tRRP>0) = 1 + a_RS_ref * exp(-tRRP(tRRP>0)./tau_RRP(tRRP>0));
        end
    end

    % SRA
    if SRA
        % firing neurons, "jump"
        x_th_SRA(firing==1) = x_th_SRA(firing==1) + p_th_SRA;
        if noise_SRA
            x_RS_SRA(firing==1) = x_RS_SRA(firing==1) + p_th_SRA;     
        end
        
        % all neurons, exp decrease towards 1
        x_th_SRA = x_th_SRA + (1 - x_th_SRA) .* dt/tau_SRA;
        if noise_SRA
            x_RS_SRA = x_RS_SRA + (1 - x_RS_SRA) .* dt/tau_SRA;                
        end                
    end
    
    % FAC + ACC
    if fac || acc || acc_slow
        % shifted and scaled stimulus response voltage z(i)
        % to avoid negative indices, starts after t=t_pulse_width has elapsed
        % pulse width w defined in boulet_stimulation
        if (i>w)
            z = (v(i-w,:)-vrest) ./ (vth0-vrest);
            % z=0 by default, z=1 if v = vth0
            % cut off negative values?
            %z(z<0) = 0;
        end
            
        % reset during ARP
        if ref
            y_th_fac(tRRP<0) = 0;
            y_RS_fac(tRRP<0) = 0;
            y_th_acc(tRRP<0) = 0;
            y_RS_acc(tRRP<0) = 0;
            y_th_acc_slow(tRRP<0) = 0;
            y_RS_acc_slow(tRRP<0) = 0;            
        end
            
        % reset FAC at the end of stimulus pulse - prevents accumulation over
        % more than 2 pulses
        y_th_fac(Istim(i,:)~=0 & Istim(i+1,:)==0) = 0;
        y_RS_fac(Istim(i,:)~=0 & Istim(i+1,:)==0) = 0;
        
        % update FAC
        if fac
            y_th_fac = y_th_fac .* (1-dt/tau_th_fac) + dt * a_th_fac .* z;
            if noise_fac
                y_RS_fac = y_RS_fac .* (1-dt/tau_RS_fac) + dt * a_RS_fac .* z;
            end
        end
        
        % update ACC
        if acc
            y_th_acc = y_th_acc .* (1-dt/tau_th_acc) + dt * a_th_acc .* z;
            if noise_acc
                y_RS_acc = y_RS_acc .* (1-dt/tau_RS_acc) + dt * a_RS_acc .* z;
            end
        end
        
        % update ACC_slow
        if acc_slow
            y_th_acc_slow = y_th_acc_slow .* (1-dt/tau_th_acc_slow) + dt * a_th_acc_slow .* z;
            if noise_acc_slow
                y_RS_acc_slow = y_RS_acc_slow .* (1-dt/tau_RS_acc_slow) + dt * a_RS_acc_slow .* z;
            end
        end
        
    end % end fac+acc
    %%% END of nonlinear effects
    
end % end time loop
toc

%% plot results
v = v(1:niter,:); % trimming away any additional time entries

figure(1)
    subplot(2,1,2);
    hold on;
    plot(t,Istim(:,1),'-blue')%-1.2*A
    plot(t,50*ones(size(t)),'-.blue')%-1.2*A
    axis([0 tmax 0 1.2*max(Istim(:,1))]);
    title('I_{stim} vs. time')
    xlabel('t (ms)');
    ylabel('I_{stim} (pA)');
    
    subplot(2,1,1);
    plot(t,sum(v,2)./nneurons,'-black');
    hold on;
    %plot(t,sum(vth,2)./nneurons,'-red');
    axis([0 tmax -20 100]);
    title('V_{mem avr} and V_{th avr} vs. time')
    xlabel('t (ms)');
    ylabel('V_{mem avr}, V_{th avr}(mV)');
    
%% spike histogram
figure(2)
    title('Spike histogram (all neurons)')
    xlabel('t (ms)');
    ylabel('num. of spikes');
    h1 = histogram(cell2mat(spiketimes),tmax,'BinLimits',[0 tmax]);
    %h1.Normalization = 'countdensity';
    %num2str(length(cell2mat(spiketimes)))  % total number of spikes  
    
    %h2 = histogram(cell2mat(spiketimes),tmax,'BinLimits',[0 tmax]);
    %h2_bin_count = h2.Values * 1000/nneurons;
    %plot(h2_bin_count,'-black*');
    
    hold on;
    edges = [0 2 6 12 20 30 40 50 tmax];
    st = cell2mat(spiketimes);
    clear bin;
    for i=1:length(edges)-1
        spikes_in_bin = length(st(st>=edges(i) & st<edges(i+1)));
        bin_count(i) = spikes_in_bin/(edges(i+1)-edges(i)); %* 1000/nneurons;
        bin_time(i) = 0.5*(edges(i)+edges(i+1));
    end
    plot(bin_time, bin_count,'-r*');
    title({['Firing rate vs. time'],...
        ['nneurons: ',num2str(nneurons), ', A: ', num2str(A), ', IPI: ', num2str(tIPI)]});
    xlabel('t (ms)');
    ylabel('Firing rate (1/s)');
    
    %filename = strcat('boulet_pulsetrain','SRA',num2str(SRA),'ACC',num2str(acc),'.mat');
    %save(filename,'bin_time','spiketimes','Istim','dt');
    %filename = strcat('boulet_pulsetrain','IPI',num2str(tIPI),'.mat');
    %save(filename,'bin_count','bin_time','spiketimes','Istim','tIPI','A','dt');
% inter-spike interval (ISI), first differences only
    % loop through each neuron
    % loop from each spike, subtract time from all other spikes
%figure(3)
    ISI = 0;
    sp_count = 0;
    
    for k=1:nneurons
        for s = 1:length(spiketimes{k})-1
            sp_count = sp_count +1;
            ISI(sp_count,1) = spiketimes{k}(s+1)-spiketimes{k}(s);            
        end
    end
    %h2 = histogram(ISI,100,'BinLimits',[0 tIPI*20]);
    %title('ISI (first differences only)')
    %xlabel('t (ms)');
    %ylabel('ISI count');