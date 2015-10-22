WITH Simple_Io;
USE Simple_Io;

PACKAGE P_Creation IS

   PROCEDURE Creation_Fichier(Fichier:String);
   PROCEDURE Retour_Ligne(Fichier:File_Type;NbRetours:Integer:=1);

   PRIVATE

   FUNCTION Longueur_Mot(Mot:String) RETURN Integer;
   PROCEDURE Ligne_Condition(Fichier:String);
   PROCEDURE Ligne_Fcondition(Fichier:String);
   PROCEDURE Ligne_Fpour(Fichier:String);
   PROCEDURE Ligne_Boucle(Fichier:String);
   PROCEDURE Ligne_Affectation(Fichier:String);
   PROCEDURE Ligne_DeclarationVariable(Fichier:String);
   PROCEDURE Ligne_DeclarationType(Fichier:String);
   PROCEDURE Ligne_DebutDeclaration(Fichier:String);
   PROCEDURE Ligne_DebutCode(Fichier:String);
   PROCEDURE Ligne_Lire(Fichier:String);
   PROCEDURE Ligne_Pour(Fichier:String);
   PROCEDURE Ligne_Ecrire(Fichier:String);
   PROCEDURE Ligne_FtantQue(Fichier:String);
   PROCEDURE Ligne_TantQue(Fichier:String);
   PROCEDURE Ligne_Frepeter(Fichier:String);
   PROCEDURE Ligne_Repeter(Fichier:String);

   --Fonctions ou procédure pour les verifications internes.
   FUNCTION Variable_Existe(ChaineVar:String) RETURN Boolean;
   FUNCTION Type_Interdit(ChaineType:String) RETURN Boolean;
   PROCEDURE Initialisation_Types_Interdits;
   FUNCTION Type_Existe(ChaineType:String) RETURN Boolean;
   PROCEDURE Initialisation_Variables_Creees;
   FUNCTION Mauvais_Caracteres(Chaine:String; TypeCaracteres:Integer:=2) RETURN Boolean;
   PROCEDURE Initialisation_Types_Crees;

END P_Creation;
