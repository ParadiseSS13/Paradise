#!/bin/bash
# Clear out old folder
rm -rf docs
# Generate documentation
tools/github-actions/doc-generator
# Rename the folder to be GitHub pages compatible
mv dmdoc docs
