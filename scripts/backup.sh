#!/bin/bash
# Gregor Cienciala 05.2024

source backup.conf


blink_dots() {
  duration=$1
  end_time=$((SECONDS + duration))

  while [ $SECONDS -lt $end_time ]; do
    for i in {1..9}; do
      # Anzeige von i Punkten
      printf "\r"
      printf "%0.s." $(seq 1 $i)
      sleep 0.7
    done
    # Zurücksetzen der Anzeige nach 3 Punkten
    printf "\r   \r"
  done
}


#prüfen ob der Zielordner vorhanden ist sonst erstellen

if [ ! -d "$ziel_dir" ]; then
    mkdir -p "$ziel_dir"
fi

last_backup=$(ls -td $ziel_dir/backup* | head -1)

vorh_backups=$(find $ziel_dir/backup* -maxdepth 0 -type d | wc -l)

#echo "das findet find: $(find $ziel_dir/backup* -maxdepth 0 -type d)"
echo
echo "Folgende Ordner werden geischert $quelle_dir"
echo "Zielordner ist: $ziel_dir"
echo "Maximale Anzahl der Backups: $max_backups"
echo "Anzahl vorhandener Backups: $vorh_backups"
echo "Letztes gefundenes Backup: $last_backup"
echo
bold_red "Falsche Angaben? Änderungen in der >>>backup.conf<<< vornehmen"
echo
echo "heute ist $wochentag den $datum $zeit Uhr"

echo "----------------------------------------------------------------"

bold_cyan "Erstelle Backup vonm $quelle_dir nach $ziel_dir"

read -p "Fortfahren? (j/n)" ja



if [[ $ja =~ ^[Jj]$ ]]; then

    if [ -n "$last_backup" ]; then
        # Inkrementelles Backup
        echo "-----------------------------------"
        bold_cyan "inkrementelles Backup wird erstellt"
        echo "-----------------------------------"
blink_dots 5
        rsync $rsync_opt --link-dest="$last_backup" $quelle_dir "$akt_backup"
    else
        # Vollständiges Backup (erstes Backup)
        echo "--------------------------"
        bold_cyan "neues Backup wird erstellt"
        echo "--------------------------"
       blink_dots 5
       rsync $rsync_opt $quelle_dir "$akt_backup"
    fi

else

    echo "!!!!!!!!!!!!!!!!!!!!!"
    bold_red "Programm abgebrochen!"
    echo "!!!!!!!!!!!!!!!!!!!!!"
    exit
fi

#bold_red "kann jetzt noch abgebrochen werden"
#sleep 10

# prüfen ob Backup erstellet wurde
if [ $? -eq 0 ]; then
    echo "----------------------------------------"
    bold_green "Backup erfolgreich erstellt: $akt_backup"
    echo "----------------------------------------"
else
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "Fehler beim Erstellen des Backups"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
fi

# Löschen alter Backups, wenn die maximale Anzahl überschritten wird
# backups nach alter enlesen
backups=($(ls -td $ziel_dir/backup_*))

#zahl der vorhandenen Backups
anzahl_backups=${#backups[@]}

if [ $anzahl_backups -gt $max_backups ]; then
    #anzahl  backups zum löschen
    loesch=$((anzahl_backups - max_backups))
    echo "Lösche $loesch alte Backups..."
    #sleep 5
    for ((i = $max_backups; i < $anzahl_backups; i++)); do
        bold_red "Gelöscht: ${backups[$i]}..."
        #lösche älteste Datei
        rm -rf "${backups[$i]}"
    done
fi

bold_green "----------------"

# ermitteln der grösse des Backupordners
big=($(du -sh $ziel_dir | cut -f1 | tail -1))
max_big=($(df -h $ziel_dir | xargs | cut -d " " -f11))

bold_green "Fertig!"
bold_purple "Gesamtgrösse des Backupordners ist $big"
bold_purple "Verfügbarer Speicherplatz: $max_big"
bold_green "----------------"
