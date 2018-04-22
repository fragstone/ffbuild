#!/bin/bash
start=$(date +%s)
echo CLEANUP
cd /home/build/gluon
make dirclean
git checkout v2017.1.x
rm -rf /home/build/site-ffniers
echo "Firmware Compilie for the Niersufer instance"
echo "get siteconfiguration"
cd /home/build
git clone https://github.com/ffniers/site-ffniers 
ln -s /home/build/site-ffniers /home/build/gluon/site
cd /home/build/site-ffniers
git checkout 2017.1.5
cd /home/build/gluon
make update
echo "preconfiguration done"
#OPTIONS="DEFAULT_GLUON_RELEASE=2016.2.3~exp$(date  '+%Y%m%d%H%M')"
CORES=$(expr $(nproc) + 1)
for TARGET in ar71xx-generic ar71xx-tiny ar71xx-nand brcm2708-bcm2708 brcm2708-bcm2709 mpc85xx-generic ramips-mt7621 x86-generic x86-geode x86-64; do
  echo "################# $(date) start building target $TARGET ###########################"
  make -j$CORES GLUON_TARGET=$TARGET $OPTIONS || exit 1 
done && echo "alle Targets wurden erfolgreich erstellt im ordner output/"
echo "Erstelle Manifest"
make manifest GLUON_BRANCH=stable
echo -n "finished: "; date
echo "Dauer: $((($(date +%s)-start)/60)) Minuten"
