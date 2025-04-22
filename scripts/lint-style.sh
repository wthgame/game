#!/usr/bin/env bash

bunx prettier --check ./src
stylua ./src ./mechanics -c ./stylua.toml
