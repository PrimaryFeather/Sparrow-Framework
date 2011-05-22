#!/bin/bash

# This script creates a nice API reference documentation for the Sparrow source
# and installs it in Xcode.
# 
# To execute it, you need the "AppleDoc"-tool. Download it here: 
# http://www.gentlebytes.com/home/appledocapp/

echo "Please enter the version number (like '1.0'), followed by [ENTER]:"
read version

appledoc \
  --project-name "Sparrow Framework" \
  --project-company "Gamua" \
  --company-id com.gamua \
  --project-version "$version" \
  --explicit-crossref \
  --ignore ".m" \
  --ignore "_Internal.h" \
  --keep-undocumented-objects \
  --keep-undocumented-members \
  --keep-intermediate-files \
  --no-warn-missing-arg \
  --no-warn-undocumented-object \
  --no-warn-undocumented-member \
  --no-warn-empty-description \
  --docset-bundle-id "org.sparrow-framework.docset" \
  --docset-bundle-name "Sparrow Framework API Documentation" \
  --docset-atom-filename "docset.atom" \
  --docset-feed-url "http://doc.sparrow-framework.org/core/feed/%DOCSETATOMFILENAME" \
  --docset-package-url "http://doc.sparrow-framework.org/core/feed/%DOCSETPACKAGEFILENAME" \
  --publish-docset \
  --output . \
  ../src/Classes

echo
echo "Finished."
