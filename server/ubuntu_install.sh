#!/bin/bash
npm install
npm install profiler
pushd dag
npm install
popd
pushd ..
npm install jade
popd
