% Graphene electrode code - runs analysis of Graphene electrode data
%==========================================================================
% This code contains analysis code to run the analysis on graphene, steps
% of this can be run by toggling on or off the following variables

% Getting EEG Datafeatures
%--------------------------------------------------------------------------
pullieeg = 0;       % Downloads EEG data from IEEG portal
physfeat = 0;       % Estaimates 

% Getting Calcium Imaging Datafeatures
%--------------------------------------------------------------------------
estwave = 0;
getfeat = 0;

% Run NMF
%--------------------------------------------------------------------------
runnmf  = 0;

% Plotting functions
%--------------------------------------------------------------------------
% This can be toggled on or off further down
% 1) grp_plot_nmf - example weights and loadings for NMF calculated above
% 2) grp_plot_traj - plots state-space trajectories 
% 3) grp_plot_spike - plots binned ictal spike averages


% Housekeeping
%==========================================================================
fs          = filesep; 
F           = grp_housekeeping; 
Fs          = 5000;     % EEG sampling frequency

% Running actual analysis
%==========================================================================
% Get EEG Datafeatures
%--------------------------------------------------------------------------
if pullieeg,    C   = grp_electrophys(F);   end
if ~exist('C'), load([F.data fs 'Electrophysiology' fs 'Channel_Data.mat']); end
if physfeat,    [EPH, fcE] = grp_ephysfeat(C);     end

% Get Imaging Datafeatures
%--------------------------------------------------------------------------
if estwave,     F   = grp_imaging(F);       end
if getfeat,     IMG = grp_imgfeat(C, F);    end

% Matrix decomposition
%--------------------------------------------------------------------------
if runnmf 
    [W,H,FMT,fid,fset,trange,fastrange] = grp_nmf(EPH,IMG,fcE,Fs,whichk,6);     
end


% Plotting functions (use the if statements as toggles)
%==========================================================================
if 0,   grp_plot_nmf(W,H,C,trange,fastrange,fset,fid);          end
if 0,   grp_plot_traj(F,traneg,H,wsort);                        end
if 0,   grp_plot_spike(C, H, wsort, fastrange, Fs, 9);          end
if 0,   grp_plot_tsrs(C, IMG, trange, fastrange, Fs, dolong);   end
if 0,   grp_plot_edgemap(F, trange);                            end

% GRAVEYARD
% 
% alli = unique(id); 
% for i = 1:length(alli)
%     tid = find(id == alli(i)); 
%     Wg{i} = W(tid,:);
%     if (alli(i) == 8) || (alli(i) == 9),  cstr = 'r',     
%     else,                       cstr = 'k';     end
%     
%     plot(mean(Wg{i}), cstr), hold on
%     mW(i,:) = mean(Wg{i}); 
% end
% %%
% rng(45)
% Z = linkage(W, 'complete');
% T = cluster(Z,'maxclust',10);
% % dendrogram(Z)
% [std tsort] = sort(T);
% imagesc(corr(W(tsort,:)'));
% 
% % Percentage of channel features in each 
% caid = find(feattypes == 3);
% for c = 1:length(caid)
%     tcaid = find(fid == caid(c));
%     allts = unique(T);
%     for t = 1:length(allts)
%         rat(c,t) = length(find(fid(T == t) == caid(c))) / length(tcaid);
%     end
%     
% end
% 
% imagesc(W(tsort,:))
% set(gca, 'YTick', find([1; diff(sort(T))]))


% % Correlation weights 
% %--------------------------------------------------------------------------
% if strcmp(whichone, 'corrweights')
% dum     = ones(length(C)); dum = zeros(length(C)) + triu(dum,1); dum = find(dum); 
% ddum    = zeros(16);
% 
% Featid  = [6 7];    % 6: low freq corr; 7: high freq corr
% zcut    = 1;        % zscore cut off when looking across all weight loadings
% fnames  = {'LFP correlation', 'HFO correlation'}; 
% 
% for f = 1:length(Featid)
%     featid = Featid(f); 
%     allw 	= W(fid == featid,:);
%     allw(zscore(allw(:)) < zcut) = 0; 
%     for s = 1:wr
%         ddum(dum)   = allw(:, wsort(s)); 
%         A           = ddum + ddum';
% 
%         subplot(length(Featid)+2,wr,s+(wr*f))       
%             G           = graph(A);  
%             jx = randn(1,16)*0;
%             jy = randn(1,16)*0;
%             plot(G,'XData',[C.x]+jx,'YData',[C.y]+jy, 'LineWidth', G.Edges.Weight*30, ...
%                  'NodeLabel', [C.id], 'EdgeColor', lincols(wsort(s),:))
%             set(gca, 'YDir', 'Reverse');
%             axis square
%             title(['Factor ' num2str(wsort(s))])
%             ylabel(fset{f}); 
%     end
% end
% end