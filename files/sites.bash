#!/bin/bash

GITNIERS=https://github.com/ffniers/site-ffniers
GITMO=https://github.com/ffniers/site-ffmo
GITMG=https://github.com/ffniers/site-ffmg

rm -rf ~/site/2016
mkdir -p ~/site/2016
rm -rf ~/site/2017
mkdir -p ~/site/2017

git clone ${GITNIERS} ~/site/2016/niers
cd ~/site/2016/niers
git checkout 2016.2-l2tp
git pull

#---

git clone ${GITMO} ~/site/2016/mo
cd ~/site/2016/mo
git checkout 2016.2-l2tp
git pull

#---

git clone ${GITMG} ~/site/2016/mg
cd ~/site/2016/mg
git checkout 2016.2-l2tp
git pull

#===

git clone ${GITNIERS} ~/site/2017/niers
cd ~/site/2017/niers
git checkout 2017.1.5
git pull


