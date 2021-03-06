% Feature extractor
%--------------------------------------------------------------------------
ictspike = 1;   % Detects ictal spikes and their amplitude
gamcoupl = 1;   % Calculates zero-lag correlation in the high gamma band
imgfeatr = 1;   % Pulls image features

% Ictal spike frequency and amplitude
%--------------------------------------------------------------------------
if ictspike
clear spks ampl smspk smamp
for c = 1:16
rnge    = 1:size(fdat{1},2);  %500000:900000;

[z , mu, sig]   = zscore(fbdat{1}(c,:)); 
[pks loc]       = findpeaks(mu-fdat{1}(c,rnge));
loc             = loc(pks > 5 * sig); 
pks             = pks(pks > 5 * sig); 

srts  = fix([rnge(1)/Fs:0.1:rnge(end)/Fs] * Fs); 
for t = 1:length(srts)-1
    td      = fdat{1}(c,srts(t):srts(t+1)-1);
    spks(c,t) = length(intersect(find(loc >= srts(t)), find(loc < srts(t+1))));
    ampl(c,t) = max(td) - min(td); 
end

smamp(c,:) = smooth(ampl(c,:), 50); 
smspk(c,:) = smooth(spks(c,:), 50); 
end

subplot(2,1,1)
plot(smamp'); 
subplot(2,1,2)
plot(smspk'); 
end

% High gamma coupling - correlation
%--------------------------------------------------------------------------
if gamcoupl
srts  = fix([rnge(1)/Fs:0.1:rnge(end)/Fs] * Fs);
dummy = ones(size(fdat{1},1)); 
dummy = triu(dummy,1); 
upid  = find(dummy); 

cors = [];
for t = 1:length(srts)-1
    td          = fdat{2}(:,srts(t):srts(t+1)-1);
    cmat        = corr(td'); 
    cors(:,t)   = cmat(upid);
end

cors(cors < 0) = 0; 
for c = 1:size(cors,1)
    smcor(c,:) = smooth(cors(c,:), 50); 
end
end
%% Plot example summaries of the electrophysiology features
%--------------------------------------------------------------------------
plot(mean(smcor(:,3:end-2)) / max(mean(smcor(:,3:end-2)))), hold on
plot(mean(smamp(:,3:end-2)) / max(mean(smamp(:,3:end-2))) + 1), hold on
plot(mean(smspk(:,3:end-2)) / max(mean(smspk(:,3:end-2))) + 2), hold on

%% Wave front
%--------------------------------------------------------------------------
load([F.analysis fs 'Wave map' fs 'Binary.mat']);
load([F.analysis fs 'Wave map' fs 'Edge.mat']); 

%%
clear tfedg
for c = 1:length(C)
for s = 1:size(smamp,2)
    smedg       = imgaussfilt(real(squeeze(edgm(s,:,:))), 15);
    tfedg(c,s)  = smedg(C(c).x, C(c).y); 
end
end
% Calcium amplitude
%--------------------------------------------------------------------------





% %% High gamma power
% %--------------------------------------------------------------------------
% for c = 1:16
% rnge    = 1:size(fdat{1},2);
% srts    = [rnge(1)/Fs:0.1:rnge(end)/Fs] * Fs; 
% f       = 2; 
% clear hgpw
% for t = 1 %:length(srts)-1
%     ftd    = fft(fdat{2}(c,srts(t):srts(t+1)-1)); 
%     numsmp = length(ftd);
%     psd    = 2 .* abs(ftd) .^ 2 ./ (numsmp .^2);
%     spc    = psd(8:26);
% end
% 
% end

% for l = 1:size(loc,2)
%     plot([loc(l), loc(l)], [-pks(l)-30, -pks(l)-15], 'color', [.3 .3 .3], 'linewidth', 2); hold on
% end
% plot(fdat{1}(c,rnge))

% %%
% 
% h       = hilbert(fdat{3});
% phase   = unwrap(angle(h));
% 
% %%
% 
% % since the calculation of the hilbert transform requires integration over
% % infinite time; 10% of the calculated instantaneous values are discarded
% % on each side of every window
% % discard 10%
% perc10w =  floor(nit/10);
% phase1 = phase1(perc10w:end-perc10w);
% phase2 = phase2(perc10w:end-perc10w);