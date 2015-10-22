--Ecrire "modifier" dans main
--Verifier "afficher_algo"

WITH P_Traduction,P_Creation,P_Edition,Simple_Io;
USE P_Traduction,P_Creation,P_Edition,Simple_Io;

PROCEDURE Main IS

   NomFichier:String(1..25):=(others=>' ');
   CommandeAnnuler:CONSTANT String:="-annuler";--Commande pour annuler une action.
   LongNomFichier,LongNumCommande:Integer:=0;
   Erreur_Longueur,Erreur_Choix,Erreur_Fichier_Inexistant:EXCEPTION;

   NumCommande:String(1..15);

BEGIN

   New_Line;
   Put_Line("Bienvenue dans le Createur - Editeur - Traducteur d'Algorithme");
   Put_Line("Par BLANC Nathanael, GACA Sebastien et LIBERT Jeremy");

   LOOP

      BEGIN

         New_Line;
         Put("------------------------");New_Line;
         Put("Que souhaitez-vous faire ?");New_Line;
         Put("(1) : Creer un algorithme guide");New_Line;
         Put("(2) : Modifier un algorithme (non guide)");New_Line;
         Put("(3) : Traduire un algorithme en Ada");New_Line;
         Put("(4) : Quitter");New_Line;
         Put(" => ");
         Get_Line(NumCommande, LongNumCommande);

         EXIT WHEN NumCommande(1..LongNumCommande) = "4" OR NumCommande(1..LongNumCommande) = "-quitter";

         IF NumCommande(1..LongNumCommande) = "1" AND NumCommande(1..LongNumCommande) = "2" AND NumCommande(1..LongNumCommande) = "3" AND NumCommande(1..LongNumCommande) = "4" THEN

            RAISE Erreur_Choix;

         ELSIF NumCommande(1..LongNumCommande) = "1" OR NumCommande(1..LongNumCommande) = "creer" THEN

            LOOP

               BEGIN

                  New_Line;
                  Put("Quel nom voulez-vous donner a votre fichier .txt qui contiendra l'algorithme ?");
                  New_Line;
                  Put(" => ");
                  Get_Line(NomFichier, LongNomFichier);

                  IF LongNomFichier = 0 THEN

                     RAISE Erreur_Longueur;

                  END IF;

                  EXIT WHEN LongNomFichier > 0 OR NomFichier(CommandeAnnuler'RANGE) = CommandeAnnuler;

               EXCEPTION

                  WHEN Erreur_Longueur => Put("  Erreur : Saisissez au moins un caractere");New_line;

               END;

            END LOOP;

            IF NomFichier(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

               Creation_Fichier(NomFichier(1..LongNomFichier));New_Line;

            END IF;

         ELSIF NumCommande(1..LongNumCommande) = "2" OR NumCommande(1..LongNumCommande) = "modifier" THEN

            LOOP

               BEGIN

                  New_Line;
                  Put("Quel est le nom de votre fichier .txt a modifier ?");
                  New_Line;
                  Put(" => ");
                  Get_Line(NomFichier, LongNomFichier);

                  IF LongNomFichier = 0 THEN

                     RAISE Erreur_Longueur;

                  END IF;

                  IF NOT P_Traduction.Existence_Fichier(NomFichier(1..LongNomFichier) & ".txt") AND NomFichier(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

                     RAISE Erreur_Fichier_Inexistant;

                  END IF;

                  EXIT WHEN LongNomFichier > 0 OR NomFichier(CommandeAnnuler'RANGE) = CommandeAnnuler;

               EXCEPTION

                  WHEN Erreur_Longueur => Put("  Erreur : Saisissez au moins un caractere");New_Line;
                  WHEN Erreur_Fichier_Inexistant => Put("  Erreur : Le fichier n'existe pas");New_line;

               END;

            END LOOP;

            IF NomFichier(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

               Edition_Fichier(NomFichier(1..LongNomFichier));New_Line;

            END IF;

         ELSIF NumCommande(1..LongNumCommande) = "3" OR NumCommande(1..LongNumCommande) = "traduire" THEN

            LOOP

               BEGIN

                  New_Line;
                  Put("Quel est le nom de votre fichier .txt a traduire ?");
                  New_Line;
                  Put(" => ");
                  Get_Line(NomFichier, LongNomFichier);

                  IF LongNomFichier = 0 THEN

                     RAISE Erreur_Longueur;

                  END IF;

                  IF NOT P_Traduction.Existence_Fichier(NomFichier(1..LongNomFichier) & ".txt") AND NomFichier(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

                     RAISE Erreur_Fichier_Inexistant;

                  END IF;

                  EXIT WHEN LongNomFichier > 0 OR NomFichier(CommandeAnnuler'RANGE) = CommandeAnnuler;

               EXCEPTION

                  WHEN Erreur_Longueur => Put("  Erreur : Saisissez au moins un caractere");New_line;

               END;

            END LOOP;

            IF NomFichier(CommandeAnnuler'RANGE) /= CommandeAnnuler THEN

               Traduction_Fichier(NomFichier(1..LongNomFichier), NomFichier(1..LongNomFichier));New_Line;

            END IF;

         END IF;

      EXCEPTION

         WHEN Erreur_Choix => Put("  Erreur : Vous n'avez pas saisi un choix valide");New_Line;
         WHEN Erreur_Fichier_Inexistant => Put("  Erreur : Le fichier n'existe pas");New_line;

      END;

   END LOOP;



END Main;