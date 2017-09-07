function [ data, true_states ] = load_toy_data( data_path )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

load(strcat(data_path,'/Toy/2D_toy_data.mat'))

data = Data;
true_states = True_states;

end

