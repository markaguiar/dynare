function [proba, dproba] = stab_map_1(lpmat, ibehaviour, inonbehaviour, aname, iplot, ipar, dirname)
%function [proba, dproba] = stab_map_1(lpmat, ibehaviour, inonbehaviour, aname, iplot, ipar, dirname)
%
% lpmat =  Monte Carlo matrix
% ibehaviour = index of behavioural runs
% inonbehaviour = index of non-behavioural runs
% aname = label of the analysis
% iplot = 1 plot cumulative distributions (default)
% iplot = 0 no plots
% ipar = index array of parameters to plot
% dirname = (OPTIONAL) path of the directory where to save 
%            (default: current directory)
%
% Plots: dotted lines for BEHAVIOURAL
%        solid lines for NON BEHAVIOURAL
% USES smirnov

global estim_params_ bayestopt_ M_ options_

if nargin<5,
  iplot=1;
end
fname_ = M_.fname;
if nargin<7,
  dirname='';;
end

nshock = estim_params_.nvx;
nshock = nshock + estim_params_.nvn;
nshock = nshock + estim_params_.ncx;
nshock = nshock + estim_params_.ncn;

npar=size(lpmat,2);
ishock= npar>estim_params_.np;

if nargin<6 | isempty(ipar),
  ipar=[1:npar];
end
nparplot=length(ipar);

% Smirnov test for Blanchard; 
for j=1:npar,
  [H,P,KSSTAT] = smirnov(lpmat(ibehaviour,j),lpmat(inonbehaviour,j));
  proba(j)=P;
  dproba(j)=KSSTAT;
end
if iplot
  lpmat=lpmat(:,ipar);
  ftit=bayestopt_.name(ipar+nshock*(1-ishock));
  
for i=1:ceil(nparplot/12),
  figure('name',aname),
  for j=1+12*(i-1):min(nparplot,12*i),
    subplot(3,4,j-12*(i-1))
    if ~isempty(ibehaviour),
      h=cumplot(lpmat(ibehaviour,j));
      set(h,'color',[0 0 0], 'linestyle',':')
    end
    hold on,
    if ~isempty(inonbehaviour),
      h=cumplot(lpmat(inonbehaviour,j));
      set(h,'color',[0 0 0])
    end
    title([ftit{j},'. D-stat ', num2str(dproba(ipar(j)),2)],'interpreter','none')
  end
  saveas(gcf,[dirname,'\',fname_,'_',aname,'_SA_',int2str(i)])
  eval(['print -depsc2 ' dirname '\' fname_ '_' aname '_SA_' int2str(i)]);
  eval(['print -dpdf ' dirname '\' fname_ '_' aname '_SA_' int2str(i)]);
  if options_.nograph, close(gcf), end
end
end
