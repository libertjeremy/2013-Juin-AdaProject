PACKAGE P_Edition IS

   PROCEDURE Edition_Fichier(Fichier:String);
   PROCEDURE Edition_Ordonnancement(Fichier:String);
   PROCEDURE Afficher_Algo(Fichier:String);
   PROCEDURE Edition_Ligne(Fichier:String);
   PROCEDURE Initialisation_Tab_Lignes;
   FUNCTION Longueur_Ligne(Ligne:String) RETURN Integer;
   PROCEDURE Vider_Ligne_Tab (NumeroLigne:Integer);
   FUNCTION Vider_Ligne RETURN String;

END P_Edition;