#!/bin/sh

BASENAME=dlscripts-0.1.1

tar -cvf $BASENAME.tar scripts/
bzip2 --keep --best -v $BASENAME.tar
gzip --best --verbose $BASENAME.tar
zip -9 -v -r $BASENAME.zip scripts/*
