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
FTg = tf(2*numm,denm)
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
FTf = tf(numm,denm)
%Capteur 
Kcap = 0.104 
%FT cap +cond 
FTboucle = tf(Kcap*numm,denm)
%%%%%%%bode pour FTBO pas correcteur 
FTBO = FTg*FTboucle
bode(FTBO);
%%%%%% Ajouter correcteur de proportionnelle
Kp = 3 
FTBOcp = Kp*FTBO;
bode(FTBFcp)




