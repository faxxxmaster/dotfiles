#!/bin/bash

# Eingabedatei und Ausgabedatei definieren
input_file="test.txt"
output_file="output.csv"

# Überschriften für die CSV-Datei schreiben
echo "Fragennummer,Frage,Antwort 1,Antwort 2,Antwort 3,Antwort 4,Antwort 5,Richtige Antwort" > "$output_file"

# Variable für die aktuelle Fragennummer
fragennummer=0

# Die Eingabedatei zeilenweise lesen
while IFS= read -r line
do
    # Prüfen, ob die Zeile mit "Frage" beginnt
    if [[ $line == Frage* ]]; then
        # Fragennummer erhöhen
        fragennummer=$((fragennummer + 1))
        # Fragezeile speichern
        frage="$line"
        # Initialisierung der Antworten
        antworten=()
    # Prüfen, ob die Zeile mit "A." beginnt
    elif [[ $line == [A-Z].* ]]; then
        # Antwort hinzufügen
        antworten+=("${line:3}")
    # Prüfen, ob die Zeile mit "Richtige Antwort:" beginnt
    elif [[ $line == Richtige\ Antwort:* ]]; then
        # Richtige Antwort extrahieren
        richtige_antwort="${line:17}"
        # Frage, Antworten und richtige Antwort in die CSV-Datei schreiben
        echo "$fragennummer,\"$frage\",\"${antworten[0]}\",\"${antworten[1]}\",\"${antworten[2]}\",\"${antworten[3]}\",\"${antworten[4]}\",$richtige_antwort" >> "$output_file"
    fi
done < "$input_file"

echo "CSV-Datei wurde erstellt: $output_file"

