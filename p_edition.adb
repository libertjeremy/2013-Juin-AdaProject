WITH P_Traduction,P_Creation,Simple_Io;
USE P_Traduction,P_Creation,Simple_Io;

PACKAGE BODY P_Edition IS

   Erreur_Ordonnancement:EXCEPTION;
   Erreur_Longueur:EXCEPTION;
   Erreur_Saisie:EXCEPTION;
   Erreur_Ligne_Interdite:EXCEPTION;
   Erreur_Condition:EXCEPTION;
   ErreurLongueur:CONSTANT String(1..33):="  Erreur : Votre saisie est vide.";

   CommandeQuitter:CONSTANT String:="-quitter";--Commande pour quitter le programme.
   CommandeAnnuler:CONSTANT String:="-annuler";--Commande pour annuler une action.


   NbCaracteresMaximumLigne:CONSTANT Integer:=150;--Nombres de caracteres maximum pour une ligne de code.

   TYPE Tab_Lignes IS ARRAY (0..100) OF String(1..NbCaracteresMaximumLigne);

   Fichiertype:File_Type;
   ChaineDebutDeclaration:CONSTANT String(1..12):="-declaration";
   ChaineDebutCode:CONSTANT String(1..5):="-code";
   LignesCode:Tab_Lignes;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------EDITION_FICHIER-------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Edition_Fichier(Fichier : String) IS

      Reponse:String(1..15):=(OTHERS=>' ');
      LongReponse:Integer:=0;

   BEGIN

      LOOP

         BEGIN

            New_Line;
            Put("------------------------");
            New_Line;

            Put("Voici l'algorithme dans le fichier " & Fichier & ".txt :");
            New_Line;
            New_Line;

            Afficher_Algo(Fichier);
            New_Line;
            Put("------------------------");
            New_Line;
            New_Line;

            Put("Souhaitez-vous modifier une ligne, ou modifier l'ordonnancement ? (l/o) : ");
            Get_Line(Reponse, LongReponse);

            EXIT WHEN Reponse(CommandeQuitter'RANGE) = CommandeQuitter OR Reponse(CommandeAnnuler'RANGE) = CommandeAnnuler;

            IF LongReponse = 0 THEN

               RAISE Erreur_Longueur;

            END IF;

            IF Reponse(1..LongReponse) /= "ligne" AND Reponse(1..LongReponse) /= "ordo" AND Reponse(1..LongReponse) /= "o" AND Reponse(1..LongReponse) /= "l" THEN

               RAISE Erreur_Saisie;

            END IF;

            IF Reponse(1) = 'o' THEN

               Edition_Ordonnancement(Fichier & ".txt");

            END IF;

            IF Reponse(1) = 'l' THEN

               Edition_Ligne(Fichier & ".txt");

            END IF;

         EXCEPTION

            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Saisie => Put_Line("  Erreur : Saisir <o> ou <n>");

         END;

      END LOOP;

   END Edition_Fichier;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------EDITION_ORDONNANCEMENT------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Edition_Ordonnancement(Fichier : String) IS

      Ligne:String(1..NbCaracteresMaximumLigne):=(OTHERS=>' ') ;
      LongueurLigne:Integer:=0;
      CompteurLigne:Integer:=1;
      NumeroLigne_Source,NumeroLigne_Destination,LongReponse:Integer:=0;
      PosDebutCode,PosDebutDeclaration:Integer:=1;
      Reponse:String(1..15);
      NbPour,NbFinPour,NbCondition,NbFinCondition,NbTantQue,NbFinTantQue,Nb_Repeter,Nb_FRepeter:Integer:=0;
      LignesCodeTemp:Tab_Lignes ;
      MauvaisOrdonnancement:Boolean:=False;

   BEGIN

      New_Line;
      Open(Fichiertype, In_File, Fichier);

      Initialisation_Tab_Lignes;

      WHILE NOT End_Of_File(Fichiertype) LOOP

         Get_Line(Fichiertype, Ligne, LongueurLigne);
         LignesCode(CompteurLigne)(1..Longueur_Ligne(Ligne)):=Ligne(1..Longueur_Ligne(Ligne));
         CompteurLigne:=Integer'Succ(CompteurLigne);
         Ligne:=Vider_Ligne;

      END LOOP;

      Close(Fichiertype);
      LignesCodeTemp:=LignesCode;

      LOOP

         MauvaisOrdonnancement:=False;

         BEGIN

            WHILE PosDebutDeclaration < LignesCode'LENGTH AND THEN(LignesCode(PosDebutDeclaration)(ChaineDebutDeclaration'RANGE) /= ChaineDebutDeclaration) LOOP

               PosDebutDeclaration:=PosDebutDeclaration+1;

            END LOOP;

            WHILE PosDebutCode < LignesCode'LENGTH AND THEN(LignesCode(PosDebutCode)(ChaineDebutCode'RANGE) /= ChaineDebutCode) LOOP

               PosDebutCode:=PosDebutCode+1;

            END LOOP;


            Put(" => Saisir le numero de la ligne a deplacer : ");
            Get(NumeroLigne_Source);

            IF (NumeroLigne_Source = PosDebutCode) OR (NumeroLigne_Source = PosDebutDeclaration) THEN

               RAISE Erreur_Ligne_Interdite;

            END IF;

            Put(" => Saisir le numero de la ligne au dessus de la quelle elle devrait etre : ");
            Get(NumeroLigne_Destination);
            Skip_Line;

            IF (((NumeroLigne_Source<=PosDebutCode) AND (NumeroLigne_Destination>PosDebutCode)) OR ((NumeroLigne_Source>=PosDebutCode) AND (NumeroLigne_Destination<=PosDebutCode))) THEN

               RAISE Erreur_Ordonnancement;

            END IF;

            WHILE NumeroLigne_Source < NumeroLigne_Destination LOOP

               Vider_Ligne_Tab(0);
               LignesCode(0)(1..Longueur_Ligne(LignesCode(NumeroLigne_Source))):=LignesCode(NumeroLigne_Source)(1..Longueur_Ligne(LignesCode(NumeroLigne_Source)));
               Vider_Ligne_Tab(NumeroLigne_Source);
               LignesCode(NumeroLigne_Source)(1..Longueur_Ligne(LignesCode(NumeroLigne_Source+1))):=LignesCode(NumeroLigne_Source+1)(1..Longueur_Ligne(LignesCode(NumeroLigne_Source+1)));
               Vider_Ligne_Tab(NumeroLigne_Source+1);
               LignesCode(NumeroLigne_Source+1)(1..Longueur_Ligne(LignesCode(0))):=LignesCode(0)(1..Longueur_Ligne(LignesCode(0)));
               Vider_Ligne_Tab(0);
               NumeroLigne_Source:=NumeroLigne_Source + 1;

            END LOOP;


            WHILE NumeroLigne_Source > NumeroLigne_Destination LOOP

               Vider_Ligne_Tab(0);
               LignesCode(0)(1..Longueur_Ligne(LignesCode(NumeroLigne_Source))):=LignesCode(NumeroLigne_Source)(1..Longueur_Ligne(LignesCode(NumeroLigne_Source)));
               Vider_Ligne_Tab(NumeroLigne_Source);
               LignesCode(NumeroLigne_Source)(1..Longueur_Ligne(LignesCode(NumeroLigne_Source-1))):=LignesCode(NumeroLigne_Source-1)(1..Longueur_Ligne(LignesCode(NumeroLigne_Source-1)));
               Vider_Ligne_Tab(NumeroLigne_Source-1);
               LignesCode(NumeroLigne_Source-1)(1..Longueur_Ligne(LignesCode(0))):=LignesCode(0)(1..Longueur_Ligne(LignesCode(0)));
               Vider_Ligne_Tab(0);
               NumeroLigne_Source:=NumeroLigne_Source - 1;

            END LOOP;

            FOR J IN LignesCode'RANGE LOOP

               IF LignesCode(J)(1) /= ' ' THEN

                  IF Verification_Si(LignesCode(J)(1..Longueur_Ligne(LignesCode(J)))) THEN

                     NbCondition:=Integer'Succ(NbCondition);

                  ELSIF Verification_Fsi(LignesCode(J)(1..Longueur_Ligne(LignesCode(J)))) THEN

                     NbFinCondition:=Integer'Succ(NbFinCondition);

                  ELSIF Verification_Pour(LignesCode(J)(1..Longueur_Ligne(LignesCode(J)))) THEN

                     NbPour:=Integer'Succ(NbPour);

                  ELSIF Verification_Fpour(LignesCode(J)(1..Longueur_Ligne(LignesCode(J)))) THEN

                     NbFinPour:=Integer'Succ(NbFinPour);

                  ELSIF Verification_TantQue(LignesCode(J)(1..Longueur_Ligne(LignesCode(J)))) THEN

                     NbTantQue:=Integer'Succ(NbTantQue);

                  ELSIF Verification_Ftq(LignesCode(J)(1..Longueur_Ligne(LignesCode(J)))) THEN

                     NbFinTantQue:=Integer'Succ(NbFinTantQue);

                  ELSIF Verification_Repeter(LignesCode(J)(1..Longueur_Ligne(LignesCode(J)))) THEN

                     Nb_Repeter:=Integer'Succ(Nb_Repeter);

                  ELSIF Verification_Frepeter(LignesCode(J)(1..Longueur_Ligne(LignesCode(J)))) THEN

                     Nb_FRepeter:=Integer'Succ(Nb_FRepeter);

                  END IF;

               END IF;

               IF (NbCondition < NbFinCondition) OR (NbPour < NbFinPour) OR (NbTantQue < NbFinTantQue) OR (Nb_Repeter < Nb_FRepeter) THEN

                  MauvaisOrdonnancement:=True;

               END IF;

            END LOOP;

            IF MauvaisOrdonnancement THEN

               LignesCode:=LignesCodeTemp;
               RAISE Erreur_Condition;

            ELSE

               Open(FichierType, Out_File, Fichier);

               FOR I IN LignesCode'RANGE LOOP

                  IF LignesCode(I)(1) /= ' ' THEN

                     Put(FichierType, LignesCode(I)(1..Longueur_Ligne(LignesCode(I))));
                     New_Line(FichierType);

                  END IF;

               END LOOP;

               Close(FichierType);

               EXIT;

            END IF;

         EXCEPTION

            WHEN Erreur_Ordonnancement => Put_Line(" Erreur : Impossible d'inverser declaration et code");
            WHEN Erreur_Ligne_Interdite => Put_Line(" Erreur : Impossible de deplacer '-code' ou '-declaration'");
            WHEN Erreur_Condition => Put_Line(" Erreur : Deplacement illicite !");

         END;

      END LOOP;


      LOOP

         BEGIN

            Reponse(1..15):=(OTHERS=>' ');
            New_Line;
            Skip_Line;
            Put("Voulez-vous continuer l'ordonnancement ? o/n : ");
            Get_Line(Reponse, LongReponse);

            EXIT WHEN Reponse(1) = 'n';

            IF LongReponse = 0 THEN

               RAISE Erreur_Longueur;

            ELSIF Reponse(1) /= 'n' AND Reponse(1) /= 'o' THEN

               RAISE Erreur_Saisie;

            ELSIF Reponse(1) = 'o' THEN

               Edition_Ordonnancement(Fichier);

            ELSE

               EXIT;

            END IF;

         EXCEPTION

            WHEN Erreur_Ordonnancement => Put_Line(" Erreur : Une ligne de code n'est pas une declaration.");
            WHEN Erreur_Longueur => Put_Line(ErreurLongueur);
            WHEN Erreur_Saisie => Put_Line(" Erreur : Saisir <o> ou <n>");

         END;

      END LOOP;

   END Edition_Ordonnancement;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------AFFICHER_ALGO---------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Afficher_Algo(Fichier:String) IS

      CompteurLigne:Integer:=1;
      Ligne:String(1..NbCaracteresMaximumLigne);
      LongLigne:Integer:=0;

   BEGIN

      Open(Fichiertype, In_File, Fichier & ".txt");

      WHILE NOT End_Of_File (Fichiertype) LOOP

         Get_Line(Fichiertype, Ligne, LongLigne);

         --On decalle le code pour la lisibilité.
         Put("   ");

         IF Ligne(ChaineDebutCode'RANGE) /= ChaineDebutCode AND Ligne(ChaineDebutDeclaration'RANGE) /= ChaineDebutDeclaration AND Ligne(1) /= ' ' THEN

            Put(Integer'Image(CompteurLigne) & " : ");

         END IF;

         Put(Ligne(1..LongLigne));
         New_Line;
         CompteurLigne:=Integer'Succ(CompteurLigne);

      END LOOP;

      Close(FichierType);

   END Afficher_Algo;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------EDITION_LIGNE---------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Edition_Ligne(Fichier:String) IS

      Ligne,LigneModifiee:String(1..NbCaracteresMaximumLigne):=(OTHERS=>' ');
      LongLigne, LongLigneModifiee:Integer:=0;
      CompteurLigne:Integer:=1;
      NumeroLigne:Integer:=0;

   BEGIN

      Initialisation_Tab_Lignes;

      Open(Fichiertype, In_File, Fichier);

      WHILE NOT End_Of_File(Fichiertype) LOOP

         Get_Line(Fichiertype, Ligne, LongLigne);
         LignesCode(CompteurLigne)(1..LongLigne):=Ligne(1..LongLigne);
         CompteurLigne:=Integer'Succ(CompteurLigne);

      END LOOP;

      Close(FichierType);

      LOOP

         BEGIN

            Put(" => Quelle ligne souhaitez vous modifier ? ");
            Get(NumeroLigne);
            New_Line;

            IF NumeroLigne < 0 THEN

               RAISE DATA_ERROR;

            END IF;

            EXIT WHEN NumeroLigne > 0 AND NumeroLigne <= LignesCode'LENGTH;

         EXCEPTION

            WHEN OTHERS => Put("  Erreur : Mauvaise saisie");

         END;

      END LOOP;

      Skip_Line;

      Put("Saisissez la ligne modifiee : ");
      New_Line;
      Put(" => ");
      Get_Line(LigneModifiee, LongLigneModifiee);

      Vider_Ligne_Tab(NumeroLigne);
      LignesCode(NumeroLigne)(1..LongLigneModifiee):=LigneModifiee(1..LongLigneModifiee);

      Open(FichierType, Out_File, Fichier);

      FOR I IN LignesCode'RANGE LOOP

         IF LignesCode(I)(1) /= ' ' THEN

            Put(FichierType, LignesCode(I)(1..Longueur_Ligne(LignesCode(I))));
            P_Creation.Retour_Ligne(FichierType);

         END IF;

      END LOOP;

      Close(FichierType);

   END Edition_Ligne;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------INITIALISATION_TAB_LIGNES---------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Initialisation_Tab_Lignes IS
   BEGIN

      FOR I IN LignesCode'RANGE LOOP

         LignesCode(I):=(OTHERS=>' ');

      END LOOP;

   END Initialisation_Tab_Lignes;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------LONGUEUR_LIGNE-------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION Longueur_Ligne(Ligne:String) RETURN Integer IS

      Retour:Integer:=0;

   BEGIN

      FOR I IN 1..Ligne'Length - 1 LOOP

         IF Ligne(I) = ' ' AND Ligne(I+1) = ' ' THEN

            RETURN I-1;

         END IF;

      END LOOP;

      FOR I IN Ligne'RANGE LOOP

         Retour:=Integer'Succ(Retour);

      END LOOP;

   RETURN Retour;

   END Longueur_Ligne;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VIDER_LIGNE_TAB-------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE Vider_Ligne_Tab(NumeroLigne:Integer) IS
   BEGIN

      FOR I IN 1..NbCaracteresMaximumLigne LOOP

         LignesCode(NumeroLigne)(I):= ' ';

      END LOOP;

   END Vider_Ligne_Tab;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------VIDER_LIGNE-----------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

   FUNCTION Vider_Ligne RETURN String IS

      Ligne_Espace:String(1..NbCaracteresMaximumLigne);

   BEGIN

      FOR I IN 1..NbCaracteresMaximumLigne LOOP

         Ligne_Espace(I):=' ';

      END LOOP;

      RETURN Ligne_Espace;

   END Vider_Ligne;

END P_Edition;