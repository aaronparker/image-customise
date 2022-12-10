VERSION=`cat ./src/VERSION.txt`
if [ -z "$VERSION" ]; then echo "VERSION not set"; else git tag v$VERSION; git push origin --tags; fi
