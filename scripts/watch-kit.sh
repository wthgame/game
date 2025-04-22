#!/usr/bin/env bash

bunx rbxtsc --watch --project kit.tsconfig.json --rojo kit.project.json \
    & blink core.blink --watch \
    & blink kit.blink --watch \
    & rojo serve kit.project.json \
    & rojo sourcemap -o sourcemap.json kit.project.json --watch --include-non-scripts
