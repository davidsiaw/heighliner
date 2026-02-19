#!/bin/bash

rm -rf build
rm -rf gittemp

echo "This document has been deployed to https://davidsiaw.github.io/heighliner$ROOT_DIR"

git clone git@github.com:davidsiaw/heighliner gittemp
pushd gittemp
git checkout gh-pages
popd
weaver build --root "https://davidsiaw.github.io/heighliner$ROOT_DIR"
rm -rf build/js/MathJax
echo "Making dir gittemp$ROOT_DIR"
mkdir -p "gittemp$ROOT_DIR"
cp -r build/* "gittemp$ROOT_DIR"
pushd gittemp
rm -rf js/MathJax
git add .
git add -u
git commit -m "update"
git push
popd
