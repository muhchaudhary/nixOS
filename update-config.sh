#!/bin/bash

CONFIG_FILE='/etc/nixos/configuration.nix'
# create backup file
cp $CONFIG_FILE $CONFIG_FILE$'.bak'

mv 'configuration.nix' $CONFIG_FILE
