#!/bin/bash
# Script: scripts/update_status.sh
# Parcourt les fichiers .md à la racine et met à jour leur statut et date dans le nom


set -e

# Recherche automatiquement tous les fichiers .md dans l'arborescence (hors README, TODO, etc. si besoin)
FILES=()
while IFS= read -r -d '' f; do
  fname=$(basename "$f")
  # Exclure certains fichiers si besoin
  case "$fname" in
    "README.md"|"TODO.md") continue;;
  esac
  # Retire tous les statuts et dates à la fin pour retrouver le "base" (chemin relatif sans extension ni statut)
  relpath="${f%.md}"
  # Supprime tous les blocs [STATUT][DATE] à la fin du nom (même multiples)
  # Ne garde que la partie avant le premier bloc [STATUT][DATE]
  base=$(echo "$relpath" | sed -E 's/(\s*\[[\?OK]+\]\[[0-9\-]+\])+.*$//')
  FILES+=("$base")
done < <(find . -type f -name '*.md' -print0)

# Fonction pour déterminer le statut d'un fichier
get_status() {
  local file="$1"
  # Si le fichier contient TODO ou une question sans réponse, statut = [?]
  if grep -E -q "\?\s*$|TODO|À compléter|\[\s*\]" "$file"; then
    echo "[?]"
  else
    echo "[OK]"
  fi
}

# Pour chaque fichier, met à jour le nom avec le statut et la date du dernier commit
for base in "${FILES[@]}"; do
  # Cherche le fichier correspondant (avec ou sans plusieurs statuts/dates)
  file=$(ls "${base}"*.md 2>/dev/null | head -n1)
  [ -z "$file" ] && continue
  status=$(get_status "$file")
  last_commit=$(git log -1 --format="%cd" --date=short -- "$file" 2>/dev/null)
  [ -z "$last_commit" ] && last_commit="$(date +%Y-%m-%d)"
  newname="${base} ${status}[${last_commit}].md"
  # Si le nom diffère, renomme
  if [[ "$file" != "$newname" ]]; then
    mv "$file" "$newname"
    echo "Renommé: $file -> $newname"
  fi
done
