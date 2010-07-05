function [acc,sig,cv] = test_procedure(myproc,nfolds,X,Y)
% test multivariate analysis procedure
%
% [acc,sig,cv] = test_procedure(myproc,nfolds,data,design)
%
%   Copyright (c) 2009, Marcel van Gerven


  if nargin == 1
    nfolds = 10;
  end

  if nargin < 4
    
    % load example data
    load covattfrq1
    
    chans = ft_channelselection({'MLO' 'MRO'},left.label);
    cvec = ismember(left.label,chans); % subset of channels
    %cvec = 1:length(left.label);
    fvec = (left.freq >= 8 & left.freq <= 14); % subset of frequencies
    tvec = (left.time >= 1.5 & left.time <= 2.5); % subset of time segment
    
    X  = [squeeze(mean(left.powspctrm(:,cvec,fvec,tvec),4)); squeeze(mean(right.powspctrm(:,cvec,fvec,tvec),4))];
    Y  = [ones(size(left.powspctrm,1),1); 2*ones(size(right.powspctrm,1),1)];
    
    if isa(myproc{end},'transfer_learner')
      
      load covattfrq2;
      
      cvec = ismember(left.label,ft_channelselection({'MLO' 'MRO'},left.label)); % subset of channels
      %cvec = 1:length(left.label);
      fvec = (left.freq >= 8 & left.freq <= 14); % subset of frequencies
      tvec = (left.time >= 1.5 & left.time <= 2.5); % subset of time segment
      
      X2  = [squeeze(mean(left.powspctrm(:,cvec,fvec,tvec),4)); squeeze(mean(right.powspctrm(:,cvec,fvec,tvec),4))];
      Y2  = [ones(size(left.powspctrm,1),1); 2*ones(size(right.powspctrm,1),1)];
      
      X = {X X2};
      Y = {Y Y2};
      
    end    
    
  end
  
  cv = crossvalidator('procedure',myproc,'nfolds',nfolds,'verbose','all','compact',false,'model',true);
  
  cv = cv.validate(X,Y);
  
  acc = cv.evaluate;
  sig = cv.significance;
  
  if 0
    scalp = left;
    scalp.powspctrm = scalp.powspctrm(1,:,fvec,1);
    %scalp.label = scalp.label(cvec);
    scalp.powspctrm(1,~cvec,:,:) = 0;
    scalp.powspctrm(1,cvec,:,:) =  reshape(cv.model{1},[1 sum(cvec) sum(fvec) 1]);
    scalp.freq = scalp.freq(fvec);
    scalp.time = mean(scalp.time(tvec));
    cfg.layout = 'CTF275.lay';
    topoplotTFR(cfg,scalp);
  end
  
end