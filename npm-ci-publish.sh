#!/bin/sh

echo "//registry.npmjs.org/:_authToken=$NPM_AUTH_TOKEN" > .npmrc
npm publish 
rm .npmrc