function [ exAmp ] = CL_to_exAmp( CL )
%%  CL_to_exAmp converts a stimulation pulse from CL to uA.
% Adapted from Max Hess 2017 semester project
exAmp = 17.5 * 100.^(CL./255);
