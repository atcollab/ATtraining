close all;
clear all;

%load('/mntdirect/_machfs/ESRF_Russia_AT_Training/USSR4/lattice/EBS/S28C.mat')
 
atplot(ARCA)

atplot(ARCA,@plotB0curlyh);

% figure;
%[ARCB_INJ;ARCA_INJ]);
% 
% 
% figure;
% atplot([ARCB_INJ;ARCA_INJ;repmat(ARCA,30,1)]);


load('/mntdirect/_machfs/ESRF_Russia_AT_Training/projects/Booster/fullsy-nuv6nuh12.mat')

 atplot(THERING)
 
 
 p =atgeometry(THERING);
 
 plot([p.x],[p.y]);
 xlabel('x [m]');
 ylabel('y [m]');
 
 
 
  load('/mntdirect/_machfs/ESRF_Russia_AT_Training/USSR4/lattice/INJ_L26.3743m_NCell46_6GeV_DLDQ_tune_RF/HMBAINJ_L26.3743m_NCell46_6GeV_DLDQ_tune_RFL10p01_short_RF.mat')
atplot(ARCA)
