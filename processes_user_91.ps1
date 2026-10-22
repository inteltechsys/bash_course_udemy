# =====================================================================
# UnmodifiedPowerShellScript_commente.ps1
# Liste les processus d'un utilisateur donne (PT0-003 - Dion Training)
#
# OBJECTIF : afficher, pour UN compte utilisateur precis, tous ses
#            processus en cours, tries du plus gourmand en RAM au
#            moins gourmand.
# CONTEXTE : enumeration post-exploitation. Voir ce qu'un utilisateur
#            fait tourner revele : outils de securite (AV/EDR), sessions
#            admin, gestionnaires de mots de passe, navigateurs, etc.
# ATTENTION: script 100% Windows (WMI). Get-WmiObject n'existe que dans
#            Windows PowerShell 5.1 (pas dans PowerShell 7 / Linux).
#
# VERSION "UNMODIFIED" : c'est le script de depart du cours. Une version
# modifiee (ModifiedPowerShellScript.ps1) vient ensuite dans la video.
# =====================================================================


# ---------------------------------------------------------------------
# 1) PARAMETRE : LE COMPTE CIBLE
# ---------------------------------------------------------------------
# Set the user account to check processes for
# Variable $user = nom du compte a filtrer. Ici "kaley" est en dur :
# pour cibler un autre compte, il suffit de changer cette valeur.
# Le nom est compare SANS le domaine (voir section 3).
$user = "kaley"

# Message d'en-tete. Les guillemets doubles " " font l'expansion de
# variable : $user est remplace par "kaley" dans le texte affiche.
Write-Output "Listing processes running under this user account: $user"


# ---------------------------------------------------------------------
# 2) RECUPERATION DE TOUS LES PROCESSUS ET BOUCLE
# ---------------------------------------------------------------------
# Get-WmiObject Win32_Process interroge WMI (Windows Management
# Instrumentation). La classe Win32_Process = un objet par processus
# en cours (Name, ProcessId, WorkingSetSize, etc.). "Win32_Process"
# est passe en parametre positionnel (c'est le -Class).
#
# Le | (pipe) envoie ces objets UN PAR UN a ForEach-Object, qui execute
# le bloc { ... } pour chacun.
Get-WmiObject Win32_Process | ForEach-Object {

    # $_ designe l'objet courant dans le pipeline. On le copie dans $p
    # pour lui donner un nom clair. Ce n'est pas qu'esthetique : a
    # l'interieur d'un bloc catch, $_ devient l'objet ERREUR, donc on
    # perdrait le processus courant. $p, lui, reste stable.
    $p = $_

    # ---------------------------------------------------------------
    # 3) RECUPERATION DU PROPRIETAIRE (avec gestion d'erreur)
    # ---------------------------------------------------------------
    # try { } catch { } : on tente l'operation ; si elle echoue, on
    # saute dans le bloc catch au lieu de faire planter le script.
    try {
        # GetOwner() est une methode WMI de l'objet processus. Elle
        # renvoie un objet avec les proprietes User et Domain
        # (qui possede ce processus).
        # Elle echoue ou renvoie du vide pour certains processus
        # proteges (ex : System Idle Process, processus systeme) ou
        # si on n'a pas les droits (Access is denied).
        $owner = $p.GetOwner()

        # Condition en deux parties reliees par -and :
        #   a) $owner      : l'objet existe bien (n'est pas $null)
        #   b) $owner.User -eq $user : le nom d'utilisateur est egal
        #                    a la cible (-eq est insensible a la casse)
        # -and s'arrete des que la 1re partie est fausse : on ne lit
        # donc jamais .User sur un objet vide.
        if ($owner -and $owner.User -eq $user) {

            # -----------------------------------------------------------
            # 4) CONSTRUCTION DE LA LIGNE DE RESULTAT
            # -----------------------------------------------------------
            # [PSCustomObject]@{ ... } cree un objet personnalise a
            # partir d'une table de hachage (cle = valeur). Chaque cle
            # devient une "colonne" du resultat.
            # Cet objet n'est pas stocke : il est envoye directement
            # dans le pipeline (sortie implicite), puis ira vers
            # Sort-Object plus bas.
            [PSCustomObject]@{
                Name        = $p.Name         # nom de l'executable (ex : chrome.exe)
                ProcessId   = $p.ProcessId    # PID, l'identifiant unique du processus
                User        = $owner.User     # compte proprietaire
                Domain      = $owner.Domain   # domaine (ou nom de la machine si compte local)
                # WorkingSetSize = RAM physique utilisee, en OCTETS.
                # / 1MB convertit en megaoctets (1MB = 1 048 576 en
                # PowerShell). [int] convertit le resultat en entier.
                MemoryUsage = [int]($p.WorkingSetSize / 1MB)
            }
        }   # fin du if
    } catch {
        # "Not found", "Access is denied", etc. -> skip that process
        # Bloc volontairement vide : toute erreur est ignoree en silence
        # et on passe au processus suivant.
        # [Point d'attention pentest] Si tu n'es pas admin, beaucoup de
        # processus peuvent etre sautes SANS aucun message : la liste
        # affichee est alors INCOMPLETE. Ne jamais prendre un resultat
        # silencieux pour une liste exhaustive.
    }
} | Sort-Object MemoryUsage -Descending
# La } ferme le ForEach-Object. Le | suivant envoie TOUS les objets
# produits vers Sort-Object, qui les trie sur la propriete MemoryUsage
# en ordre decroissant (-Descending) : le processus le plus gourmand
# en RAM s'affiche en premier. Sort-Object attend d'avoir recu tous
# les objets avant d'afficher quoi que ce soit.


# ---------------------------------------------------------------------
# 5) MESSAGE DE FIN
# ---------------------------------------------------------------------
# Confirme que le script est arrive au bout (sans dire que la liste
# est complete : voir l'avertissement du bloc catch).
Write-Output "Filtered process listing for user $user completed."


# ---------------------------------------------------------------------
# NOTES
# ---------------------------------------------------------------------
# - Affichage : un objet a 5 proprietes s'affiche en general en LISTE
#   dans la console. Pour un tableau, ajouter | Format-Table a la fin.
# - PowerShell 7 : Get-CimInstance Win32_Process remplace
#   Get-WmiObject, MAIS les objets CIM n'ont pas de methode
#   .GetOwner() : il faut Invoke-CimMethod -MethodName GetOwner.
# - Alternative plus simple : Get-Process -IncludeUserName
#   (necessite une session PowerShell elevee/administrateur).
# ---------------------------------------------------------------------
