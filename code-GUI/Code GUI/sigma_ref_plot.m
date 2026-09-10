load('sigma_ref_0.mat')
ECAP_0 = ECAP_amp;
load('sigma_ref_02.mat')
ECAP_02 = ECAP_amp;
load('sigma_ref_04.mat')
ECAP_04 = ECAP_amp;
load('sigma_ref_06.mat')
ECAP_06 = ECAP_amp;
load('sigma_ref_08.mat')
ECAP_08 = ECAP_amp;
load('sigma_ref_1.mat')
ECAP_1 = ECAP_amp;


%%
plot(ECAP_time,ECAP_0);
hold on;
%plot(ECAP_time,ECAP_02);
plot(ECAP_time,ECAP_04);
%plot(ECAP_time,ECAP_06);
%plot(ECAP_time,ECAP_08);
plot(ECAP_time,ECAP_1);