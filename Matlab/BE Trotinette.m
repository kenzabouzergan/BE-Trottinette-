clear all
close all
%Partie 1: L'asservissement de couple
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
Ubat = 24;
%FT G: Moteur + Hacheur
FTg = tf(2*Ubat*numm,denm)
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
Kcap = 0.104; %Sensibilité du capteur
%FT cap +conditionnement
FTretour = tf(Kcap*numf,denf)
%Bode pour FTBO pas correcteur 
FTBO = FTg*FTretour
figure
bode(FTBO);
% Ajouter correcteur PI
numC = [Taum  1];
%On choisit le fréauence de transition = 350Hz
taui = ((24*Km*Kfiltre*Kcap)/(pi*350)); % cf l'équation dans le rapport
denC = [taui 0];
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
C_discret = c2d(C,Te,'tustin')
%Partie 2: L'asservissement de vitesse
numV = [3.3];
denV = [1 0];
V = tf(numV,denV)
figure 
bode(V)
numCv = [3.8553 1];
denCv = [0.543 0]; 
Cv = tf(numCv,denCv)
Cv_discret = c2d(Cv,Te,'tustin')

