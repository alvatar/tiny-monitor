#!/bin/sh

xfbuild ../main.d +h +noop +full +cdmd +obin/monitor -O -I../../.. -I../../ -L-lncurses
strip bin/monitor
if [[ `ls *di 2> /dev/null` ]]; then rm -R *di; fi;
