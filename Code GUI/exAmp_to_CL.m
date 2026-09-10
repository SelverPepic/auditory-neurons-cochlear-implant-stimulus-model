function [ CL ] = exAmp_to_CL( exAmp )
%%  exAmp_to_CL converts a extracellular stimulation pulse from uA to CL.
% Adapted from Max Hess 2017 semester project
CL = 255.*(log10(exAmp./17.5))/2;
