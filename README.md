# Welcome to Hell

![Welcome to Hell](./clickbait-thumbnail.png)

## Prerequisites

- Bun >1: <https://bun.sh/>
- Rokit >1: <https://github.com/rojo-rbx/rokit>
- Rojo plugin >7: <https://create.roblox.com/store/asset/13916111004>
- Git and Git experience

## Development

Installing toolchain:

```sh
rokit install
```

Installing packages:

```sh
bun i
```

Transpiling the project:

```sh
bun run dev
```

Serve the project:

```sh
rojo serve
```

Sync assets to Roblox Studio:

```sh
asphalt sync --target=studio
```

Generate network files:

```sh
blink blink
# this will run until u terminate the program:
blink blink --watch
```

Generate sourcemaps to have instance autocomplete in luau files:

```sh
rojo sourcemap -o sourcemap.json ./default.project.json --include-non-scripts
# this will run until u terminate the program:
rojo sourcemap -o sourcemap.json ./default.project.json --watch --include-non-scripts
```

Once served, open the project in Roblox Studio and sync the codebase.

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for
commit messages.

## Project Structure

- luau: Luau modules included in the project. This was kept out of the src
    folder to use rojo sourcemapping.

    - mechanics: maps to ReplicatedStorage.Mechanics.Core and is where the core
        mechanics are implemented

    - utils: maps to ReplicatedStorage.Lib and provides the types used
        in mechanic modules

- assets: Roblox assets included in the project.
- src: Source code for the project written in TypeScript.
- blink: Remote networking definition file.
