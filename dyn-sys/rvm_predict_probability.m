function [p] = rvm_predict_probability(X,  model) 

% Parse model params
weights = model.weights;
kernel_ = model.kernel_;
width   = model.width;
bias    = model.bias;
RVs     = model.RVs;

% Evaluate RVM
PHI		= SB1_KernelFunction(X,RVs,kernel_,width);
y       = PHI*weights + bias;

% apply sigmoid for probabilities (option)
p	    = 1./(1+exp(-y));

end