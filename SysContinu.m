clear all
close all
%Definition des valeurs
%Moteur 
Rm = 1;
Lm = 2*10^(-3);
Taum = Lm/Rm;
Km = 1/Rm;
%FT de moteur 
numm = [Km];
denm = [Taum  1];
FTm = tf(numm,denm)
%Hacheur 
%FT = 2Ubat 
Ubat = 24;
%FT G
FTg = tf(2*Ubat*numm,denm)
figure
bode(FTg)
%Bloc conditonnement 
R5 = 5100;
R8 = 10000;
R18 = 12000;
R12 = 10000;
R21 = 220;
C2 = 22*10^(-9);
C7 = 22*10^(-9);
Req = (R8*R5)/(R8+R5);
Kfiltre = (R8/(R5+R8))*(1+(R18/R12));
tau1 = Req * C2;
tau2 = R21 * C7;
%FT F
numf = [Kfiltre];
denf = [tau1*tau2 tau1+tau2 1];
FTf = tf(numf,denf)
%Capteur 
Kcap = 0.104 
%FT cap +cond 
FTretour = tf(Kcap*numf,denf)
%%%%%%%bode pour FTBO pas correcteur 
FTBO = FTg*FTretour
figure
bode(FTBO);
%%%%%% Ajouter correcteur PI
Kp = 3;
numC = Kp*[Taum  1]
denC = [9.92e-3 0]
C =  tf(numC,denC)
FTBOc = C*FTBO;
figure
bode(FTBOc)
%Simulation en continu
Te = 2e-4;
out = sim('sim_SysContinu')
figure
plot(out.resBF)
%Asservissement dans le domaine discret
C_discret = c2d(C,Te)





