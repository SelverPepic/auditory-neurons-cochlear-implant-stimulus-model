%%% Population Integrate & fire model
%%% Master thesis, Selver Pepic
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA
%%% Based on the model in J.Boulet PhD thesis
%%% v1 09.07.2018
%%% v2 26.09.2018
%%% v3 30.09.2018
%%% v4 02.10.2018
%%% v5 23.10.2018

function [v, vth, spiketimes, x] = IFmodel(p,s,modeltype)
% Function used in GUI that calculates the neural response for given
% parameters and modeltype.

% INPUTS:
    % handles.parameters - neuronal and simulation parameters
    % handles. stimulation - stimulus parameters and stimulus waveform

% OUTPUTS:
        % v - voltage response (for each neuron)
        % vth - membrane threshold over time (for each neuron)
        % spiketimes (for each neuron) 
        % x - threshold/noise modifiers due to ref/sra/fac/acc, at each
            % timestep and for all neurons

%% initial conditions
v = p.vrest * ones(p.niter,p.nneurons);
vth = repmat(p.vth0_stoch,p.niter,1); % * ones(p.niter,p.nneurons);
x_th = ones(p.niter,p.nneurons); % x = x_r * x_sra * (1+y_fac) * (1+y_acc);
    x_th_ref = ones(p.niter,p.nneurons);
    x_th_SRA = ones(p.niter,p.nneurons);
    y_th_fac = zeros(p.niter,p.nneurons);
    y_th_acc = zeros(p.niter,p.nneurons);
    y_th_acc_slow = zeros(p.niter,p.nneurons);
    z = zeros(p.niter,p.nneurons); % time shifted stimulus, used for fac and acc
x_RS = ones(p.niter,p.nneurons); % x = x_r * x_sra * (1+y_fac) * (1+y_acc);
    x_RS_ref = ones(p.niter,p.nneurons);
    x_RS_SRA = ones(p.niter,p.nneurons);
    y_RS_fac = zeros(p.niter,p.nneurons);
    y_RS_acc = zeros(p.niter,p.nneurons);
    y_RS_acc_slow = zeros(p.niter,p.nneurons);

spiketimes = cell(1,p.nneurons); % array of spike times
spikelast = -100 * ones(1,p.nneurons);
% sets the time of last spike "long time ago" - prevents errors in code later
firing = zeros(1,p.nneurons);
tRRP = zeros(1,p.nneurons);
vnoise = zeros(p.niter,p.nneurons);

%% loop
tic
for i = 1:p.niter-1
    
        % check simulation progress
        %if p.niter>10000
        %    step = p.niter/5;
        %    if i/step == round(i/step)
        %        disp(strcat(num2str(i/step*20),'% done'))
        %    end
        %end
    
    % linear RC membrane model
    v(i+1,:) = v(i,:) + 1/p.C .* (s.Istim(i,:)-(v(i,:)-p.vrest)./p.R).*p.dt;
    % midpoint method
    % v(i+1,:) = v(i,:) + 1/(1+0.5*dt/R/C)* 1/C .* ( 0.5*(Istim(i,:)+Istim(i+1,:))-(v(i,:)-vrest)./R ).*dt;
    
    % update threshold x function
    x_th(i,:) = x_th_ref(i,:) .* x_th_SRA(i,:) ... 
       .* (1+y_th_fac(i,:)) .* (1+y_th_acc(i,:)) .* (1+y_th_acc_slow(i,:));
    vth(i,:) = p.vth0_stoch .* x_th(i,:);
        
    % update noise x function
    if modeltype.noise_mem
        x_RS(i,:) = x_RS_ref(i,:) .* x_RS_SRA(i,:) ... 
           .* (1+y_RS_fac(i,:)) .* (1+y_RS_acc(i,:)) .* (1+y_RS_acc_slow(i,:));
        vth(i,:) = vth(i,:) + x_RS(i,:) .* x_th(i,:) .* p.vth_sigma(i,:) ;
        %vnoise(i,:) = p.vth_sigma(i,:) .* x_RS(i,:);
    end
    
    
    %%% BEGIN of nonlinear effects (spike, ref, SRA, fac, acc)
    % spike and reset
    firing = zeros(1,p.nneurons);
    firing(v(i,:)>vth(i,:)) = 1; % if v>vth, mark neuron as firing
    spikelast(firing==1) = p.t(i);
    for k=find(firing) % find = indices equal to one (of neurons firing)
        spiketimes{k} = [spiketimes{k}, p.t(i)];
    end
    v(i,firing==1) = p.vspike;
    v(i+1,firing==1) = p.vreset;
    
    % REF recovery function
    if modeltype.ref
        tRRP = p.t(i) - spikelast - p.T_ARP; % neuron in RRP or ARP?
        x_th_ref(i+1,tRRP<=0) = Inf;
        x_th_ref(i+1,tRRP>0) = 1./( 1-exp(-tRRP(tRRP>0)./ p.tau_RRP(tRRP>0)) );
        if modeltype.noise_ref
            x_RS_ref(i+1,tRRP>0) = 1 + p.a_RS_ref * exp(-tRRP(tRRP>0)./ p.tau_RRP(tRRP>0));
        end
    end

    % SRA
    if modeltype.SRA
        % firing neurons, "jump"
        x_th_SRA(i,firing==1) = x_th_SRA(i,firing==1) + p.p_th_SRA;
        if modeltype.noise_SRA
            x_RS_SRA(i,firing==1) = x_RS_SRA(i,firing==1) + p.p_RS_SRA;     
        end
        
        % all neurons, exp decrease towards 1
        x_th_SRA(i+1,:) = x_th_SRA(i,:) + (1 - x_th_SRA(i,:)) .* p.dt/p.tau_th_SRA;
        if modeltype.noise_SRA
            x_RS_SRA(i+1,:) = x_RS_SRA(i,:) + (1 - x_RS_SRA(i,:)) .* p.dt/p.tau_RS_SRA;                
        end
    end
    
    % FAC + ACC
    if modeltype.fac || modeltype.acc || modeltype.acc_slow
        % shifted and scaled stimulus response voltage z(i)
        % to avoid negative indices, starts after t=t_pulse_width has elapsed
        % pulse width w defined in boulet_stimulation
        if (i>s.w)
            z(i,:) = (v(i-s.w,:)-p.vrest)./(p.vth0_stoch-p.vrest);
            % z=0 by default, z=1 if v = vth0
            % cut off negative values?
            % z(z<0) = 0;
        end
            
        % reset during ARP
        if modeltype.ref
            y_th_fac(i,tRRP<0) = 0;
            y_RS_fac(i,tRRP<0) = 0;
            %y_th_acc(i,tRRP<0) = 0;
            %y_RS_acc(i,tRRP<0) = 0;
            %y_th_acc_slow(i,tRRP<0) = 0;
            %y_RS_acc_slow(i,tRRP<0) = 0;            
        end
            
        % reset FAC at the end of stimulus pulse - prevents accumulation over
        % more than 2 pulses
        y_th_fac(i,s.Istim(i,:)~=0 & s.Istim(i+1,:)==0) = 0;
        y_RS_fac(i,s.Istim(i,:)~=0 & s.Istim(i+1,:)==0) = 0;
        
        % update FAC
        if modeltype.fac
            y_th_fac(i+1,:) = y_th_fac(i,:) .* (1-p.dt/p.tau_th_fac) + p.dt * p.a_th_fac .* z(i,:);
            if modeltype.noise_fac
                y_RS_fac(i+1,:) = y_RS_fac(i,:) .* (1-p.dt/p.tau_RS_fac) + p.dt * p.a_RS_fac .* z(i,:);
            end
        end
        
        % update ACC
        if modeltype.acc
            y_th_acc(i+1,:) = y_th_acc(i,:) .* (1-p.dt/p.tau_th_acc) + p.dt * p.a_th_acc .* z(i,:);
            if modeltype.noise_acc
                y_RS_acc(i+1,:) = y_RS_acc(i,:) .* (1-p.dt/p.tau_RS_acc) + p.dt * p.a_RS_acc .* z(i,:);
            end
        end
        
        % update ACC_slow
        if modeltype.acc_slow
            y_th_acc_slow(i+1,:) = y_th_acc_slow(i,:) .* (1-p.dt/p.tau_th_acc_slow) + p.dt * p.a_th_acc_slow .* z(i,:);
            if modeltype.noise_acc_slow
                y_RS_acc_slow(i+1,:) = y_RS_acc_slow(i,:) .* (1-p.dt/p.tau_RS_acc_slow) + p.dt * p.a_RS_acc_slow .* z(i,:);
            end
        end
        
    end % end fac+acc
    %%% END of nonlinear effects
    
end % end time loop
toc

%% save data
% v
% vth
% spiketimes

x.th = x_th;
x.th_ref = x_th_ref;
x.th_SRA = x_th_SRA;
x.th_fac = 1 + y_th_fac;
x.th_acc = 1 + y_th_acc;
x.th_acc_slow = 1 + y_th_acc_slow;

x.RS = x_RS;
x.RS_ref = x_RS_ref;
x.RS_SRA = x_RS_SRA;
x.RS_fac = 1 + y_RS_fac;
x.RS_acc = 1 + y_RS_acc;
x.RS_acc_slow = 1 + y_RS_acc_slow;