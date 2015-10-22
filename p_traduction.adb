PACKAGE BODY P_Traduction IS

   --Un type tableau d'entier qui servira pour la suite.
   TYPE Tableau IS ARRAY(1..150) OF Integer;
   --Longueur maximale d'une ligne de code
   LongueurMaxLigne:CONSTANT Integer:=150;

   --Erreur indiquant que le fichier source n'existe pas
   Erreur_Fichier_Inexistant:EXCEPTION;

   --Variable indiquant le début d'une déclaration dans un fichier.
   ChaineDebutDeclaration:CONSTANT String(1..12):="-declaration";
   ChaineDebutCode:CONSTANT String(1..5):="-code";

   FichierType:File_Type;

   Indentation:CONSTANT String:="    ";--Espacement qui permettra de rendre lisible le code Ada

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------EXISTENCE_FICHIER-----------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Fonction qui vérifie l'existence d'un fichier
   FUNCTION Existence_Fichier(Fichier:String) RETURN Boolean IS

   BEGIN

      --On ouvre le fichier puis le referme.
      Open(FichierType, In_File, Fichier);
      Close(FichierType);

      --Tout s'est bien passé, on indique que le fichier existe.
      RETURN True;

   EXCEPTION

      --Si l'ouverture a echoué, une erreur sera renvoyé et donc le fichier sera consideré comme inexistant.
      WHEN OTHERS => RETURN False;

   END Existence_Fichier;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_FICHIER----------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Procédure générale qui permettra de traduire le fichier de base Txt, en un fichier Adb
   PROCEDURE Traduction_Fichier(FichierSource,FichierRes:String) IS

      ContenuLigne:String(1..LongueurMaxLigne):=(OTHERS=>' ');--Variable qui contiendra le contenu des lignes.
      FichierTypeRes,FichierTypeSource:File_Type;--Déclaration des variables de type Fichier.
      LongueurLigne:Integer;--Variable qui permettra d'indiquer la longueur d'une ligne.
      TypeInstructionLigne:Integer;--Contiendra le type d'instruction de la ligne.
      CompteurLigne:Integer:=1;--Compteur du numéro de ligne dans le fichier.
      DebutDeclar:Boolean:=False;--Variables qui définiront si le code ou la déclaration a commencé dans le fichier.
      CompteurIndent:Integer:=0;

   BEGIN

      --Si le fichier résultat n'existe pas, on le crée.
      IF NOT Existence_Fichier(FichierRes & ".adb") THEN

         Create(FichierTypeRes, Out_File, FichierRes & ".adb");

      --Sinon, on l'ouvre simplement.
      ELSE

         Open(FichierTypeRes, Out_File, FichierRes & ".adb");

      END IF;

      --On initialise le fichier Ada, en ajoutant les bibiotheques.
      Put(FichierTypeRes, "WITH Simple_IO; USE Simple_IO;");Retour_Ligne(FichierTypeRes);

      --On indique le début de la procédure du fichier Ada.
      Put(FichierTypeRes, "PROCEDURE " & FichierRes & " IS");Retour_Ligne(FichierTypeRes, 2);

      --On vérifie que le fichier source existe
      IF NOT Existence_Fichier(FichierSource & ".txt") THEN

         --Si le fichier n'existe pas, on retourne une erreur. Inutile d'en créer un, du fait qu'il sera vide.
         RAISE Erreur_Fichier_Inexistant;

      ELSE

         --Ouverture du fichier content l'algorithme en mode lecture.
         Open(FichierTypeSource, In_File, FichierSource & ".txt");

      END IF;

      --On boucle le fichier pour trouver le position du début de code, et ainsi trouver les déclarations qui se trouvent avant.
      WHILE ContenuLigne(ChaineDebutCode'RANGE) /= ChaineDebutCode(ChaineDebutCode'RANGE) AND NOT End_Of_FIle(FichierTypeSource) LOOP

         --On récupere une ligne du fichier
         Get_Line(FichierTypeSource, ContenuLigne, LongueurLigne);

         --Affectation du type d'instruction de la ligne.
         TypeInstructionLigne:=Verification_Instruction(ContenuLigne(1..LongueurLigne));

         --Condition permettant de dire quand la partie lexique/déclaration commence, si la ligne lue vaut "-declaration"
         IF ContenuLigne(ChaineDebutDeclaration'RANGE) = ChaineDebutDeclaration(ChaineDebutDeclaration'RANGE) THEN

            --La variable est donc mise à true.
            DebutDeclar:=True;

         END IF;

         --Si nous sommes dans la partie de déclaration, et qu'on ne lit pas la ligne de début de déclaration.
         IF DebutDeclar AND (ContenuLigne(ChaineDebutDeclaration'RANGE) /= ChaineDebutDeclaration(ChaineDebutDeclaration'RANGE)) AND (ContenuLigne(ChaineDebutCode'RANGE) /= ChaineDebutCode(ChaineDebutCode'RANGE)) THEN

            --On vérifie si la déclaration a une syntaxe valide.
            IF Verification_DeclarationVariable(ContenuLigne(1..LongueurLigne)) THEN

               --On insère la traduction de la declaration dans le fichier Ada.
               Ajout_Indentation(FichierTypeRes);
               Put(FichierTypeRes, Traduction_DeclarationVariable(ContenuLigne(1..LongueurLigne)));
               --On fait un retour chariot.
               Retour_Ligne(FichierTypeRes);
               --On indique à l'utilisateur que la ligne a été traduite.
               --put("Ligne" & Integer'Image(CompteurLigne) & " traduite. (Declaration variable)");

            ELSIF Verification_DeclarationType(ContenuLigne(1..LongueurLigne)) THEN

               --On insère la traduction de la declaration dans le fichier Ada.
               Ajout_Indentation(FichierTypeRes);
               Put(FichierTypeRes, Traduction_DeclarationType(ContenuLigne(1..LongueurLigne)));
               --On fait un retour chariot.
               Retour_Ligne(FichierTypeRes);
               --On indique à l'utilisateur que la ligne a été traduite.
               --put("Ligne" & Integer'Image(CompteurLigne) & " traduite. (Declaration type)");

            --ELSE

               --On indique à l'utilisateur que la ligne n'a pas été traduite.
               --Put("Ligne" & Integer'Image(CompteurLigne) & " non traduite. (Instruction inexistante)");

            END IF;

            New_Line;

         END IF;
         --On incremente le compteur de ligne.
         CompteurLigne:=Integer'Succ(CompteurLigne);

      END LOOP;

      --On indique dans le fichier Ada que le code commence.
      Retour_Ligne(FichierTypeRes);
      DebutDeclar:=False;
      Put(FichierTypeRes, "BEGIN");
      Retour_Ligne(FichierTypeRes, 2);

      WHILE NOT End_Of_File(FichierTypeSource) LOOP

         --Récuperation de la ligne du fichier.
         Get_Line(FichierTypeSource, ContenuLigne, LongueurLigne);

         --Affectation du type d'instruction de la ligne.
         TypeInstructionLigne:=Verification_Instruction(ContenuLigne(1..LongueurLigne));

         --Si la partie programme du code est commencée, on peut commencer les analyses du code.
         IF ContenuLigne(ChaineDebutCode'RANGE) /= ChaineDebutCode(ChaineDebutCode'RANGE) AND NOT DebutDeclar THEN

            --On vérifie quel type d'instruction la ligne est.
            --IF TypeInstructionLigne = 0 THEN

               --On indique à l'utilisateur que la ligne n'a pas été traduite.
               --put("Ligne" & Integer'Image(CompteurLigne) & " non traduite. (Instrution inexistante)");

            --ELSE

               --On indique la ligne a été traduite.
               --Put("Ligne" & Integer'Image(CompteurLigne) & " traduite. (Instruction " & Integer'Image(TypeInstructionLigne) & ")");

            --END IF;

            --New_Line;

            --On analyse la ligne, afin de déterminer quelle type d'instruction elle possède.
            CASE TypeInstructionLigne IS

               WHEN 11 => --On vérifie si c'est un "si non". Avant de vérifier si c'est juste un "si" afin de pas négliger le "non".
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Si(ContenuLigne(1..LongueurLigne), True));
                  Retour_Ligne(FichierTypeRes, 2);
                  CompteurIndent:=Integer'Succ(CompteurIndent);
               WHEN 9 => --On vérifie si c'est un appel de procédure.
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Fonction(ContenuLigne(1..LongueurLigne)));
                  Retour_Ligne(FichierTypeRes);
               WHEN 1 => --On vérifie si c'est un "si".
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Si(ContenuLigne(1..LongueurLigne)));
                  Retour_Ligne(FichierTypeRes, 2);
                  CompteurIndent:=Integer'Succ(CompteurIndent);
               WHEN 2 => --On vérifie si c'est une boucle "pour".
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Pour(ContenuLigne(1..LongueurLigne)));
                  Retour_Ligne(FichierTypeRes, 2);
                  CompteurIndent:=Integer'Succ(CompteurIndent);
               WHEN 31 => --On vérifie si c'est une boucle "tant que non".
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_TantQue(ContenuLigne(1..LongueurLigne), True));
                  Retour_Ligne(FichierTypeRes, 2);
                  CompteurIndent:=Integer'Succ(CompteurIndent);
               WHEN 3 => --On vérifie si c'est une boucle "tant que".
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_TantQue(ContenuLigne(1..LongueurLigne)));
                  Retour_Ligne(FichierTypeRes, 2);
                  CompteurIndent:=Integer'Succ(CompteurIndent);
               WHEN 5 => --On vérifie si c'est un "sinon".
                  CompteurIndent:=Integer'Pred(CompteurIndent);
                  Retour_Ligne(FichierTypeRes);
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Sinon(ContenuLigne(1..LongueurLigne)));
                  Retour_Ligne(FichierTypeRes, 2);
                  CompteurIndent:=Integer'Succ(CompteurIndent);
               WHEN 6 => --On vérifie si c'est une affectation de variable.
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Affectation(ContenuLigne(1..LongueurLigne)));
                  Retour_Ligne(FichierTypeRes);
               WHEN 7 => --On vérifie si c'est un "fsi".
                  CompteurIndent:=Integer'Pred(CompteurIndent);
                  Retour_Ligne(FichierTypeRes);
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Fsi);
                  Retour_Ligne(FichierTypeRes);
               WHEN 8 => --On vérifie si c'est un "fpour"
                  CompteurIndent:=CompteurIndent-1;
                  Retour_Ligne(FichierTypeRes);
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Fboucle);
                  Retour_Ligne(FichierTypeRes);
               WHEN 13 => --On vérifie si c'est un "ftq"
                  CompteurIndent:=CompteurIndent-1;
                  Retour_Ligne(FichierTypeRes);
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Fboucle);
                  Retour_Ligne(FichierTypeRes);
               WHEN 101 =>--On vérifie si c'est un "frepeter : jusqu'a non"
                  CompteurIndent:=CompteurIndent-1;
                  Retour_Ligne(FichierTypeRes);
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Frepeter(ContenuLigne(1..LongueurLigne), True));
                  Retour_Ligne(FichierTypeRes);
               WHEN 10 =>--On vérifie si c'est un "frepeter : jusqu'a"
                  CompteurIndent:=CompteurIndent-1;
                  Retour_Ligne(FichierTypeRes);
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Frepeter(ContenuLigne(1..LongueurLigne)));
                  Retour_Ligne(FichierTypeRes);
               WHEN 12 =>--On vérifie si c'est un "repeter"
                  Ajout_Indentation(FichierTypeRes, CompteurIndent);
                  Put(FichierTypeRes, Traduction_Repeter);
                  Retour_Ligne(FichierTypeRes, 2);
                  CompteurIndent:=CompteurIndent+1;
               WHEN OTHERS => put("");--Si ce n'est pas une instruction valide, on ne fait rien.

            END CASE;

            ContenuLigne(1..LongueurMaxLigne):=(OTHERS=>' ');--On remet la variable à zéro avec uniquement des espaces pour éviter des caractères inutiles.
            CompteurLigne:=Integer'Succ(CompteurLigne);--On incremente le numéro de ligne du fichier.
            TypeInstructionLigne:=0;

         END IF;

      END LOOP;

      --On indique dans le fichier Ada, que le programme est fini.
      Retour_Ligne(FichierTypeRes);
      Put(FichierTypeRes, "END " & FichierRes & ";");

      --On dit à l'utilisateur que la traduction est finie.
      Put("Le fichier '" & FichierRes & ".adb' traduit a partir de '" & FichierSource & ".txt' a ete cree.");


      --On ferme les deux fichiers.
      Close(FichierTypeSource);
      Close(FichierTypeRes);

      EXCEPTION

         --Erreur indiquant que le fichier n'existe pas.
         WHEN Erreur_Fichier_Inexistant => Put("Le fichier source n'existe pas, veuillez le creer");

   END Traduction_Fichier;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_DECLARATIONVARIABLE--------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Verification_DeclarationVariable(Contenu:String) RETURN Boolean IS

   PosParentheseOuvrante,PosParentheseFermante,PosEgal,PosPoints:Integer:=0;

BEGIN

   --On lit caractère par caractère de la chaine afin de trouver la syntaxe d'une déclaration.
   FOR I IN 1..Contenu'Length LOOP

      --Parenthèses, où se trouvera le type de la variable.
      IF Contenu(I) = '(' THEN PosParentheseOuvrante:=I;
      ELSIF Contenu(I) = ')' THEN PosParentheseFermante:=I;

      --Le égal de l'affectation.
      ELSIF Contenu(I) = '=' THEN PosEgal:=I;

      --Les deux points de la description de la variable.
      ELSIF Contenu(I) = ':' THEN PosPoints:=I;
      END IF;

   END LOOP;

   --La première parentèse ouvrante, doit se trouver au moins à la deuxième position.
   --La parenthèse ouvrante doit se trouver au moins à la 4eme position.
   --Il doit y avoir un caractère entre les deux parentheses.
   IF PosParentheseOuvrante > 1 AND PosParentheseFermante > 3 AND Integer'Succ(PosParentheseOuvrante) < PosParentheseFermante THEN

      IF PosEgal /= 0 AND PosPoints = 0 THEN

         IF Integer'Succ(PosParentheseFermante) = PosEgal THEN

            RETURN True;

         ELSE

            RETURN False;

         END IF;

      ELSIF PosEgal /= 0 AND PosPoints /= 0 THEN

         IF Integer'Succ(PosParentheseFermante) = PosEgal THEN

            IF Integer'Succ(PosEgal) < PosPoints THEN

               RETURN True;

            ELSE

               RETURN False;

            END IF;

         ELSE

            RETURN False;

         END IF;

      ELSE

         RETURN True;

      END IF;

   ELSE

      RETURN False;

   END IF;

END Verification_DeclarationVariable;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_FONCTION-------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Fonction vérifiant si la chaine est un appel de fonction, fonctionne sur le même principe que la déclaration.
FUNCTION Verification_Fonction(Contenu:String) RETURN Boolean IS

   PosParentheseOuvrante,PosParentheseFermante:Integer:=0;

BEGIN

   FOR I IN 1..Contenu'Length LOOP

      IF Contenu(I) = '(' THEN PosParentheseOuvrante:=I;
      ELSIF Contenu(I) = ')' THEN PosParentheseFermante:=I;
      END IF;

   END LOOP;

   IF PosParentheseOuvrante > 1 AND PosParentheseFermante > 3 AND (PosParentheseOuvrante < PosParentheseFermante) THEN

      RETURN True;

   ELSE

      RETURN False;

   END IF;

END Verification_Fonction;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_INSTRUCTION----------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Verification_Instruction(Contenu:String) RETURN Integer IS

   Retour:Integer:=0;

BEGIN

   IF Contenu'Length < 3 THEN

      RETURN 0;

   END IF;

   IF Verification_Si(Contenu, true) THEN--Si NON

      Retour:=11;

   ELSIF Verification_Si(Contenu) THEN--Si

      Retour:=1;

   ELSIF Verification_Pour(Contenu) THEN--Pour

      Retour:=2;

   ELSIF Verification_Frepeter(Contenu, true) THEN--jusqu'a non

      Retour:=101;

   ELSIF Verification_Frepeter(Contenu) THEN--jusqu'a

      Retour:=10;

   ELSIF Verification_Repeter(Contenu) THEN--repeter

      Retour:=12;

   ELSIF Verification_TantQue(Contenu, true) THEN--Tant que NON

      Retour:=31;

   ELSIF Verification_Fonction(Contenu) THEN--Appel de fonction

      Retour:=9;

   ELSIF Verification_TantQue(Contenu) THEN--Tant que

      Retour:=3;

   ELSIF Verification_Sinon(Contenu) THEN--Sinon

      Retour:=5;

   ELSIF Verification_Affectation(Contenu) THEN--Affectation de variable

      Retour:=6;

   ELSIF Verification_Fsi(Contenu) THEN--Fin de condition

      Retour:=7;

   ELSIF Verification_Fpour(Contenu) THEN--Fin de boucle "pour"

      Retour:=8;

   ELSIF Verification_Ftq(Contenu) THEN--Fin de boucle "tq"

      Retour:=13;

   END IF;

   RETURN Retour;

END Verification_Instruction;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_REPETER--------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Permet de vérifier si la chaine est une condition.
--Negation est une variable indiquant si la condition possède un "non".
FUNCTION Verification_Repeter(Contenu:String) RETURN Boolean IS
BEGIN

   IF Contenu'Length = 7 AND THEN (Contenu(Contenu'First..Contenu'First + 6) = "repeter")  THEN

      RETURN True;

   ELSE

      RETURN False;

   END IF;

END Verification_Repeter;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_DECLARATIONTYPE------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--a:type tableau[1..1]:a
FUNCTION Verification_DeclarationType(Contenu:String) RETURN Boolean IS

   PosCrochetOuvrant,PosCrochetFermant,PosPoints1,PosPoints2:Integer:=0;

BEGIN

   FOR I IN Contenu'RANGE LOOP

      IF Contenu(I) = '[' THEN

         PosCrochetOuvrant:=I;

      END IF;

      IF Contenu(I) = ']' THEN

         PosCrochetFermant:=I;

      END IF;

      IF Contenu(I) = ':' THEN

         IF PosPoints1 /= 0 THEN

            PosPoints2:=I;

         ELSE

            PosPoints1:=I;

         END IF;

      END IF;

   END LOOP;

   IF Contenu'Length > 15 AND THEN (PosPoints1 /= 0 AND PosPoints2 /= 0 AND PosCrochetOuvrant /= 0 AND PosCrochetFermant /= 0 AND Contenu(PosPoints1..PosCrochetOuvrant-1) = ":type tableau")  THEN

      RETURN True;

   ELSE

      RETURN False;

   END IF;

END Verification_DeclarationType;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_FREPETER-------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Verification_Frepeter(Contenu:String;Negation:Boolean:=False) RETURN Boolean IS
BEGIN

   IF Negation THEN

      IF Contenu'Length > 12 AND THEN (Contenu(Contenu'First..Contenu'First + 11) = "jusqu'a non ")  THEN

         RETURN True;

      ELSE

         RETURN False;

      END IF;

   ELSE

      IF Contenu'Length > 8 AND THEN (Contenu(Contenu'First..Contenu'First + 7) = "jusqu'a ")  THEN

         RETURN True;

      ELSE

         RETURN False;

      END IF;

   END IF;


END Verification_Frepeter;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_SI-------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Verification_Si(Contenu:String;Negation:Boolean:=False) RETURN Boolean IS
BEGIN

   --Si la condition possède un "non".
   IF Negation THEN

      IF Contenu'Length > 13 AND THEN (Contenu(Contenu'First..Contenu'First + 6) = "si non " AND Contenu((Contenu'Last-5)..Contenu'Last) = " alors") THEN

         RETURN True;

      ELSE

         RETURN False;

      END IF;

   --Si elle n'en possède pas.
   ELSE

      IF Contenu'Length > 9 AND THEN (Contenu(Contenu'First..Contenu'First + 2) = "si " AND Contenu((Contenu'Last-5)..Contenu'Last) = " alors") THEN

         RETURN True;

      ELSE

         RETURN False;

      END IF;

   END IF;


END Verification_Si;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_SINON_SI-------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Verifie si la chaine est un "sinon si".
FUNCTION Verification_Sinon_Si(Contenu:String) RETURN Boolean IS
begin

   IF Contenu'Length > 13 AND THEN (Contenu(Contenu'First..Contenu'First + 8) = "sinon si " and Contenu((Contenu'Last-5)..Contenu'Last) = " alors") THEN

      RETURN True;

   ELSE


      RETURN False;

   END IF;

END Verification_Sinon_Si;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_SINON----------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Verifie si la chaine est un "sinon".
FUNCTION Verification_Sinon(Contenu:String) RETURN Boolean IS
begin

   IF Contenu'Length = 5 AND THEN (Contenu(Contenu'First..Contenu'First + 4) = "sinon") THEN

      RETURN True;

   ELSE

      RETURN False;

   END IF;

END Verification_Sinon;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_FSI------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Vérifie si la chaine est une fin de condition.
FUNCTION Verification_Fsi(Contenu:String) RETURN Boolean IS
BEGIN

   IF Contenu(Contenu'First..Contenu'First + 2) = "fsi" THEN

      RETURN True;

   ELSE

      RETURN False;

   END IF;

END Verification_Fsi;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_AFFECTATION----------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Permet de vérifier si la chaine est une affectation de variable.
FUNCTION Verification_Affectation(Contenu:String) RETURN Boolean IS

   PosDebutFleche:Integer:=0;
   Espace:Boolean:=False;

BEGIN

   --On vérifie la présence d'un espace, si c'est le cas, on retourne faux.
   FOR I IN Contenu'RANGE LOOP

      --On compte le nombre d'espaces dans la chaine.
      IF Contenu(I) = ' ' THEN

         Espace:=True;

      END IF;

   END LOOP;

   --Si la chaine contient moins de 4 caractères ( a<-b ) on indique que ce n'est pas une affectation valide.
   IF Contenu'Length < 4 or Espace THEN

      RETURN False;

   END IF;

   --On lit caractère par caractère de la chaine.
   FOR I IN 2..Integer'Pred(Contenu'Length) LOOP

      --Si un < et un - se suivent.
      IF Contenu(I) = '<' AND Contenu(I+1) = '-' THEN

         PosDebutFleche:=I;

      END IF;

   END LOOP;

   --Vérifie si la position de la flèche ne se trouve pas au premier caractère.
   IF PosDebutFleche > 0 THEN

      --La variable est définie, on indique que c'est bon.
      RETURN True;

   ELSE

      --Il n'y a pas de variable définie, on retourne une contradiction.
      RETURN False;

   END IF;

END Verification_Affectation;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_FPOUR--------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Vérifie si la chaine est une fin de boucle pour
FUNCTION Verification_Fpour(Contenu:String) RETURN Boolean IS

BEGIN

   IF Contenu'Length > 4 AND THEN (Contenu(Contenu'First..Contenu'First+4) = "fpour") THEN

      RETURN True;

   ELSE

      RETURN False;

   END IF;

END Verification_Fpour;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_FTQ--------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Vérifie si la chaine est une fin de boucle pour
FUNCTION Verification_Ftq(Contenu:String) RETURN Boolean IS

BEGIN

   IF Contenu'Length > 2 AND THEN (Contenu(Contenu'First..Contenu'First+2) = "ftq") THEN

      RETURN True;

   ELSE

      RETURN False;

   END IF;

END Verification_Ftq;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_POUR----------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Verifie si la condition est un "pour".
FUNCTION Verification_Pour(Contenu:String) RETURN Boolean IS

   Espace:Integer:=0;
   PosEspace:Tableau;

BEGIN

   IF Contenu'Length > 20 THEN

      --On lit caractère par caractère.
      FOR I IN Contenu'RANGE LOOP

         --On compte le nombre d'espaces dans la chaine. (6 au total pour un boucle Pour).
         IF Contenu(I) = ' ' THEN

            Espace:=Integer'Succ(Espace);--On incremente le nombre d'espaces
            PosEspace(Espace):=I;

         END IF;

      END LOOP;

      --Forme générale d'un pour : Pour X de Y a Z faire
      --On vérifie qu'il y a "pour " au début.
      --Puis qu'après le deuxième éspace, il y à "de " avec un espace après, correspondant au 3eme espace.
      --Et auss qu'après le quatrième espace, on retrouve "a ", et que l'espace après le a correspond au 5eme espace.


      IF Espace = 6 AND THEN ((Contenu(Contenu'First..(Contenu'First+4)) = "pour "
            AND Contenu((PosEspace(2)+1)..(PosEspace(2)+3)) = "de "
      AND Contenu(Integer'Succ(PosEspace(4))) = 'a' AND PosEspace(4)+2 = PosEspace(5)
      AND Contenu((Contenu'Last-5)..Contenu'Last) = " faire")) THEN

         RETURN True;

      ELSE

         RETURN False;

      END IF;

   ELSE

      RETURN False;

   END IF;


END Verification_Pour;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VERIFICATION_TANTQUE--------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Indique si une boucle est un "tant que".
FUNCTION Verification_TantQue(Contenu:String; Negation:Boolean:=False) RETURN Boolean IS
begin

   IF Negation THEN

      IF Contenu'Length > 14 AND THEN  ( (Contenu(Contenu'First..(Contenu'First+11)) = "tant que non"  AND Contenu((Contenu'Last-4)..Contenu'Last) = "faire") ) THEN

         RETURN True;

      ELSE

         RETURN False;

      END IF;

   ELSE

      IF Contenu'Length > 14 AND THEN  ( (Contenu(Contenu'First..(Contenu'First+7)) = "tant que"  AND Contenu((Contenu'Last-4)..Contenu'Last) = "faire") ) THEN

         RETURN True;

      ELSE

         RETURN False;

      END IF;

   END IF;

END Verification_TantQue;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_SI---------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_Si(Contenu:String;Negation:Boolean:=false) RETURN String IS

BEGIN

   IF Negation THEN

      RETURN "if not" & Contenu((Contenu'First+6)..(Contenu'Last-5)) & "then";--si non

   ELSE

      RETURN "if" & Contenu((Contenu'First+2)..(Contenu'Last-5)) & "then";

   END IF;

END Traduction_Si;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_SINON_SI---------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_Sinon_Si(Contenu:String) RETURN String IS

BEGIN

   RETURN "elsif" & Contenu((Contenu'First+8)..(Contenu'Last-5)) & "then";

END Traduction_Sinon_Si;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_SINON------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_Sinon(Contenu:String) RETURN String IS

BEGIN

   RETURN "else" & Contenu((Contenu'First + 5)..Contenu'Last);

END Traduction_Sinon;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_FSI--------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_Fsi RETURN String IS

BEGIN

   RETURN "end if;";

END Traduction_Fsi;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_TANTQUE----------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_TantQue(Contenu:String; Negation:Boolean:=False) RETURN String IS
BEGIN

   IF Negation THEN

      RETURN "while not" & Contenu(Contenu'First+12..Contenu'Last-5) & "loop";--Tant que non

   ELSE

      RETURN "while" & Contenu(Contenu'First+8..Contenu'Last-5) & "loop";

   END IF;

END Traduction_TantQue;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_REPETER----------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_Repeter RETURN String IS
BEGIN

      RETURN "loop";

END Traduction_Repeter;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_FREPETER---------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_Frepeter(Contenu:String; Negation:Boolean:=False) RETURN String IS
BEGIN

   IF Negation THEN

      RETURN "exit when not" & Contenu(Contenu'First+11..Contenu'Last) & "; end loop;";--Jusqu'a non

   ELSE

      RETURN "exit when" & Contenu(Contenu'First+7..Contenu'Last) & "; end loop;";--Jusqu'a


   END IF;

END Traduction_Frepeter;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_POUR-------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Fonction permettant de traduire une boucle Pour.
-- Pour différencier les parametres de la boucle, on utilisera les espaces dans celle-ci pour délimiter.
FUNCTION Traduction_Pour(Contenu:String) RETURN String IS

   Espace:Integer:=0;--Variable compteur d'espace.
   --PosEspace:Tableau;--Tableau qui contiendra la position des 6 espaces.
   PosParam:Tableau;--Tableau contenant la position des caractères des paramètres.
   PosCaractereDebutParametre:Integer;--Variable temporaire qui donnera l'emplacement du caractere apres ou avant un espace.

BEGIN

   --Cette boucle permet de récuperer la position des espacess dans la boucle.
   --Boucle qui lit caractère par caractère de la chaine de boucle.
   FOR I IN Contenu'Range LOOP

      IF Contenu(I) = ' ' THEN--On vérifie si le caractère courant est un espace

         Espace:=Integer'Succ(Espace);--Incrémentation du nombre d'espace
         --PosEspace(Espace):=I;--On indique dans le tableau la position de l'espace courant.

         IF Espace mod 2 = 1 THEN
            -- Si le caractère est celui de début du paramètre, alors il se trouve après l'espace. On rajoutera donc 1 à la position de l'espace.
            PosCaractereDebutParametre:=Integer'Succ(I);
         ELSE
            -- Sinon, il sera placé avant l'espace, alors on retranche 1 à la position de l'espace.
            PosCaractereDebutParametre:=Integer'Pred(I);
         END IF;

         PosParam(Espace):=PosCaractereDebutParametre;--Affectation de la valeur dans la tableau

      END IF;

   END LOOP;

   RETURN "for " & Contenu(PosParam(1)..PosParam(2)) & " in " & Contenu(PosParam(3)..PosParam(4)) & ".." & Contenu(PosParam(5)..PosParam(6)) & " loop";

END Traduction_Pour;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_DECLARATIONVARIABLE----------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_DeclarationVariable(Contenu:String) RETURN String IS

   PosParentheseOuvrante,PosParentheseFermante,PosEgal,PosPoints,LongValeurResultat:Integer:=0;
   TypeResultat,TypeDepart,ValeurResultat:String(1..50):=(OTHERS=> ' ');
   LongTypeResultat:Integer;

BEGIN

   FOR I IN Contenu'RANGE LOOP

      IF Contenu(I) = '(' THEN PosParentheseOuvrante:=I;
      ELSIF Contenu(I) = ')' THEN PosParentheseFermante:=I;
      ELSIF Contenu(I) = '=' THEN PosEgal:=I;
      ELSIF Contenu(I) = ':' THEN PosPoints:=I;
      END IF;

   END LOOP;

   TypeDepart(1..(Integer'Pred(PosParentheseFermante)-Integer'Succ(PosParentheseOuvrante)+1)):=Contenu(Integer'Succ(PosParentheseOuvrante)..Integer'Pred(PosParentheseFermante));

   IF TypeDepart(1..6) = "entier" THEN

      TypeResultat(1..7):="Integer";
      LongTypeResultat:=7;

   ELSIF TypeDepart(1..6) = "chaine" THEN

      TypeResultat(1..6):="String";
      LongTypeResultat:=6;

   ELSIF TypeDepart(1..9) = "caractere" THEN

      TypeResultat(1..9):="Character";
      LongTypeResultat:=9;

   ELSIF TypeDepart(1..4) = "reel" THEN

      TypeResultat(1..5):="Float";
      LongTypeResultat:=5;

   ELSIF TypeDepart(1..7) = "booleen" THEN

      TypeResultat(1..7):="Boolean";
      LongTypeResultat:=7;

   ELSE

      TypeResultat(TypeDepart'RANGE):=TypeDepart;
      LongTypeResultat:=Integer'Pred(PosParentheseFermante)-Integer'Succ(PosParentheseOuvrante)+1;

   END IF;

   IF PosEgal = 0 AND PosPoints = 0 THEN

      RETURN Contenu(Contenu'First..Integer'Pred(PosParentheseOuvrante)) & ":" & TypeResultat(1..LongTypeResultat) & ";";

   ELSIF PosEgal = 0 AND PosPoints /= 0 THEN

      RETURN Contenu(Contenu'First..Integer'Pred(PosParentheseOuvrante)) & ":" & TypeResultat(1..LongTypeResultat) & ";--" & Contenu(Integer'Succ(PosPoints)..Contenu'Last);

   ELSIF PosEgal /= 0 AND PosPoints = 0 THEN

      IF TypeResultat(1..7) = "Boolean" AND THEN (Contenu(Integer'Succ(PosEgal)..Contenu'Last) = "vrai") THEN

         LongValeurResultat:=4;
         ValeurResultat(1..LongValeurResultat) := "True";

      ELSIF TypeResultat(1..7) = "Boolean" AND THEN (Contenu(Integer'Succ(PosEgal)..Contenu'Last) = "faux") THEN

         LongValeurResultat:=5;
         ValeurResultat(1..LongValeurResultat) := "False";

      ELSE

         LongValeurResultat:=Contenu'Last-Integer'Succ(PosEgal)+1;
         ValeurResultat(1..LongValeurResultat) := Contenu(Integer'Succ(PosEgal)..Contenu'Last);

      END IF;


      RETURN Contenu(Contenu'First..Integer'Pred(PosParentheseOuvrante)) & ":" & TypeResultat(1..LongTypeResultat) & ":=" & ValeurResultat(1..LongValeurResultat) & ";";

   ELSIF PosEgal /= 0 AND PosPoints /= 0 THEN

      IF Contenu(Integer'Succ(PosEgal)..Integer'Pred(PosPoints)) = "vrai" AND TypeResultat(1..7) = "Boolean" THEN

         LongValeurResultat:=4;
         ValeurResultat(1..LongValeurResultat) := "True";

      ELSIF Contenu(Integer'Succ(PosEgal)..Contenu'Last) = "faux" AND TypeResultat(1..7) = "Boolean" THEN

         LongValeurResultat:=5;
         ValeurResultat(1..LongValeurResultat) := "False";

      ELSE

         LongValeurResultat:=Integer'Pred(PosPoints)-Integer'Succ(PosEgal)+1;
         ValeurResultat(1..LongValeurResultat) := Contenu(Integer'Succ(PosEgal)..Integer'Pred(PosPoints));

      END IF;


      RETURN Contenu(Contenu'First..Integer'Pred(PosParentheseOuvrante)) & ":" & TypeResultat(1..LongTypeResultat) & ":="
      & ValeurResultat(1..LongValeurResultat) & ";--" & Contenu(Integer'Succ(PosPoints)..Contenu'Last);

   END IF;


END Traduction_DeclarationVariable;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_DECLARATIONTYPE--------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_DeclarationType(Contenu:String) RETURN String IS

   PosCrochetOuvrant,PosCrochetFermant,PosPoints1,PosPoints2:Integer:=0;
   TypeResultat,TypeDepart:String(1..25):=(OTHERS=> ' ');
   LongTypeDepart:Integer:=0;
   LongTypeResultat:Integer;

BEGIN

   FOR I IN Contenu'RANGE LOOP

      IF Contenu(I) = '[' THEN

         PosCrochetOuvrant:=I;

      END IF;

      IF Contenu(I) = ']' THEN

         PosCrochetFermant:=I;

      END IF;

      IF Contenu(I) = ':' THEN

         IF PosPoints1 /= 0 THEN

            PosPoints2:=I;

         ELSE

            PosPoints1:=I;

         END IF;

      END IF;

   END LOOP;

   LongTypeDepart:=Contenu'Last-Integer'Succ(PosPoints2)+1;

   TypeDepart(1..LongTypeDepart):=Contenu(Integer'Succ(PosPoints2)..Contenu'Last);

   IF LongTypeDepart = 6 AND TypeDepart(1..6) = "entier" THEN

      TypeResultat(1..7):="Integer";
      LongTypeResultat:=7;

   ELSIF LongTypeDepart = 6 AND TypeDepart(1..6) = "chaine" THEN

      TypeResultat(1..6):="String";
      LongTypeResultat:=6;

   ELSIF LongTypeDepart = 9 AND TypeDepart(1..9) = "caractere" THEN

      TypeResultat(1..9):="Character";
      LongTypeResultat:=9;

   ELSIF LongTypeDepart = 4 AND TypeDepart(1..4) = "reel" THEN

      TypeResultat(1..5):="Float";
      LongTypeResultat:=5;

   ELSIF LongTypeDepart = 7 AND TypeDepart(1..7) = "booleen" THEN

      TypeResultat(1..7):="Boolean";
      LongTypeResultat:=7;

   ELSE

      TypeResultat(TypeDepart'RANGE):=TypeDepart;
      LongTypeResultat:=Contenu'Last-Integer'Succ(PosPoints2)+1;

   END IF;

   RETURN "type " & Contenu(Contenu'First..PosPoints1-1) & " is array(" & Contenu(PosCrochetOuvrant+1..PosCrochetFermant-1) & ") of " & TypeResultat(1..LongTypeResultat) & ";";

END Traduction_DeclarationType;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_FONCTION---------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION Traduction_Fonction(Contenu:String) RETURN String IS

   PosParentheseOuvrante,PosParentheseFermante:Integer:=0;

BEGIN

   FOR I IN 1..Contenu'Length LOOP

      IF Contenu(I) = '(' THEN PosParentheseOuvrante:=I;
      ELSIF Contenu(I) = ')' THEN PosParentheseFermante:=I;
      END IF;

   END LOOP;

   IF Contenu(Contenu'First..Integer'Pred(PosParentheseOuvrante)) = "ecrire" THEN

      RETURN "put(" & Contenu(Integer'Succ(PosParentheseOuvrante)..Integer'Pred(PosParentheseFermante)) & ");";

   ELSIF Contenu(Contenu'First..Integer'Pred(PosParentheseOuvrante)) = "lire" THEN

      RETURN "get(" & Contenu(Integer'Succ(PosParentheseOuvrante)..Integer'Pred(PosParentheseFermante)) & ");";

   ELSE

      RETURN Contenu(Contenu'First..Integer'Pred(PosParentheseOuvrante)) & Contenu(Integer'Succ(PosParentheseOuvrante)..Integer'Pred(PosParentheseFermante)) & ");";

   END IF;

END Traduction_Fonction;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_AFFECTATION------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Traduit une affectation.
FUNCTION Traduction_Affectation(Contenu:String) RETURN String IS

   PosDebutFleche:Integer:=0;

begin

   FOR I IN Contenu'Range LOOP

      IF Contenu(I) = '<' THEN

         PosDebutFleche:=I;

      END IF;

   END LOOP;

   RETURN Contenu(Contenu'First..Integer'Pred(PosDebutFleche)) & ":=" & Contenu(PosDebutFleche+2..Contenu'Last) & ";";

END Traduction_Affectation;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TRADUCTION_FBOUCLE----------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Traduit une fin de boucle.
FUNCTION Traduction_Fboucle RETURN String IS

BEGIN

   RETURN "end loop;";

END Traduction_Fboucle;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------RETOUR_LIGNE----------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Procédure qui fait un retour chariot dans le fichier selectionné.
PROCEDURE Retour_Ligne(Fichier:File_Type;NbRetours:Integer:=1) IS

BEGIN

   FOR I IN 1..NbRetours LOOP

      New_Line(Fichier);

   END LOOP;

END Retour_Ligne;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------AJOUT_INDENTATION-----------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Procédure qui ajoute des espaces, afin de rendre lisible le code Ada.
PROCEDURE Ajout_Indentation(Fichier:File_Type;NbIndent:Integer:=0) IS
BEGIN

   FOR I IN 1..Integer'Succ(NbIndent) LOOP

      Put(Fichier, Indentation);

   END LOOP;

END Ajout_Indentation;




END P_Traduction;
