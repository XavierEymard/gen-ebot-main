#!/bin/bash
# Script: scripts/update_status.sh
# Parcourt les fichiers .md à la racine et met à jour leur statut et date dans le nom


set -e


# Nouvelle logique robuste :
# 1. Pour chaque base, ne garder qu'un seul fichier (le plus récent), supprimer les doublons
# 2. Renommer le fichier gardé avec un seul bloc [STATUT][DATE]

find . -type f -name '*.md' | while read -r f; do
  fname=$(basename "$f")
  case "$fname" in
    "README.md"|"TODO.md") continue;;
  esac
  # Base = chemin sans statuts/dates
  relpath="${f%.md}"
  base=$(echo "$relpath" | sed -E 's/(\s*\[[\?OK]+\]\[[0-9\-]+\])+.*$//')
  echo "$base|$f"
done | sort > .all_md_files.tmp

cut -d'|' -f1 .all_md_files.tmp | sort | uniq | while read -r base; do
  files=( $(grep "^$base|" .all_md_files.tmp | cut -d'|' -f2) )
  # Garde le plus récent (modification)
  keep=$(ls -t "${files[@]}" | head -n1)
  # Supprime les autres
  for f in "${files[@]}"; do
    if [[ "$f" != "$keep" ]]; then
      rm "$f"
      echo "Supprimé: $f"
    fi
  done
  # Statut
  status="[?]"
  if grep -E -q "\?\s*$|TODO|À compléter|\[\s*\]" "$keep"; then
    status="[?]"
  else
    status="[OK]"
  fi
  last_commit=$(git log -1 --format="%cd" --date=short -- "$keep" 2>/dev/null)
  [ -z "$last_commit" ] && last_commit="$(date +%Y-%m-%d)"
  newname="${base} ${status}[${last_commit}].md"
  if [[ "$keep" != "$newname" ]]; then
    mv "$keep" "$newname"
    echo "Renommé: $keep -> $newname"
  fi
done
rm .all_md_files.tmp

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
