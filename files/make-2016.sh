#!/bin/bash

# Bitte vorher eine Unterverzeichnisstruktur unterhalb von $SITEPATH erstellen.
# Ein Verzeichnis pro Site konfiguration.
# WICHTIG. Und bitte mit git checkout bereits in den richtigen branch wechseln
#
# Beispiel fuer einen korrekten Check eines 2016er Branches
# build@1db8457d2a53:~/site/2016/niers$ for i in `ls ~/site/2016`;do echo $i;cd ~/site/2016/$i; git branch ; done
# mg
# * 2016.2-l2tp
#   master
# mo
# * 2016.2-l2tp
#   master
# niers
# * 2016.2-l2tp
#   master

DATE=`date +%F-%H-%M`
LOGFILE=~/make-2016-${DATE}
SITEPATH=~/site/2016
GLUONDIR=~/gluon-2016
# Hier den passenden Gluon Branch definieren.
GLUONBASEBRANCH=v2016.2.x
GLUONBRANCH=v2016.2.7
IMAGEPATH=~/images
COMPILECORES=$(expr $(nproc) + 1)
OPTIONS="GLUON_BRANCH=stable"

echo `date +%F-%H-%M` "PROGRAMM START" >> ${LOGFILE}

#Cleanup

if [ -d "${GLUONDIR}" ]; then
  cd ${GLUONDIR}
  make dirclean
else 
  git clone https://github.com/freifunk-gluon/gluon ${GLUONDIR}
fi

#START Build

for SITE in ` ls ${SITEPATH}|tac`
do
# Wenn Variable SITE leer ist, dann Abbruch
if [ -z $SITE ]; then echo "SITE Variable leer" >> ${LOGFILE} && exit 1; fi

echo `date +%F-%H-%M` ${SITE} "Start Build" >> ${LOGFILE}

# SITECONF Link neu setzen
rm ${GLUONDIR}/site
ln -s ${SITEPATH}/${SITE} ${GLUONDIR}/site 

# Site konfiguration des Branch Updaten
cd ${SITEPATH}/${SITE}
git pull

# GLUON Branch wechseln und updaten
cd ${GLUONDIR}
git checkout ${GLUONBASEBRANCH}
make update
git checkout ${GLUONBRANCH}
make update

  for TARGET in ar71xx-generic ar71xx-tiny ar71xx-nand brcm2708-bcm2708 brcm2708-bcm2709 mpc85xx-generic ramips-mt7621 x86-generic x86-geode x86-64; do
    echo `date +%F-%H-%M` ${SITE} "start building target" ${TARGET} >> ${LOGFILE}
    make -j$CORES GLUON_TARGET=${TARGET} ${OPTIONS} || echo `date +%F-%H-%M` ${SITE} "Probeleme beim Kompilieren" >> ${LOGFILE} && exit 1
    #make V=s GLUON_TARGET=${TARGET} ${OPTIONS} || echo `date +%F-%H-%M` ${SITE} "Probeleme beim Kompilieren" >> ${LOGFILE} && exit 1
  done && echo `date +%F-%H-%M` ${SITE} "Alle Targets wurden erfolgreich erstellt" >> ${LOGFILE}

make manifest GLUON_BRANCH=stable
echo `date +%F-%H-%M` ${SITE} "Manifest erstellt" >> ${LOGFILE}

#Export Images & Packages
if [ -d "${IMAGEPATH}/${SITE}" ]; then
mkdir ${DATE}
fi
# Images Verschieben.
mv ${GLUONDIR}/output/* ${IMAGEPATH}/${SITE}/${DATE} 

done

echo `date +%F-%H-%M` "FINISH" >> ${LOGFILE}
