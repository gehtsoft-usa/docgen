#!/bin/bash

# Set docgen path
docgen="../.."

# Create destination directory
if [ ! -d "dst" ]; then
    mkdir -p dst
fi

# Clean destination directory
rm -rf dst/*

# Run docgen to generate markdown documentation
dotnet "$docgen/source/app/bin/Release/net80/docgen.dll" project.xml

echo "Documentation generated in dst/"
