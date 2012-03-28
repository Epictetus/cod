#!/bin/bash
doc_sha=$(git ls-tree -d HEAD website/build | awk '{print $3}')
new_commit=$(echo "Auto-update docs." | git commit-tree $doc_sha -p refs/heads/gh-pages)
git update-ref refs/heads/gh-pages $new_commit
