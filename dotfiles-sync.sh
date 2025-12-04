#!/bin/bash

# ============================================================================
# KONFIGURATION - HIER DEINE DATEIEN UND URLS EINTRAGEN
# ============================================================================

# Format: "lokaler_pfad|download_url"
# Verwende $HOME statt ~ für bessere Kompatibilität
CONFIG_FILES=(
    "$HOME/.bashrc|https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.bashrc"
    "$HOME/.config/zed/settings.json|https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.config/zed/settings.json"
    "$HOME/.config/kitty/kitty.conf|https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.config/kitty/kitty.conf"
    "$HOME/.config/micro/settings.json|https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.config/micro/settings.json"
    "$HOME/.zshrc|https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.zshrc"
    "$HOME/.local/bin/locales-de.sh|https://raw.githubusercontent.com/faxxxmaster/scripte/refs/heads/main/locales-de.sh"
    "$HOME/.config/niri/config.kdl|https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.config/niri/config.kdl"
#    "$HOME/.config/kitty/meins/kiztty.conf|https://raw.githubusercontent.com/faxxxmaster/dotfiles/refs/heads/main/.config/niri/config.kdl"
#   "$HOME/.tmux.conf|https://raw.githubusercontent.com/username/dotfiles/main/tmux/tmux.conf"
#    "$HOME/.config/git/config|https://raw.githubusercontent.com/username/dotfiles/main/git/config"
#    "$HOME/.config/alacritty/alacritty.yml|https://raw.githubusercontent.com/username/dotfiles/main/alacritty/alacritty.yml"
)

# ============================================================================
# SCRIPT-OPTIONEN
# ============================================================================

# Automatische Backups erstellen (true/false)
AUTO_BACKUP=true

# Maximale Zeilen für Diff-Vorschau
MAX_DIFF_LINES=20

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# HILFSFUNKTIONEN
# ============================================================================

print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE} Configuration File Sync Tool${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Validierungsfunktionen
validate_json() {
    python3 -m json.tool "$1" >/dev/null 2>&1
}

validate_yaml() {
    python3 -c "
import yaml
try:
    with open('$1', 'r') as f:
        yaml.safe_load(f)
except:
    exit(1)
" 2>/dev/null
}

validate_file() {
    local file="$1"
    local extension="${file##*.}"

    case "$extension" in
        json)
            if ! validate_json "$file"; then
                print_warning "Downloaded file is not valid JSON!"
                return 1
            fi
            ;;
        yml|yaml)
            if ! validate_yaml "$file"; then
                print_warning "Downloaded file is not valid YAML!"
                return 1
            fi
            ;;
    esac
    return 0
}

# ============================================================================
# HAUPT-SYNC-FUNKTION
# ============================================================================

sync_single_config() {
    local config_file="$1"
    local download_url="$2"

    print_info "Processing: $(basename "$config_file")"
    echo "  Local:  $config_file"
    echo "  Remote: $download_url"
    echo

    # Verzeichnis erstellen
    local config_dir
    config_dir="$(dirname "$config_file")"
    mkdir -p "$config_dir"

    # Temporäre Datei für Download
    local temp_file
    temp_file=$(mktemp)

    # Datei herunterladen
    print_info "Downloading..."
    if ! wget -q --timeout=10 --tries=3 -O "$temp_file" "$download_url"; then
        print_error "Failed to download from: $download_url"
        rm -f "$temp_file"
        return 1
    fi

    # Datei validieren
    if ! validate_file "$temp_file"; then
        read -p "Continue despite validation warning? [y/N]: " continue_choice
        if [[ ! "$continue_choice" =~ ^[yY] ]]; then
            print_info "Skipping due to validation error."
            rm -f "$temp_file"
            return 1
        fi
    fi

    # Prüfen ob lokale Datei existiert
    if [[ -f "$config_file" ]]; then
        # Dateien vergleichen
        if diff -q "$config_file" "$temp_file" >/dev/null; then
            print_success "Files are identical. No changes needed."
            rm -f "$temp_file"
            return 0
        fi

        print_warning "Differences found!"
        echo

        # Diff anzeigen
        echo "--- Current file"
        echo "+++ New file from remote"
        if command -v colordiff >/dev/null 2>&1; then
            colordiff -u "$config_file" "$temp_file" | head -$MAX_DIFF_LINES
        else
            diff -u "$config_file" "$temp_file" | head -$MAX_DIFF_LINES
        fi

        # Bei vielen Unterschieden abkürzen
        local diff_lines
        diff_lines=$(diff -u "$config_file" "$temp_file" | wc -l)
        if [[ $diff_lines -gt $MAX_DIFF_LINES ]]; then
            echo "... (showing first $MAX_DIFF_LINES of $diff_lines total lines)"
        fi

        echo
        echo "Options:"
        echo "  [y] Replace current file"
        echo "  [b] Create backup and replace"
        echo "  [v] View full diff"
        echo "  [s] Skip this file"
        echo "  [q] Quit script"

        while true; do
            read -p "Choose action [y/b/v/s/q]: " choice

            case "$choice" in
                y|Y)
                    cp "$temp_file" "$config_file"
                    print_success "File updated: $config_file"
                    break
                    ;;
                b|B)
                    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
                    cp "$config_file" "$backup_file"
                    cp "$temp_file" "$config_file"
                    print_success "Backup created: $backup_file"
                    print_success "File updated: $config_file"
                    break
                    ;;
                v|V)
                    echo
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
                    echo
                    # Zurück zum Auswahlmenü
                    continue
                    ;;
                s|S)
                    print_info "Skipping file: $config_file"
                    break
                    ;;
                q|Q)
                    print_info "Exiting script."
                    rm -f "$temp_file"
                    exit 0
                    ;;
                *)
                    echo "Invalid choice. Please enter y, b, v, s, or q."
                    continue
                    ;;
            esac
        done
    else
        # Datei existiert nicht, direkt erstellen
        cp "$temp_file" "$config_file"
        print_success "New file created: $config_file"

        # Automatisches Backup falls gewünscht
        if [[ "$AUTO_BACKUP" == "true" ]]; then
            local backup_file="${config_file}.original.$(date +%Y%m%d_%H%M%S)"
            touch "$backup_file"  # Leeres Backup da Datei neu
            print_info "Original state backed up (empty): $backup_file"
        fi
    fi

    # Temporäre Datei löschen
    rm -f "$temp_file"
    echo
}

# ============================================================================
# HAUPTPROGRAMM
# ============================================================================

main() {
    print_header

    # Abhängigkeiten prüfen
    if ! command -v wget >/dev/null 2>&1; then
        print_error "wget is required but not installed."
        exit 1
    fi

    # Statistiken
    local total_files=${#CONFIG_FILES[@]}
    local processed=0
    local updated=0
    local errors=0

    print_info "Found $total_files configuration files to process."
    echo

    # Jede Konfigurationsdatei verarbeiten
    for config_entry in "${CONFIG_FILES[@]}"; do
        # Leere Einträge überspringen
        [[ -z "$config_entry" ]] && continue

        # Pfad und URL trennen
        IFS='|' read -r config_file download_url <<< "$config_entry"

        # Kommentare überspringen (Zeilen die mit # beginnen)
        [[ "$config_file" =~ ^[[:space:]]*# ]] && continue

        echo "----------------------------------------"

        if sync_single_config "$config_file" "$download_url"; then
            ((updated++))
        else
            ((errors++))
        fi

        ((processed++))
    done

    # Zusammenfassung
    echo "========================================"
    print_info "Sync completed!"
    echo "  Total files: $total_files"
    echo "  Processed: $processed"
    echo "  Updated: $updated"
    echo "  Errors: $errors"
    echo

    if [[ $errors -gt 0 ]]; then
        print_warning "Some files had errors. Check the output above."
        exit 1
    else
        print_success "All files processed successfully!"
    fi
}

# ============================================================================
# KOMMANDOZEILEN-OPTIONEN
# ============================================================================

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -n, --dry-run   Show what would be done without making changes"
    echo "  -q, --quiet     Suppress non-essential output"
    echo "  -f, --force     Auto-accept all updates (no prompts)"
    echo
    echo "Edit the CONFIG_FILES array at the top of this script to configure"
    echo "which files should be synchronized."
}

# Argumentverarbeitung
DRY_RUN=false
QUIET=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Script ausführen
main
