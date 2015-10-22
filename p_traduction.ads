WITH Simple_Io;
USE Simple_Io;

PACKAGE P_Traduction IS

	--Indique si un fichier existe ou non.
	FUNCTION Existence_Fichier(Fichier:String) RETURN Boolean;

	--Procédure principale de traduction d'un fichier
PROCEDURE Traduction_Fichier(FichierSource,FichierRes:String);
--Fin de boucle /Pour
      FUNCTION Verification_Fpour(Contenu:String) RETURN Boolean;
      --Fin de boucle Tant Que
      FUNCTION Verification_Ftq(Contenu:String) RETURN Boolean;

--Fin de boucle Repeter
FUNCTION Verification_Frepeter(Contenu:String;Negation:Boolean:=False) RETURN Boolean;


	--Condition Si et Si Non
	FUNCTION Verification_Si(Contenu:String;Negation:Boolean:=False) RETURN Boolean;
	--Sinon si
	FUNCTION Verification_Sinon_Si(Contenu:String) RETURN Boolean;
	--Fin de condition si
	FUNCTION Verification_Fsi(Contenu:String) RETURN Boolean;
	--Sinon
	FUNCTION Verification_Sinon(Contenu:String) RETURN Boolean;
	--Boucle Pour
	FUNCTION Verification_Pour(Contenu:String) RETURN Boolean;
	--Boucle Tant Que
      FUNCTION Verification_TantQue(Contenu:String; Negation:Boolean:=False) RETURN Boolean;
      --Boucle Repeter
      FUNCTION Verification_Repeter(Contenu:String) RETURN Boolean;

	PRIVATE

	--Fonctions de vérification

	--Vérifie quelle instruction
	FUNCTION Verification_Instruction(Contenu:String) RETURN Integer;

	--Déclaration de variable
	FUNCTION Verification_DeclarationVariable(Contenu:String) RETURN Boolean;

	--Affectation de variable
	FUNCTION Verification_Affectation(Contenu:String) RETURN Boolean;
	--Boucle Tant Que/Pour
	FUNCTION Verification_Fonction(Contenu:String) RETURN Boolean;
	FUNCTION Verification_DeclarationType(Contenu:String) RETURN Boolean;

	--Fonctions de traduction

	FUNCTION Traduction_Si(Contenu:String; Negation:Boolean:=False) RETURN String;
FUNCTION Traduction_TantQue(Contenu:String; Negation:Boolean:=False) RETURN String;
FUNCTION Traduction_Frepeter(Contenu:String; Negation:Boolean:=False) RETURN String;
	FUNCTION Traduction_Pour(Contenu:String) RETURN String;
FUNCTION Traduction_Fboucle RETURN String;
FUNCTION Traduction_Repeter RETURN String;
	FUNCTION Traduction_DeclarationVariable(Contenu:String) RETURN String;
	FUNCTION Traduction_Fsi RETURN String;
	FUNCTION Traduction_Sinon(Contenu:String) RETURN String;
	FUNCTION Traduction_Affectation(Contenu:String) RETURN String;
FUNCTION Traduction_Fonction(Contenu:String) RETURN String;
FUNCTION Traduction_DeclarationType(Contenu:String) RETURN String;
	FUNCTION Traduction_Sinon_Si(Contenu:String) RETURN String;

	--Fait un retour chariot dans un fichier
	PROCEDURE Retour_Ligne(Fichier:File_Type;NbRetours:Integer:=1);
	PROCEDURE Ajout_Indentation(Fichier:File_Type;NbIndent:Integer:=0);


END P_Traduction;


--SEB
--existence_fichier
--verification_répéter
--verification_frepeter
--verification_si
--verification_sinon_si
--verification_si
--verification_fsi

