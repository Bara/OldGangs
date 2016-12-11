#!/bin/bash

git fetch --unshallow
COUNT=$(git rev-list --count HEAD)
HASH="$(git log --pretty=format:%h -n 1)"
FILE=gangs-$2-$1-$COUNT-$HASH.zip
LATEST=gangs-latest-$2-$1.zip
HOST=$3
USER=$4
PASS=$5

echo "Download und extract sourcemod"
wget -q "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
# wget "http://www.sourcemod.net/latest.php?version=$1&os=linux" -O sourcemod.tar.gz
tar -xzf sourcemod.tar.gz

echo "Give compiler rights for compile"
chmod +x addons/sourcemod/scripting/spcomp

echo "Set plugins version"
for file in addons/sourcemod/scripting/include/gangs.inc
do
  sed -i "s/<ID>/$COUNT/g" $file > output.txt
  rm output.txt
done

echo "Compile plugins"
for file in addons/sourcemod/scripting/gangs*.sp
do
  addons/sourcemod/scripting/spcomp -E -v0 $file
done

echo "Remove plugins folder if exists"
if [ -d "addons/sourcemod/plugins" ]; then
  rm -r addons/sourcemod/plugins
fi

echo "Create clean plugins folder"
mkdir addons/sourcemod/plugins

echo "Move all other binary files to plugins folder"
for file in *.smx
do
  mv $file addons/sourcemod/plugins
done

echo "Remove api test plugin"
rm addons/sourcemod/plugins/gangs_api.smx

echo "Remove build folder if exists"
if [ -d "build" ]; then
  rm -r build
fi

echo "Create clean build folder"
mkdir build

echo "Move addons, materials and sound folder"
mv addons materials sound build/

echo "Remove sourcemod folders"
rm -r build/addons/metamod
rm -r build/addons/sourcemod/bin
rm -r build/addons/sourcemod/configs/geoip
rm -r build/addons/sourcemod/configs/sql-init-scripts
rm -r build/addons/sourcemod/configs
rm -r build/addons/sourcemod/data
rm -r build/addons/sourcemod/extensions
rm -r build/addons/sourcemod/gamedata
rm -r build/addons/sourcemod/scripting
rm -r build/addons/sourcemod/translations
rm build/addons/sourcemod/*.txt

# echo "Create clean translations folder"
# mkdir build/addons/sourcemod/translations

# echo "Download und unzip translations files"
# wget -q -O translations.zip http://translator.mitchdempsey.com/sourcemod_plugins/158/download/ttt.translations.zip
# unzip -qo translations.zip -d build/

echo "Clean root folder"
rm sourcemod.tar.gz
# rm translations.zip

echo "Go to build folder"
cd build

echo "Compress directories and files"
zip -9rq $FILE addons materials sound

echo "Upload file"
lftp -c "open -u $USER,$PASS $HOST; put -O gangs/downloads/$2/ $FILE"

echo "Add latest build"
mv $FILE $LATEST

echo "Upload latest build"
lftp -c "open -u $USER,$PASS $HOST; put -O gangs/downloads/ $LATEST"
