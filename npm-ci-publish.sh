#!/bin/sh

sed -i -e "s/version\": \"0.0.0\"/version\": \"$VERSION\"/g" package.json
sed -i -e "s/version\": \"0.0.0\"/version\": \"$VERSION\"/g" package-lock.json
sed -i -e "s/version\": \"0.0.0\"/version\": \"$VERSION\"/g" plugin.xml

echo "//registry.npmjs.org/:_authToken=$NPM_AUTH_TOKEN" > .npmrc
npm publish 
rm .npmrc