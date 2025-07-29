#!/bin/bash

# Funktion zum Synchronisieren von Konfigurationsdateien
sync_config() {
    local config_file="$1"
    local download_url="$2"

    # Parameter prüfen
    if [[ -z "$config_file" || -z "$download_url" ]]; then
        echo "Usage: sync_config <config_file_path> <download_url>"
        echo "Example: sync_config ~/.config/micro/settings.json https://raw.githubusercontent.com/user/dotfiles/main/micro/settings.json"
        return 1
    fi

    # Verzeichnis der Konfigurationsdatei erstellen falls nicht vorhanden
    local config_dir
    config_dir="$(dirname "$config_file")"
    mkdir -p "$config_dir"

    # Temporäre Datei für Download
    local temp_file
    temp_file=$(mktemp)

    # Datei herunterladen
    echo "Downloading configuration from: $download_url"
    if ! wget -q -O "$temp_file" "$download_url"; then
        echo "Error: Failed to download file from $download_url"
        rm -f "$temp_file"
        return 1
    fi

    # Prüfen ob lokale Datei existiert
    if [[ -f "$config_file" ]]; then
        echo "Configuration file already exists: $config_file"
        echo

        # Unterschiede anzeigen
        if diff -q "$config_file" "$temp_file" >/dev/null; then
            echo "Files are identical. No changes needed."
            rm -f "$temp_file"
            return 0
        else
            echo "Differences found:"
            echo "=================="

            # Farbige Diff-Ausgabe falls verfügbar
            if command -v colordiff >/dev/null 2>&1; then
                colordiff -u "$config_file" "$temp_file" | head -20
            else
                diff -u "$config_file" "$temp_file" | head -20
            fi

            # Bei vielen Unterschieden abkürzen
            local diff_lines
            diff_lines=$(diff -u "$config_file" "$temp_file" | wc -l)
            if [[ $diff_lines -gt 20 ]]; then
                echo "... (truncated, $diff_lines total lines of diff)"
            fi

            echo "=================="
            echo

            # Backup-Option anbieten
            echo "Current file: $config_file"
            echo "New file from: $download_url"
            echo
            echo "Options:"
            echo "  y/yes - Replace current file with downloaded version"
            echo "  b/backup - Create backup and replace"
            echo "  v/view - View full diff"
            echo "  n/no - Keep current file (default)"

            read -p "What would you like to do? [y/b/v/N]: " choice

            case "$choice" in
                y|yes|Y|YES)
                    cp "$temp_file" "$config_file"
                    echo "Configuration file updated: $config_file"
                    ;;
                b|backup|B|BACKUP)
                    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
                    cp "$config_file" "$backup_file"
                    cp "$temp_file" "$config_file"
                    echo "Backup created: $backup_file"
                    echo "Configuration file updated: $config_file"
                    ;;
                v|view|V|VIEW)
                    if command -v less >/dev/null 2>&1; then
                        if command -v colordiff >/dev/null 2>&1; then
                            colordiff -u "$config_file" "$temp_file" | less -R
                        else
                            diff -u "$config_file" "$temp_file" | less
                        fi
                    else
                        if command -v colordiff >/dev/null 2>&1; then
                            colordiff -u "$config_file" "$temp_file"
                        else
                            diff -u "$config_file" "$temp_file"
                        fi
                    fi
                    # Nach dem Anzeigen nochmal fragen
                    echo
                    read -p "Replace file after viewing? [y/N]: " replace_choice
                    if [[ "$replace_choice" =~ ^[yY] ]]; then
                        cp "$temp_file" "$config_file"
                        echo "Configuration file updated: $config_file"
                    else
                        echo "Configuration file kept unchanged."
                    fi
                    ;;
                *)
                    echo "Configuration file kept unchanged."
                    ;;
            esac
        fi
    else
        # Datei existiert nicht, einfach herunterladen
        echo "Configuration file not found. Creating: $config_file"
        cp "$temp_file" "$config_file"
        echo "Configuration file downloaded and saved: $config_file"
    fi

    # Temporäre Datei löschen
    rm -f "$temp_file"
}

# Erweiterte Funktion mit mehreren Dateien
sync_configs() {
    local config_list="$1"

    if [[ -z "$config_list" ]]; then
        echo "Usage: sync_configs <config_list_file>"
        echo "Config list format (one per line): /path/to/config.file|https://url/to/download"
        return 1
    fi

    if [[ ! -f "$config_list" ]]; then
        echo "Error: Config list file not found: $config_list"
        return 1
    fi

    while IFS='|' read -r config_file download_url; do
        # Leere Zeilen und Kommentare überspringen
        [[ -z "$config_file" || "$config_file" =~ ^[[:space:]]*# ]] && continue

        echo "Processing: $config_file"
        sync_config "$config_file" "$download_url"
        echo "----------------------------------------"
    done < "$config_list"
}

# Funktion für häufige Konfigurationen (Beispiele)
sync_micro_config() {
    sync_config ~/.config/micro/settings.json "https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.config/micro/settings.json"
}

sync_nvim_config() {
    sync_config ~/.bashrc "https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.bashrc"
}

sync_hypr_config() {
    sync_config ~/.config/kitty/kitty.conf "https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.config/kitty/kitty.conf"
}

sync_hypr_config() {
    sync_config ~/.config/zsd/settings.json "https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.config/zed/settings.json"
}

# Hilfsfunktion: Konfigurationsliste erstellen
create_config_list() {
    local list_file="${1:-~/.config/sync_list.txt}"

    cat > "$list_file" << 'EOF'
# Configuration sync list
# Format: /path/to/local/file|https://url/to/download
# Lines starting with # are ignored

~/.config/micro/settings.json|https://raw.githubusercontent.com/username/dotfiles/main/micro/settings.json
~/.config/nvim/init.lua|https://raw.githubusercontent.com/username/dotfiles/main/nvim/init.lua
~/.vimrc|https://raw.githubusercontent.com/username/dotfiles/main/vim/vimrc
~/.bashrc_custom|https://raw.githubusercontent.com/username/dotfiles/main/bash/bashrc_custom
EOF

    echo "Created config list template: $list_file"
    echo "Edit this file with your actual URLs and run: sync_configs $list_file"
}
