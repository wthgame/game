default:
    just lint-code lint-fmt

lint-code:
    bunx eslint -c ./eslint.config.ts ./src/**/*.ts
    selene ./src kit

lint-fmt:
    bunx prettier --check ./src
    stylua ./src ./kit -c ./stylua.toml --verify

fmt:
    bunx prettier --check ./src --write
    stylua ./src ./kit -c ./stylua.toml

watch-game:
    bunx rbxtsc --watch --project game.tsconfig.json --rojo game.project.json \
        & blink core.blink --watch \
        & blink game.blink --watch \
        & rojo serve game.project.json \
        & rojo sourcemap -o sourcemap.json game.project.json --watch --include-non-scripts

watch-kit:
    bunx rbxtsc --watch --project kit.tsconfig.json --rojo kit.project.json \
        & blink core.blink --watch \
        & blink kit.blink --watch \
        & rojo serve kit.project.json \
        & rojo sourcemap -o sourcemap.json kit.project.json --watch --include-non-scripts

sync-audios:
    lune run sync-audios

replace-comments:
    lune run replace-comments
