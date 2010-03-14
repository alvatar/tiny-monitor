#!/bin/sh

xfbuild ../main.d +h +noop +full +cdmd +obin/monitor -I../../.. -I../../ -gc -debug -L-lncurses
if [[ `ls *di 2> /dev/null` ]]; then rm -R *di; fi;
