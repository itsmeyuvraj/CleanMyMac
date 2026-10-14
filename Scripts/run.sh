#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

if [ ! -d "MacCleaner.app" ]; then
    echo "MacCleaner.app not found. Running build first..."
    bash Scripts/build.sh
fi

echo "Launching Mac Cleaner..."
open MacCleaner.app
