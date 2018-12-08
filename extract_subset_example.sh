#!/bin/bash
pip install fonttools brotli
pyftsubset "IropkeBatangM.ttf" --flavor=$flavor --output-file="IropkeBatangMSubset.ttf" --text-file="../glyphs.txt" --unicodes="U+2603,U+E000,U+E001" --layout-features='*'   --glyph-names --symbol-cmap --legacy-cmap --notdef-glyph --notdef-outline   --recommended-glyphs --name-IDs='*' --name-legacy --name-languages='*' --drop-tables=

