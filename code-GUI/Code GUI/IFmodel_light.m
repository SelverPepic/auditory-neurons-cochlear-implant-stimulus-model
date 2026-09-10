%%% Population Integrate & fire model
%%% Master thesis, Selver Pepic
%%% ETH Zurich, UniSpital Zurich, ORL-Klinik, LEA
%%% Based on the model in J.Boulet PhD thesis
%%% v1 09.07.2018
%%% v2 26.09.2018
%%% v3 30.09.2018
%%% v4 02.10.2018
%%% v5 23.10.2018
%%% v6 13.11.2018

function [v,spiketimes] = IFmodel_light(p,s,modeltype)
% Function used in GUI that calculates the neural response for given
% parameters and modeltype.

% INPUTS:
    % handles.parameters - neuronal and simulation parameters
    % handles. stimulation - stimulus parameters and stimulus waveform

% OUTPUTS:
        % v - voltage response (for each neuron)
        % spiketimes (for each neuron)
        
% Light version modification: 
    % vth and x_th/RS are not saved at each timestep
    % single precision instead of double precision variables are used

            
%% initial conditions
v = p.vrest * ones(p.niter,p.nneurons,'single');
vth = p.vth0_stoch; % * ones(1,p.nneurons,'single');
x_th = ones(1,p.nneurons,'single'); % x = x_r * x_sra * (1+y_fac) * (1+y_acc);
    x_th_ref = ones(1,p.nneurons,'single');
    x_th_SRA = ones(1,p.nneurons,'single');
    y_th_fac = zeros(1,p.nneurons,'single');
    y_th_acc = zeros(1,p.nneurons,'single');
    y_th_acc_slow = zeros(1,p.nneurons,'single');
    z = zeros(p.niter,p.nneurons,'single'); % time shifted stimulus, used for fac and acc
x_RS = ones(1,p.nneurons,'single'); % x = x_r * x_sra * (1+y_fac) * (1+y_acc);
    x_RS_ref = ones(1,p.nneurons,'single');
    x_RS_SRA = ones(1,p.nneurons,'single');
    y_RS_fac = zeros(1,p.nneurons,'single');
    y_RS_acc = zeros(1,p.nneurons,'single');
    y_RS_acc_slow = zeros(1,p.nneurons,'single');

spiketimes = cell(1,p.nneurons); % array of spike times
spikelast = -100 * ones(1,p.nneurons,'single');
% sets the time of last spike "long time ago" - prevents errors in code later
%firing = zeros(1,p.nneurons);
%tRRP = zeros(1,p.nneurons),'single';

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
    % Euler forward
    v(i+1,:) = v(i,:) + 1/p.C .* (s.Istim(i,:) -(v(i,:)-p.vrest)./p.R).*p.dt;
    % midpoint method
    % v(i+1,:) = v(i,:) + 1/(1+0.5*dt/R/C)* 1/C .* ( 0.5*(Istim(i,:)+Istim(i+1,:))-(v(i,:)-vrest)./R ).*dt;
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
    vth = p.vth0_stoch .* x_th;
        
    % update noise x function
    if modeltype.noise_mem
        x_RS = x_RS_ref .* x_RS_SRA ... 
           .* (1+y_RS_fac) .* (1+y_RS_acc) .* (1+y_RS_acc_slow);
        vth = vth + x_RS .* x_th .*p.vth_sigma(i,:) ;
    end
    
    
    %%% BEGIN of nonlinear effects (spike, ref, SRA, fac, acc)
    % spike and reset
    firing = zeros(1,p.nneurons,'single');
    firing(v(i,:)>vth) = 1; % if v>vth, mark neuron as firing
    spikelast(firing==1) = p.t(i);
    for k=find(firing) % find = indices equal to one (of neurons firing)
        spiketimes{k} = [spiketimes{k}, p.t(i)];
    end
    v(i,firing==1) = p.vspike;
    v(i+1,firing==1) = p.vreset;
    
    % REF recovery function
    if modeltype.ref
        tRRP = p.t(i) - spikelast - p.T_ARP; % neuron in RRP or ARP?
        x_th_ref(tRRP<=0) = Inf;
        x_th_ref(tRRP>0) = 1./( 1-exp(-tRRP(tRRP>0)./ p.tau_RRP(tRRP>0)) );
        if modeltype.noise_ref
            x_RS_ref(tRRP>0) = 1 + p.a_RS_ref * exp(-tRRP(tRRP>0)./ p.tau_RRP(tRRP>0));
        end
    end

    % SRA
    if modeltype.SRA
        % firing neurons, "jump"
        x_th_SRA(firing==1) = x_th_SRA(firing==1) + p.p_th_SRA;
        if modeltype.noise_SRA
            x_RS_SRA(firing==1) = x_RS_SRA(firing==1) + p.p_RS_SRA;     
        end
        
        % all neurons, exp decrease towards 1
        x_th_SRA = x_th_SRA + (1 - x_th_SRA) .* p.dt/p.tau_th_SRA;
        if modeltype.noise_SRA
            x_RS_SRA = x_RS_SRA + (1 - x_RS_SRA) .* p.dt/p.tau_RS_SRA;                
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
            y_th_fac(tRRP<0) = 0;
            y_RS_fac(tRRP<0) = 0;
            %y_th_acc(tRRP<0) = 0;
            %y_RS_acc(tRRP<0) = 0;
            %y_th_acc_slow(tRRP<0) = 0;
            %y_RS_acc_slow(tRRP<0) = 0;            
        end
            
        % reset FAC at the end of stimulus pulse - prevents accumulation over
        % more than 2 pulses
        y_th_fac(s.Istim(i,:)~=0 & s.Istim(i+1,:)==0) = 0;
        y_RS_fac(s.Istim(i,:)~=0 & s.Istim(i+1,:)==0) = 0;
        
        % update FAC
        if modeltype.fac
            y_th_fac = y_th_fac .* (1-p.dt/p.tau_th_fac) + p.dt * p.a_th_fac .* z(i,:);
            if modeltype.noise_fac
                y_RS_fac = y_RS_fac .* (1-p.dt/p.tau_RS_fac) + p.dt * p.a_RS_fac .* z(i,:);
            end
        end
        
        % update ACC
        if modeltype.acc
            y_th_acc = y_th_acc .* (1-p.dt/p.tau_th_acc) + p.dt * p.a_th_acc .* z(i,:);
            if modeltype.noise_acc
                y_RS_acc = y_RS_acc .* (1-p.dt/p.tau_RS_acc) + p.dt * p.a_RS_acc .* z(i,:);
            end
        end
        
        % update ACC_slow
        if modeltype.acc_slow
            y_th_acc_slow = y_th_acc_slow .* (1-p.dt/p.tau_th_acc_slow) + p.dt * p.a_th_acc_slow .* z(i,:);
            if modeltype.noise_acc_slow
                y_RS_acc_slow = y_RS_acc_slow .* (1-p.dt/p.tau_RS_acc_slow) + p.dt * p.a_RS_acc_slow .* z(i,:);
            end
        end
        
    end % end fac+acc
    %%% END of nonlinear effects
    
end % end time loop
toc

%% save data
% spiketimes
% v