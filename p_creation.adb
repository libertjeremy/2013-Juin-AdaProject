-- Paquetage P_Creation contenant toutes les fonctions et procédures permettant la création guidée pas à pas d'un Algorithme.

PACKAGE BODY P_Creation IS

   Erreur_Longueur:EXCEPTION;
   ErreurLongueur:CONSTANT String(1..33):="  Erreur : Votre saisie est vide.";
   Erreur_Saisie:EXCEPTION;
   Erreur_Caractere:EXCEPTION;
   ErreurCaractere:CONSTANT String(1..40):="  Erreur : Il y a un caractere interdit.";


   ChaineDebutDeclaration:CONSTANT String(1..12):="-declaration";
   ChaineDebutCode:CONSTANT String(1..5):="-code";
   NbCaracteresMaximumType:CONSTANT Integer:=25;
   NbCaracteresMaximumVariable:CONSTANT Integer:=30;
   NbCaracteresMaximumLigne:CONSTANT Integer:=150;

   TYPE Tab_Variables_Crees IS ARRAY(1..50, 1..2) OF String(1..NbCaracteresMaximumVariable);
   VariablesCrees:Tab_Variables_Crees;--Tableau contenant les variables définies dans le programme en algo.
   TYPE Tab_Types IS ARRAY(1..25) OF String(1..NbCaracteresMaximumType);
   TypesCrees:Tab_Types;--Tableau des types de variables possibles
   TypesInterdits:Tab_Types;--Tableau des types de variables possibles


   CommandeAnnuler:CONSTANT String:="-annuler";--Commande pour annuler une action.
   CommandeQuitter:CONSTANT String:="-quitter";--Commande pour quitter le programme.

   NbCondition,NbTantQue,NbPour,NbFtantQue,NbFpour,NbFcondition,NbRepeter,NbFrepeter:Integer:=0;--Variables comptant le nombre de boucles/conditions et indiquant à l'utilisateur si des boucles/conditions ne sont pas terminées.
   Quitter:Boolean:=False;--Variable permettant de quitter le programme.
   CompteurNbVariables:Integer:=0;--Nombre de variables declarées dans le programme.
   CompteurLigne:Integer:=0;--Compteur du numéro de ligne.
   NbTypesCrees:Integer:=5;--Nombre de types déclarés.

   FichierType:File_Type;--Déclaration du type Fichier pour l'ensemble des fonctions.


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------CREATION_FICHIER------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Procédure principale qui est appellée dans le "main" et permet l'interaction avec l'utilisateur.
   PROCEDURE Creation_Fichier(Fichier:String) IS

      LongInstruction,LongReponse:Integer:=0;
      Instruction:String(1..15):=(OTHERS=>' ');
      Reponse:String(1..15):=(OTHERS=>' ');

   BEGIN

      --Ouverture et création du fichier où sera integré le code Algorithme.
      Create(FichierType, Out_File, Fichier & ".txt");
      Close(FichierType);

      New_Line;
      Put("-------------------------------------------------------------------");
      New_Line;
      Put("Commencez tout d'abord par declarer vos types et vos variables");
      New_Line;
      Put("Pour terminer vos declarations, inscrivez < " & CommandeAnnuler & " > ou < n >");
      New_Line;
      Put("-------------------------------------------------------------------");
      New_Line;

	  --Insertion de la ligne "-declaration" au début du fichier.
      Ligne_DebutDeclaration(Fichier & ".txt");

	  --Initialisation des tableaux pour les remettre à zéro.
      Initialisation_Types_Crees;
      Initialisation_Variables_Creees;
      Initialisation_Types_Interdits;

      LOOP

         BEGIN

            Put("Voulez-vous declarer un type tableau ? o/n : ");
            Get_Line(Reponse, LongReponse);

            IF LongReponse = 0 THEN

               RAISE Erreur_Longueur;

            END IF;

            IF Reponse(1) /= 'n' AND Reponse(1) /= 'o' THEN

               RAISE Erreur_Saisie;

            END IF;

            IF Reponse(1) = 'o' THEN

               Ligne_DeclarationType(Fichier & ".txt");

            END IF;

            EXIT WHEN Reponse(1) = 'n';

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Saisie => Put_Line("  Erreur : Saisir <o> ou <n>");

         END;

      END LOOP;

      Reponse(Reponse'RANGE):=(OTHERS=>' ');

      LOOP

         BEGIN

            Put("Voulez-vous declarer une variable ? o/n : ");
            Get_Line(Reponse, LongReponse);

            IF LongReponse = 0 THEN

               RAISE Erreur_Longueur;

            END IF;

            IF Reponse(1) /= 'n' AND Reponse(1) /= 'o' THEN

               RAISE Erreur_Saisie;

            END IF;

            IF Reponse(1) = 'o' THEN

               Ligne_DeclarationVariable(Fichier & ".txt");

            END IF;

            EXIT WHEN Reponse(1) = 'n';

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Saisie => Put_Line("  Erreur : Saisir <o> ou <n>");

         END;

      END LOOP;


      New_Line;
      Put("-------------------------------------------------------------------");
      New_Line;
      Put("Vous pouvez maintenant commencer a creer votre code");
      New_Line;
      Put("Pour terminer votre code, inscrivez < " & CommandeQuitter & " >");
      New_Line;
      Put("-------------------------------------------------------------------");
      New_Line;

      Ligne_DebutCode(Fichier & ".txt");

      LOOP

         New_Line;
         Put("Saisir l'instruction de la" & Integer'Image(Integer'Succ(CompteurLigne)) & "e ligne : ");
         Get_Line(Instruction, LongInstruction);

		 --On vérifie l'instruction demandée et on appelle la procédure permettant la création de cette instruction.
         IF Instruction(1..LongInstruction) = "condition" OR Instruction(1..LongInstruction) = "c" THEN

            Ligne_Condition(Fichier & ".txt");

         ELSIF Instruction(1..LongInstruction) = "fincondition" OR Instruction(1..LongInstruction) = "fc" THEN

            Ligne_Fcondition(Fichier & ".txt");

         ELSIF Instruction(1..LongInstruction) = "finpour" OR Instruction(1..LongInstruction) = "fp" THEN

            Ligne_Fpour(Fichier & ".txt");

         ELSIF Instruction(1..LongInstruction) = "fintantque" OR Instruction(1..LongInstruction) = "ftq" THEN

            Ligne_FtantQue(Fichier & ".txt");

         ELSIF Instruction(1..LongInstruction) = "finrepeter" OR Instruction(1..LongInstruction) = "fr" THEN

            Ligne_Frepeter(Fichier & ".txt");

         ELSIF Instruction(1..LongInstruction) = "boucle" OR Instruction(1..LongInstruction) = "b" THEN

            Ligne_Boucle(Fichier & ".txt");

         ELSIF Instruction(1..LongInstruction) = "affectation" OR Instruction(1..LongInstruction) = "a" THEN

            Ligne_Affectation(Fichier & ".txt");

         ELSIF Instruction(1..LongInstruction) = "ecrire" OR Instruction(1..LongInstruction) = "e" THEN

            Ligne_Ecrire(Fichier & ".txt");

         ELSIF Instruction(1..LongInstruction) = "lire" OR Instruction(1..LongInstruction) = "l" THEN

            Ligne_Lire(Fichier & ".txt");

         ELSIF Instruction(CommandeQuitter'RANGE) = CommandeQuitter THEN

            --Si il n'y a pas le meme nombre de début de "pour" que de "fin pour".
            IF NbPour /= NbFpour THEN

               New_Line;
               Put("Une boucle 'pour' n'a pas ete fermee, quitter quand meme ? o/n : ");
               Get_Line(Reponse, LongReponse);
               IF Reponse(1) = 'o' THEN

                  Quitter:=True;

               END IF;

            --Si il n'y a pas le meme nombre de début de "si" que de "fin si".
            ELSIF NbCondition /= NbFcondition THEN

               New_Line;
               Put("Une condition n'a pas ete fermee, quitter quand meme ? o/n : ");
               Get_Line(Reponse, LongReponse);

               IF Reponse(1) = 'o' THEN

                  Quitter:=True;

               END IF;

            --Si il n'y a pas le meme nombre de début de "repeter" que de "fin repeter".
            ELSIF NbRepeter /= NbFrepeter THEN

               New_Line;
               Put("Une boucle 'repeter' n'a pas ete fermee, quitter quand meme ? o/n : ");
               Get_Line(Reponse, LongReponse);

               IF Reponse(1) = 'o' THEN

                  Quitter:=True;

               END IF;

            --Si il n'y a pas le meme nombre de début de "tant que" que de "fin tant que".
            ELSIF NbTantQue /= NbFtantQue THEN

               New_Line;
               Put("Une boucle 'tant que' n'a pas ete fermee, quitter quand meme ? o/n : ");
               Get_Line(Reponse, LongReponse);

               IF Reponse(1) = 'o' THEN

                  Quitter:=True;

               END IF;

            ELSE

               Quitter:=True;

            END IF;

         ELSE

            Put_Line("  Erreur : Cette commande n'existe pas.");

         END IF;

         EXIT WHEN Quitter;

      END LOOP;

      New_Line;

	  --On indique que le fichier a été crée correctement.
      Put("Le fichier '" & Fichier & ".txt' a ete cree et contient" & Integer'Image(CompteurLigne) & " lignes de code.");

   END Creation_Fichier;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_DEBUTDECLARATION------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_DebutDeclaration(Fichier:String) IS
   BEGIN

      Open(FichierType, Append_File, Fichier);
      Put(FichierType, ChaineDebutDeclaration);
      Retour_Ligne(FichierType);
      close(FichierType);

   END Ligne_DebutDeclaration;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_DEBUTCODE-------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_DebutCode(Fichier:String) IS
   BEGIN

      Open(FichierType, Append_File, Fichier);
      Put(FichierType, ChaineDebutCode);
      Retour_Ligne(FichierType);
      close(FichierType);

   END Ligne_DebutCode;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_REPETER---------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_Repeter(Fichier:String) IS
   BEGIN

      Open(FichierType, Append_File, Fichier);
      Put(FichierType, "repeter");
      NbRepeter:=Integer'Succ(NbRepeter);
      CompteurLigne:=Integer'Succ(CompteurLigne);
      Retour_Ligne(FichierType);
      Close(FichierType);

   END Ligne_Repeter;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_FREPETER--------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_Frepeter(Fichier:String) IS

      Condition:String(1..50):=(others=>' ');
      LongCondition:Integer:=0;

   BEGIN

      --Si il y a le meme nombre de "repeter" que de "fin repeter", c'est qu'aucun "repeter" n'a besoin d'être fermé.
      IF NbRepeter = NbFrepeter THEN

         Put("  Erreur : Aucune boucle 'repeter' pour n'a precedemment ete commencee");
         New_Line;

      ELSE

         --On repete l'action.
         LOOP

            BEGIN

               Put(" => Inscrivez la condition de fin de boucle : ");
               Get_Line(Condition, LongCondition);

               --Si la saisie est vide.
               IF LongCondition = 0 THEN

                  --On renvoie une erreur de longueur.
                  RAISE Erreur_Longueur;

               ELSIF Mauvais_Caracteres(Condition(1..LongCondition), 2) THEN

                  RAISE Erreur_Caractere;

               END IF;

               --On sort de la boucle car la saisie par l'utilisateur est bonne.
               EXIT;

            EXCEPTION

               --L'erreur indiquant que la saisie est vide.
               WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
               WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

            END;

         END LOOP;

         --Si on ne demande pas à annuler l'action via la commande d'annulation.
         IF Condition(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

            Open(FichierType, Append_File, Fichier);
            Put(FichierType, "jusqu'a " & Condition(1..LongCondition));
            NbFrepeter:=Integer'Succ(NbFrepeter);
            Retour_Ligne(FichierType);
            CompteurLigne:=Integer'Succ(CompteurLigne);
            Close(FichierType);

         END IF;

      END IF;

   END Ligne_Frepeter;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_CONDITION-------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Procédure de debut de condition "si".
   PROCEDURE Ligne_Condition(Fichier:String) IS

      Condition:String(1..50):=(others=>' ');
      LongCondition:Integer:=0;

   BEGIN

      LOOP

         BEGIN

            Put(" => Inscrivez la condition : ");
            Get_Line(Condition, LongCondition);

            IF LongCondition = 0 THEN

               RAISE Erreur_Longueur;

            ELSIF Mauvais_Caracteres(Condition(1..LongCondition), 2) THEN

               RAISE Erreur_Caractere;

            END IF;

            --Si il y a le meme nombre de "tant que" que de "fin tant que", c'est qu'aucun "tant que" n'a besoin d'être fermé.
            EXIT;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

         END;

      END LOOP;

      --Si on ne demande pas à annuler l'action via la commande d'annulation.
      IF Condition(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

         Open(FichierType, Append_File, Fichier);
         Put(FichierType, "si " & Condition(1..LongCondition) & " alors");
         NbCondition:=Integer'Succ(NbCondition);
         Retour_Ligne(FichierType);
         CompteurLigne:=Integer'Succ(CompteurLigne);
         Close(FichierType);

      END IF;

   END Ligne_Condition;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_FCONDITON-------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Procédure de fin de condition "fsi".
   PROCEDURE Ligne_Fcondition(Fichier:String) IS

   BEGIN

      IF NbCondition = NbFcondition THEN

         Put("Aucune condition pour n'a precedemment ete commencee");
         New_Line;

      ELSE

         Open(FichierType, Append_File, Fichier);
         Put(FichierType, "fsi");
         Put(" => Condition terminee.");
         New_Line;
         Retour_Ligne(FichierType);
         NbFcondition:=Integer'Succ(NbFcondition);
         Close(FichierType);

      END IF;

   END Ligne_Fcondition;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_FPOUR-----------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_Fpour(Fichier:String) IS

   BEGIN

      --Si il y a le meme nombre de "pour" que de "fin pour", c'est qu'aucun "pour" n'a besoin d'être fermé.
      IF NbPour = NbFpour THEN

         Put(" => Aucune boucle 'pour' n'a precedemment ete commencee");
         New_Line;

      ELSE

         Open(FichierType, Append_File, Fichier);
         Put(FichierType, "fpour");
         Put("Boucle 'pour' terminee.");
         New_Line;
         NbFpour:=Integer'Succ(NbFpour);
         CompteurLigne:=Integer'Succ(CompteurLigne);
         Retour_Ligne(FichierType);
         Close(FichierType);

      END IF;

   END Ligne_Fpour;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_FTANTQUE--------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_FtantQue(Fichier:String) IS

   BEGIN

      --Si il y a le meme nombre de "tant que" que de "fin tant que", c'est qu'aucun "tant que" n'a besoin d'être fermé.
      IF NbTantQue = NbFtantQue THEN

         Put(" => Aucune boucle 'tant que' n'a precedemment ete commencee");
         New_Line;

      ELSE

         Open(FichierType, Append_File, Fichier);
         Put(FichierType, "ftq");
         Put("Boucle 'tant que' terminee.");
         New_Line;
         NbFtantQue:=Integer'Succ(NbFtantQue);
         Retour_Ligne(FichierType);
         Close(FichierType);

      END IF;

   END Ligne_FtantQue;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_BOUCLE----------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Procédure qui est appellée lors d'une demande de boucle.
   --Cette fonction permet de choisir le type de boucle que l'utilisateur souhaite ajouter.
   PROCEDURE Ligne_Boucle(Fichier:String) IS

      TypeBoucle:String(1..15):=(others=>' ');
      LongTypeBoucle:Integer:=0;
      Erreur_Boucle:Exception;

   BEGIN

      LOOP

         BEGIN

            Put(" => Type de boucle : ");
            Get_Line(TypeBoucle, LongTypeBoucle);

            IF LongTypeBoucle = 0 THEN

               RAISE Erreur_Longueur;

            ELSIF TypeBoucle(1..LongTypeBoucle) = "pour" OR TypeBoucle(1..LongTypeBoucle) = "p" THEN

               Ligne_Pour(Fichier);

            ELSIF TypeBoucle(1..LongTypeBoucle) = "tantque" OR TypeBoucle(1..LongTypeBoucle) = "tq" THEN

               Ligne_TantQue(Fichier);

            ELSIF TypeBoucle(1..LongTypeBoucle) = "repeter" OR TypeBoucle(1..LongTypeBoucle) = "r" THEN

               Ligne_Repeter(Fichier);

            ELSIF TypeBoucle(CommandeAnnuler'RANGE) = CommandeAnnuler THEN

               EXIT;

            ELSE

               RAISE Erreur_Boucle;

            END IF;

            EXIT;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Boucle => Put_Line("  Erreur : Aucune boucle de ce type.");

         END;

      END LOOP;

   END Ligne_Boucle;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_TANTQUE---------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_TantQue(Fichier:String) IS

      Condition:String(1..50):=(others=>' ');
      LongCondition:Integer:=0;

   BEGIN

      LOOP

         BEGIN

            Put(" => Inscrivez la condition de boucle : ");
            Get_Line(Condition, LongCondition);

            IF LongCondition = 0 THEN

               RAISE Erreur_Longueur;

            ELSIF Condition(CommandeAnnuler'RANGE) /= CommandeAnnuler AND Mauvais_Caracteres(Condition(1..LongCondition), 2) THEN

               RAISE Erreur_Caractere;

            END IF;

            EXIT;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

         END;

      END LOOP;

      --Si on ne demande pas à annuler l'action via la commande d'annulation.
      IF Condition(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

         Open(FichierType, Append_File, Fichier);
         Put(FichierType, "tant que " & Condition(1..LongCondition) & " faire");
         CompteurLigne:=Integer'Succ(CompteurLigne);
         NbTantQue:=Integer'Succ(NbTantQue);
         Retour_Ligne(FichierType);
         Close(FichierType);

      END IF;

   END Ligne_TantQue;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_POUR------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_Pour(Fichier:String) IS

      NomVar:String(1..NbCaracteresMaximumVariable):=(OTHERS=>' ');
      DebutIntervalle,FinIntervalle:String(1..50):=(OTHERS=>' ');
      LongNomVar,LongDebutIntervalle,LongFinIntervalle:Integer:=0;

   BEGIN

      LOOP

         BEGIN

            Put(" => Nom de la variable compteur : ");
            Get_Line(NomVar, LongNomVar);

            IF LongNomVar = 0 THEN

               RAISE Erreur_Longueur;

            ELSIF NomVar(CommandeAnnuler'RANGE) /= CommandeAnnuler AND Mauvais_Caracteres(NomVar(1..LongNomVar), 1) THEN

               RAISE Erreur_Caractere;

            END IF;

            EXIT;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

         END;

      END LOOP;

      --Si on ne demande pas à annuler l'action via la commande d'annulation.
      IF NomVar(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

         LOOP

            BEGIN

               Put(" => Debut intervalle (Variable/valeur de type scalaire) : ");
               Get_Line(DebutIntervalle, LongDebutIntervalle);

               IF LongDebutIntervalle = 0 THEN

                  RAISE Erreur_Longueur;

               ELSIF DebutIntervalle(CommandeAnnuler'RANGE) /= CommandeAnnuler AND Mauvais_Caracteres(DebutIntervalle(1..LongDebutIntervalle), 1) THEN

                  RAISE Erreur_Caractere;

               END IF;

               EXIT;

            EXCEPTION

               WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
               WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

            END;

         END LOOP;

         --Si on ne demande pas à annuler l'action via la commande d'annulation.
         IF DebutIntervalle(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

            LOOP

               BEGIN

                  Put(" => Fin intervalle : ");
                  Get_Line(FinIntervalle, LongFinIntervalle);

                  IF LongFinIntervalle = 0 THEN

                     RAISE Erreur_Longueur;

                  ELSIF FinIntervalle(CommandeAnnuler'RANGE) /= CommandeAnnuler AND Mauvais_Caracteres(FinIntervalle(1..LongFinIntervalle), 1) THEN

                     RAISE Erreur_Caractere;

                  END IF;

                  EXIT;

               EXCEPTION

                  WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
                  WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

               END;

            END LOOP;

            --Si on ne demande pas à annuler l'action via la commande d'annulation.
            IF FinIntervalle(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

               Open(FichierType, Append_File, Fichier);
               Put(FichierType, "pour " & NomVar(1..LongNomVar) & " de " & DebutIntervalle(1..LongDebutIntervalle) & " a " & FinIntervalle(1..LongFinIntervalle) & " faire");
               NbPour:=Integer'Succ(NbPour);
               CompteurLigne:=Integer'Succ(CompteurLigne);
               Retour_Ligne(FichierType);
               Close(FichierType);

            END IF;

         END IF;

      END IF;

   END Ligne_Pour;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_AFFFECTATION----------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_Affectation(Fichier:String) IS

      --Variable qui contiendra le nom de la variable à affecter.
      NomVar:String(1..NbCaracteresMaximumVariable):=(OTHERS=>' ');
      --Longueur du nom de la variable affectée.
      LongNomVar:Integer:=0;
      --Contenu de la variable affectée.
      Contenu:String(1..NbCaracteresMaximumLigne):=(OTHERS=>' ');
      --Longueur du texte du contenu.
      LongContenu:Integer:=0;
      LongTypeAffectation:Integer:=0;
      --Type d'affectation
      TypeAffectation:String(CommandeAnnuler'RANGE):=(OTHERS=>' ');
      Erreur_Variable_Non_Declaree:Exception;

   BEGIN

      LOOP

         BEGIN

            Put(" => Nom de la variable definie a affecter : ");
            Get_Line(NomVar, LongNomVar);

            IF LongNomVar = 0 THEN

               RAISE Erreur_Longueur;

            END IF;

            --Si on ne demande pas à annuler l'action via la commande d'annulation.
            IF NomVar(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

               IF NOT Variable_Existe(NomVar(1..LongNomVar)) THEN

                  RAISE Erreur_Variable_Non_Declaree;

               END IF;

            END IF;

            EXIT;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Variable_Non_Declaree => Put_Line("  Erreur : La variable n'existe pas.");

         END;

      END LOOP;

      --Si on ne demande pas à annuler l'action via la commande d'annulation.
      IF NomVar(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

         LOOP

            BEGIN

               Put(" => Affecter une valeur (1) ou variable (2) : ");
               Get_Line(TypeAffectation, LongTypeAffectation);

               IF LongTypeAffectation = 0 THEN

                  RAISE Erreur_Longueur;

               END IF;

               --Si on ne demande pas à annuler l'action via la commande d'annulation.
               IF TypeAffectation(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

                  IF TypeAffectation(1..LongTypeAffectation) /= "1" AND TypeAffectation(1..LongTypeAffectation) /= "2" THEN

                     RAISE Erreur_Saisie;

                  END IF;

               END IF;

            EXIT;

            EXCEPTION

               WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
               WHEN Erreur_Saisie => TypeAffectation(TypeAffectation'RANGE):=(OTHERS=>' '); Put_Line("  Erreur : Mauvaise saisie. Saisir 1 ou 2.");

            END;

         END LOOP;

         --Si on ne demande pas à annuler l'action via la commande d'annulation.
         IF TypeAffectation(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

            LOOP

               BEGIN

                  Put(" => Inscrivez la valeur/variable a affecter : ");
                  Get_Line(Contenu, LongContenu);

                  IF LongContenu = 0 THEN

                     RAISE Erreur_Longueur;

                  END IF;

                  EXIT;

               EXCEPTION

                 WHEN Erreur_Longueur => Put_Line(ErreurLongueur);

               END;

            END LOOP;

            --Si on ne demande pas à annuler l'action via la commande d'annulation.
            IF Contenu(CommandeAnnuler'Range) /= CommandeAnnuler THEN

               Open(FichierType, Append_File, Fichier);

               IF TypeAffectation(1..LongTypeAffectation) = "1" THEN

                  Put(FichierType, NomVar(1..LongNomVar) & "<-""" & Contenu(1..LongContenu) & """");
                  Retour_Ligne(FichierType);
                  CompteurLigne:=Integer'Succ(CompteurLigne);

               ELSE

                  Put(FichierType, NomVar(1..LongNomVar) & "<-" & Contenu(1..LongContenu));
                  Retour_Ligne(FichierType);
                  CompteurLigne:=Integer'Succ(CompteurLigne);

               END IF;

               Close(FichierType);

            END IF;

         END IF;

      END IF;

   END Ligne_Affectation;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_DECLARATIONVARIABLE---------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_DeclarationVariable(Fichier:String) IS

      NomVar:String(1..NbCaracteresMaximumVariable):=(OTHERS=>' ');
      ValeurVar,CommentVar:String(1..50):=(OTHERS=>' ');
      TypeVar:String(1..NbCaracteresMaximumType):=(OTHERS=>' ');
      LongNomVar,LongTypeVar,LongValeurVar,LongCommentVar:Integer:=0;
      Erreur_Type_Non_Declare,Erreur_Variable_Deja_Declaree:EXCEPTION;

   BEGIN

      LOOP

         BEGIN

            Put(" => Nom de la variable : ");
            Get_Line(NomVar, LongNomVar);

            IF LongNomVar = 0 THEN

               RAISE Erreur_Longueur;

            END IF;

            --Si on ne demande pas à annuler l'action via la commande d'annulation.
            IF NomVar(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

               IF Variable_Existe(NomVar(1..LongNomVar)) THEN

                  RAISE Erreur_Variable_Deja_Declaree;

               ELSIF NomVar(CommandeAnnuler'RANGE) /= CommandeAnnuler AND Mauvais_Caracteres(NomVar(1..LongNomVar), 1) THEN

                  RAISE Erreur_Caractere;

               END IF;

            END IF;

            EXIT;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Variable_Deja_Declaree => Put_Line("  Erreur : La variable existe deja.");
            WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

         END;

      END LOOP;

      --Si on ne demande pas à annuler l'action via la commande d'annulation.
      IF NomVar(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

         LOOP

            BEGIN

               Put(" => Type de la variable : ");
               Get_Line(TypeVar, LongTypeVar);

               IF LongTypeVar = 0 THEN

                  RAISE Erreur_Longueur;

               END IF;

               --Si on ne demande pas à annuler l'action via la commande d'annulation.
               IF TypeVar(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

			      --Si le type de la variable n'existe pas.
                  IF NOT Type_Existe(TypeVar(1..LongTypeVar)) THEN

                     RAISE Erreur_Type_Non_Declare;

                  END IF;

               END IF;

               EXIT;

            EXCEPTION

               WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
               WHEN Erreur_Type_Non_Declare => Put_Line("  Erreur : Le type n'existe pas.");

            END;

         END LOOP;

         --Si on ne demande pas à annuler l'action via la commande d'annulation.
         IF TypeVar(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

            CompteurNbVariables:=Integer'Succ(CompteurNbVariables);

			--On insère la variable créee dans le tableau des variables, pour éviter de la recréer.
            VariablesCrees(CompteurNbVariables, 1)(1..LongNomVar):=NomVar(1..LongNomVar);
            VariablesCrees(CompteurNbVariables, 2)(1..LongTypeVar):=TypeVar(1..LongTypeVar);

            Open(FichierType, Append_File, Fichier);

            Put(FichierType, NomVar(1..LongNomVar) & "(" & TypeVar(1..LongTypeVar) & ")");
            Put(" => Sa valeur par defaut (ou laisser vide) : ");

            Get_Line(ValeurVar, LongValeurVar);

            IF LongValeurVar > 0 THEN

               Put(FichierType, "=" & ValeurVar(1..LongValeurVar));

            END IF;

            Put(" => Commentez la variable (ou laisser vide) : ");
            Get_Line(CommentVar, LongCommentVar);

            IF LongCommentVar > 0 THEN

               Put(FichierType, ":" & CommentVar(1..LongCommentVar));

            END IF;

            Retour_Ligne(FichierType);
            Close(FichierType);
            CompteurLigne:=Integer'Succ(CompteurLigne);

         END IF;

      END IF;

   END Ligne_DeclarationVariable;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_DECLARATIONTYPE-------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_DeclarationType(Fichier:String) IS

      NomType,TypeContenu:String(1..NbCaracteresMaximumType):=(OTHERS=>' ');
      DebutIntervalle,FinIntervalle:String(1..25):=(OTHERS=>' ');
      LongNomType,LongTypeContenu,LongDebutIntervalle,LongFinIntervalle:Integer:=0;
      Erreur_Type_Deja_Declare,Erreur_Type_Inexistant:Exception;

   BEGIN

      LOOP

         BEGIN

            Put(" => Nom du type tableau : ");
            Get_Line(NomType, LongNomType);

            IF LongNomType = 0 THEN

               RAISE Erreur_Longueur;

            END IF;

            --Si on ne demande pas à annuler l'action via la commande d'annulation.
            IF NomType(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

               IF Type_Interdit(NomType(1..LongNomType)) OR Type_Existe(NomType(1..LongNomType)) THEN

                  RAISE Erreur_Type_Deja_Declare;

               ELSIF Mauvais_Caracteres(NomType(1..LongNomType), 1) THEN

                  RAISE Erreur_Caractere;

               END IF;

            END IF;

            EXIT;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Type_Deja_Declare => Put_Line("  Erreur : le type est interdit ou deja declare.");
            WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

         END;

      END LOOP;

      --Si on ne demande pas à annuler l'action via la commande d'annulation.
      IF NomType(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

         LOOP

            BEGIN

               Put(" => Type du contenu des cases : ");
               Get_Line(TypeContenu, LongTypeContenu);

               IF LongTypeContenu = 0 THEN

                  RAISE Erreur_Longueur;

               END IF;

               --Si on ne demande pas à annuler l'action via la commande d'annulation.
               IF TypeContenu(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

                  IF NOT Type_Existe(TypeContenu(1..LongTypeContenu)) THEN

                     RAISE Erreur_Type_Inexistant;

                  END IF;

               END IF;

               EXIT;

            EXCEPTION

               WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
               WHEN Erreur_Type_Inexistant => Put_Line("  Erreur : Le type n'existe pas.");

            END;

         END LOOP;

         --Si on ne demande pas à annuler l'action via la commande d'annulation.
         IF TypeContenu(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

            LOOP

               BEGIN

                  Put(" => Debut intervalle definition : ");
                  Get_Line(DebutIntervalle, LongDebutIntervalle);

                  IF LongDebutIntervalle = 0 THEN

                     RAISE Erreur_Longueur;

                  ELSIF DebutIntervalle(CommandeAnnuler'RANGE) /= CommandeAnnuler AND Mauvais_Caracteres(DebutIntervalle(1..LongDebutIntervalle), 1) THEN

                     RAISE Erreur_Caractere;

                  END IF;

                  EXIT;

               EXCEPTION

                  WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
                  WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

               END;

            END LOOP;

               --Si on ne demande pas à annuler l'action via la commande d'annulation.
            IF DebutIntervalle(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

               LOOP

                  BEGIN

                     Put(" => Fin intervalle definition : ");
                     Get_Line(FinIntervalle, LongFinIntervalle);

                     IF LongFinIntervalle = 0 THEN

                        RAISE Erreur_Longueur;

                     ELSIF FinIntervalle(CommandeAnnuler'RANGE) /= CommandeAnnuler AND Mauvais_Caracteres(FinIntervalle(1..LongFinIntervalle), 1) THEN

                        RAISE Erreur_Caractere;

                     END IF;

                     EXIT;

                  EXCEPTION

                     WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
                     WHEN Erreur_Caractere => Put_Line(ErreurCaractere);

                  END;

               END LOOP;

               --Si on ne demande pas à annuler l'action via la commande d'annulation.
               IF FinIntervalle(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

                  Open(FichierType, Append_File, Fichier);
                  NbTypesCrees:=Integer'Succ(NbTypesCrees);--Un nouveau type a été crée, on rajoute au compteur.
                  TypesCrees(NbTypesCrees)(1..LongNomType):=NomType(1..LongNomType);
                  Put(FichierType, NomType(1..LongNomType) & ":type tableau[" & DebutIntervalle(1..LongDebutIntervalle) & ".." & FinIntervalle(1..LongFinIntervalle) & "]:" & TypeContenu(1..LongTypeContenu));
                  Retour_Ligne(FichierType);
                  CompteurLigne:=Integer'Succ(CompteurLigne);
                  Close(FichierType);

               END IF;

            END IF;

         END IF;

      END IF;

   END Ligne_DeclarationType;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_ECRIRE----------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_Ecrire(Fichier:String) IS

      Contenu:String(1..NbCaracteresMaximumLigne);
      TypeEcriture:String(CommandeAnnuler'RANGE):=(OTHERS=>' ');
      LongContenu,LongTypeEcriture:Integer:=0;

   BEGIN

      LOOP

         BEGIN

            Put(" => Afficher une valeur (1) ou variable (2) : ");
            Get_Line(TypeEcriture, LongTypeEcriture);

            IF LongTypeEcriture = 0 THEN

               RAISE Erreur_Longueur;

            END IF;

            --Si on ne demande pas à annuler l'action via la commande d'annulation.
            IF TypeEcriture(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

               IF TypeEcriture(1..LongTypeEcriture) /= "1" AND TypeEcriture(1..LongTypeEcriture) /= "2" THEN

                  RAISE Erreur_Saisie;

               END IF;

            END IF;

            EXIT;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Saisie => TypeEcriture(TypeEcriture'RANGE):=(OTHERS=>' '); Put_Line("  Erreur : Mauvaise saisie. Saisir 1 ou 2.");

         END;

      END LOOP;

      --Si on ne demande pas à annuler l'action via la commande d'annulation.
      IF TypeEcriture(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

         LOOP

            BEGIN

               IF TypeEcriture(1..LongTypeEcriture) = "1" THEN

                  Put(" => Inscrivez la valeur a afficher : ");

               ELSE

                  Put(" => Inscrivez la variable a afficher : ");

               END IF;

               Get_Line(Contenu, LongContenu);

               IF LongContenu = 0 THEN

                  RAISE Erreur_Longueur;

               END IF;

               EXIT;

            EXCEPTION

               WHEN Erreur_Longueur => Put_Line(ErreurLongueur);

            END;

         END LOOP;

         --Si on ne demande pas à annuler l'action via la commande d'annulation.
         IF Contenu(CommandeQuitter'RANGE) /= CommandeQuitter THEN

            Open(FichierType, Append_File, Fichier);

            IF TypeEcriture(1..LongTypeEcriture) = "1" THEN

               Put(FichierType, "ecrire(""" & Contenu(1..LongContenu) & """)");
               Retour_Ligne(FichierType);
               CompteurLigne:=Integer'Succ(CompteurLigne);

            ELSE

               Put(FichierType, "ecrire(" & Contenu(1..LongContenu) & ")");New_Line(FichierType);
               CompteurLigne:=Integer'Succ(CompteurLigne);

            END IF;

            Close(FichierType);

         END IF;

      END IF;

   END Ligne_Ecrire;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LIGNE_LIRE------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Ligne_Lire(Fichier:String) IS

      NomVar:String(1..NbCaracteresMaximumVariable):=(others=>' ');
      LongNomVar:Integer:=0;

   BEGIN

      LOOP

         BEGIN

            Put(" => Nom de la variable qui recevra la valeur ecrite :  ");
            Get_Line(NomVar, LongNomVar);

            IF LongNomVar = 0 THEN

               RAISE Erreur_Longueur;

            END IF;

            EXIT;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);

         END;

      END LOOP;

      --Si on ne demande pas à annuler l'action via la commande d'annulation.
      IF NomVar(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

         Open(FichierType, Append_File, Fichier);
         Put(FichierType, "lire(" & NomVar(1..LongNomVar) & ")");
         CompteurLigne:=Integer'Succ(CompteurLigne);
         Retour_Ligne(FichierType);
         Close(FichierType);

      END IF;

   END Ligne_Lire;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------RETOUR_LIGNE----------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Retour_Ligne(Fichier:File_Type;NbRetours:Integer:=1) IS

   BEGIN

      FOR I IN 1..NbRetours LOOP

         New_Line(Fichier);

      END LOOP;

   END Retour_Ligne;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LONGUEUR_MOT----------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION Longueur_Mot(Mot:String) RETURN Integer IS

      Longueur:Integer:=Mot'Length;
      Termine:Boolean:=False;--Permet d'arreter la boucle dès qu'un espace est trouvé.

   BEGIN

      FOR I IN 1..Mot'Length LOOP

         IF Mot(I) = ' ' AND NOT Termine THEN

            Termine:=True;
            Longueur:=Integer'Pred(I);

         END IF;

      END LOOP;

      RETURN Longueur;

   END Longueur_Mot;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------INITIALISATION_TYPES_CREES--------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Pour initialiser les types déjà définis.
   PROCEDURE Initialisation_Types_Crees IS

   BEGIN

      FOR I IN TypesCrees'RANGE LOOP

         TypesCrees(I):=(OTHERS=>' ');

      END LOOP;

      TypesCrees(1)(1..6) := "entier";
      TypesCrees(2)(1..6) := "chaine";
      TypesCrees(3)(1..4) := "reel";
      TypesCrees(4)(1..7) := "booleen";
      TypesCrees(5)(1..9) := "caractere";

   END Initialisation_Types_Crees;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------INITIALISATION_VARIABLES_CREEES---------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


   --Pour initialiser le tableau de variables.
   PROCEDURE Initialisation_Variables_Creees IS

   BEGIN

      FOR I IN VariablesCrees'RANGE LOOP

         VariablesCrees(I, 1):=(OTHERS=>' ');
         VariablesCrees(I, 2):=(OTHERS=>' ');

      END LOOP;

   END Initialisation_Variables_Creees;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------INITIALISATION_TYPES_INTERDITS----------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Pour initialiser les types interdits à redéfinir.
   PROCEDURE Initialisation_Types_Interdits IS

   BEGIN

      FOR I IN TypesInterdits'RANGE LOOP

         TypesInterdits(I):=(OTHERS=>' ');

      END LOOP;

      TypesInterdits(1)(1..6) := "entier";
      TypesInterdits(2)(1..6) := "chaine";
      TypesInterdits(3)(1..4) := "reel";
      TypesInterdits(4)(1..7) := "booleen";
      TypesInterdits(5)(1..9) := "caractere";
      TypesInterdits(6)(1..7) := "integer";
      TypesInterdits(7)(1..6) := "string";
      TypesInterdits(8)(1..5) := "float";
      TypesInterdits(9)(1..7) := "boolean";
      TypesInterdits(10)(1..9) := "character";

   END Initialisation_Types_Interdits;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TYPE_EXISTE-----------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Verifie si un type est déjà declaré
   FUNCTION Type_Existe(ChaineType:String) RETURN Boolean IS

      Retour:Boolean:=False;

   BEGIN

      FOR I IN TypesCrees'RANGE LOOP

         IF ChaineType'Length = Longueur_Mot(TypesCrees(I)) AND THEN (TypesCrees(I)(ChaineType'RANGE) = ChaineType) THEN

            Retour:=True;

         END IF;

      END LOOP;

      RETURN Retour;

   END Type_Existe;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------TYPE_INTERDIT---------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Verifie si un type est interdit à être declaré.
   FUNCTION Type_Interdit(ChaineType:String) RETURN Boolean IS

      Retour:Boolean:=False;

   BEGIN

      FOR I IN TypesInterdits'RANGE LOOP

         IF ChaineType'Length = Longueur_Mot(TypesInterdits(I)) AND THEN (TypesInterdits(I)(ChaineType'RANGE) = ChaineType) THEN

            Retour:=True;

         END IF;

      END LOOP;

      RETURN Retour;

   END Type_Interdit;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VARIABLE_EXISTE-------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   --Verifie si une variable est déjà définie.
   FUNCTION Variable_Existe(ChaineVar:String) RETURN Boolean IS

      Retour:Boolean:=False;

   BEGIN

      FOR I IN VariablesCrees'RANGE LOOP

         IF ChaineVar'Length = Longueur_Mot(VariablesCrees(I, 1)) AND THEN (VariablesCrees(I, 1)(ChaineVar'RANGE) = ChaineVar) THEN

            Retour:=True;

         END IF;

      END LOOP;

      RETURN Retour;

   END Variable_Existe;

   FUNCTION Mauvais_Caracteres(Chaine:String; TypeCaracteres:Integer:=2) RETURN Boolean IS

      TYPE Tab_Caracteres_Interdits IS ARRAY(1..50) OF Character;
      Caracteres_Interdits:Tab_Caracteres_Interdits;
      Retour:Boolean:=False;

      BEGIN

         --Liste des caractères interdits dans un nom de variable, de type ou d'intervalle
         IF TypeCaracteres = 1 THEN

            Caracteres_Interdits(1):='(';
            Caracteres_Interdits(2):=')';
            Caracteres_Interdits(2):=')';
            Caracteres_Interdits(3):=';';
            Caracteres_Interdits(4):=''';
            Caracteres_Interdits(5):=']';
            Caracteres_Interdits(6):='[';
            Caracteres_Interdits(7):='{';
            Caracteres_Interdits(8):='}';
            Caracteres_Interdits(9):='/';
            Caracteres_Interdits(10):=',';
            Caracteres_Interdits(11):=' ';
            Caracteres_Interdits(12):='\';

         --Liste des caractères interdits dans une condition
         ELSE
            Caracteres_Interdits(1):='(';
            Caracteres_Interdits(2):=')';
            Caracteres_Interdits(2):=')';
            Caracteres_Interdits(3):=';';
            Caracteres_Interdits(4):=''';
            Caracteres_Interdits(5):='{';
            Caracteres_Interdits(6):='}';
            Caracteres_Interdits(7):=',';
            Caracteres_Interdits(8):=' ';
            Caracteres_Interdits(9):='\';

         END IF;


         FOR I IN Chaine'RANGE LOOP

            FOR J IN Tab_Caracteres_Interdits'RANGE LOOP

               IF NOT Retour AND THEN (Chaine(I) = Caracteres_Interdits(J)) THEN

                  Retour:=True;

               END IF;

            END LOOP;

         END LOOP;

         RETURN Retour;

      END Mauvais_Caracteres;

END P_Creation;