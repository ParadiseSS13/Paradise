#!/bin/bash

if [ -f "config/config.txt" ]; then
     echo "Existing config.txt found, starting server..."
else
    echo "Configuration not present, copying default (example) config..."
    cp -r defaultconfig/* config/
    cp config/example/* config/ 
    echo "Config copied, starting server..."
fi

exec "$@"