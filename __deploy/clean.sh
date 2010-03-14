#!/bin/sh

if [[ -a .objs ]]; then rm -R .objs; fi;
if [[ -a .deps ]]; then rm -R .deps; fi;
if [[ `ls xfbuild* 2> /dev/null` ]]; then rm -R xfbuild*; fi;
if [[ `ls *di 2> /dev/null` ]]; then rm -R *di; fi;
if [[ -a bin/Monitor ]]; then rm -R bin/Monitor; fi
