#!/bin/bash

echo "Download und extract sourcemod"
wget -q "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
# wget "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
tar -xzf sourcemod.tar.gz

echo "Give compiler rights for compile"
chmod +x addons/sourcemod/scripting/spcomp

echo "Compile ttt plugins"
for file in addons/sourcemod/scripting/gangs*.sp
do
  addons/sourcemod/scripting/spcomp -E -v0 $file
done
