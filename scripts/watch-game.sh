#!/usr/bin/env bash

bunx rbxtsc --watch --project game.tsconfig.json --rojo game.project.json \
    & blink core.blink --watch \
    & blink game.blink --watch \
    & rojo serve game.project.json \
    & rojo sourcemap -o sourcemap.json game.project.json --watch --include-non-scripts
