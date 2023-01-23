
/*
	!!!! NB : ALIMENTER LA CARTE AVANT DE CONNECTER L'USB !!!

VERSION 16/12/2021 :
- ToolboxNRJ V4
- Driver version 2021b (synchronisation de la mise à jour Rcy -CCR- avec la rampe)
- Validé Décembre 2021

*/


/*
STRUCTURE DES FICHIERS

COUCHE APPLI = Main_User.c : 
programme principal à modifier. Par défaut hacheur sur entrée +/-10V, sortie 1 PWM
Attention, sur la trottinette réelle, l'entrée se fait sur 3V3.
Attention, l'entrée se fait avec la poignée d'accélération qui va de 0.6V à 2.7V !

COUCHE SERVICE = Toolbox_NRJ_V4.c
Middleware qui configure tous les périphériques nécessaires, avec API "friendly"

COUCHE DRIVER =
clock.c : contient la fonction Clock_Configure() qui prépare le STM32. Lancée automatiquement à l'init IO
lib : bibliothèque qui gère les périphériques du STM : Drivers_STM32F103_107_Jan_2015_b
*/



#include "ToolBox_NRJ_v4.h"




//=================================================================================================================
// 					USER DEFINE
//=================================================================================================================
#define Te 0.0002
#define Km 1
#define Taum 0.002
#define Ft 350
#define R 1
#define L 0.002
#define Kfiltre 1.4570
#define Si 0.1040
#define pi 3.147
#define taui ((24*Km*Kfiltre*Si)/(pi*Ft))
#define a0 1.0

// Choix de la fréquence PWM (en kHz)
#define FPWM_Khz 20.0
						


//==========END USER DEFINE========================================================================================

// ========= Variable globales indispensables et déclarations fct d'IT ============================================

void IT_Principale(void);
//=================================================================================================================


/*=================================================================================================================
 					FONCTION MAIN : 
					NB : On veillera à allumer les diodes au niveau des E/S utilisée par le progamme. 
					
					EXEMPLE: Ce progamme permet de générer une PWM (Voie 1) à 20kHz dont le rapport cyclique se règle
					par le potentiomètre de "l'entrée Analogique +/-10V"
					Placer le cavalier sur la position "Pot."
					La mise à jour du rapport cyclique se fait à la fréquence 1kHz.

//=================================================================================================================*/

//Def des params
float Te_us;
int Courant_1, IN1, IN3V3;
float erreur, alpha , erreur1 = 0  , alpha1 = 0, sortie, b0, b1;

int main (void)
{
//Calcul les params du correcteur

b0 = (Te - 2*Taum)/(2*taui);
b1 = (Te + 2*Taum)/(2*taui);

  
// !OBLIGATOIRE! //	
Conf_Generale_IO_Carte();	
	

	
// ------------- Discret, choix de Te -------------------	
Te_us=Te*1000000.0; // conversion en µs pour utilisation dans la fonction d'init d'interruption
	

//______________ Ecrire ici toutes les CONFIGURATIONS des périphériques ________________________________	
// Paramétrage ADC pour entrée analogique
Conf_ADC();

// Configuration de la PWM avec une porteuse Triangle, voie 1 & 2 activée, inversion voie 2
Triangle (20);
Active_Voie_PWM(1);	
Active_Voie_PWM(2);	
Inv_Voie(2);

Start_PWM;
R_Cyc_1(2048);  // positionnement à 50% par défaut de la PWM
R_Cyc_2(2048);

// Activation LED
LED_Courant_On;
LED_PWM_On;
LED_PWM_Aux_Off;
LED_Entree_10V_On;
LED_Entree_3V3_Off;
LED_Codeur_Off;

// Conf IT


 Conf_IT_Principale_Systick(IT_Principale, Te_us);

	while(1)
	{}

}

//=================================================================================================================
// 					FONCTION D'INTERRUPTION PRINCIPALE SYSTICK
//=================================================================================================================
void IT_Principale(void)
{
 erreur = (float)( Entree_3V3() - I1());
// Convert en Volt
 erreur = erreur/4096*3.3;
//Fonction recurrence
 alpha = b1*erreur + b0*erreur1 + alpha1; 
//Saturation
if (alpha > 0.5)
{
alpha = 0.5;
} else if (alpha < -0.5)
{
alpha = -0.5;
}
 alpha1 = alpha;
 erreur1 = erreur;
//
 sortie = (alpha)*4096.0;
 R_Cyc_1((int)sortie+2048);
 R_Cyc_2((int)sortie+2048);
}

