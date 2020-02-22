#!/bin/bash

mkdir out

for f in *.pdf
do
    ocrmypdf $f "out/$f"
done