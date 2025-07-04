# WELCOME TO HELL IS GOING THROUGH AN ORGANIZATIONAL REWRITE. WE DO NOT PLAN ON SUPPORTING THIS KIT, BUT WOULD RATHER LIKE TO SHOW THE WORLD WHAT WE HAVE COOKED. WELCOME TO HELL ON TOP

<div align="center">
    <img src="/assets/images/logo.png" alt="Welcome To Hell Logo" />
    <h1>Welcome To Hell</h1>
</div>

Welcome To Hell wins the award for Most Schizophrenic Codebase!

Runner ups are Eternal Towers of Hell v6.

## Acknowledgements

Some KitObjects references Eternal Towers of Hell Kit v6, Obren's Towers of Hell
v3, Eternal Towers of Hell v5, and Total Fire Towers v2.

## Environment Setup

Gurt: What you're doing is very smart but also very dangerous. (to your mental
health)

### Prerequisites

* Lack of sanity
* Solid experience with Luau, including it's type system, especially needed for
    writing KitObjects: <https://luau.org/getting-started>
* Knowledge of TypeScript and the roblox-ts compiler, especially needed for
    writing the game's backend or UI: <https://roblox-ts.com/>

### For MacOS

TODO

### For Windows

#### Terms

| Term | Explanation |
|------|-------------|
| Start Powershell | https://learn.microsoft.com/en-us/powershell/scripting/windows-powershell/starting-windows-powershell?view=powershell-7.5 (You can use an existing Powershell window) |
| Restart Powershell | Close Powershell and then Start Powershell |
| Open Powershell | Start Powershell |
| Open New Window Terminal | https://learn.microsoft.com/en-us/windows/terminal/install#open-a-new-tab |

#### Setup

[Getting Rokit](https://github.com/rojo-rbx/rokit):
1. Start Powershell
2. Run this command

    ```
    Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | Invoke-Expression
    ```

3. Open New Window Terminal OR Restart Powershell
4. Run this command: `rokit -V` and confirm it says something like `rokit 1.0.0`. If you get an error, you fucked up

[Getting Bun](https://bun.sh/)

1. Open Powershell
2. Run this command

    ```sh
    powershell -c "irm bun.sh/install.ps1 | iex"
    ```

3. Open New Window Terminal OR Restart Powershell
4. Run this command: `bun -v` and confirm it says something like `1.2.2`. If you get an error, you fucked up

[Then, install Git](https://www.youtube.com/watch?v=iYkLrXobBbA)

[Then, install VSCode](https://code.visualstudio.com/)

Get Luau LSP for VSCode: <https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.luau-lsp>

Make a new folder for Welcome To Hell's Game.

Open it in VSCode. Should be obvious.

`Ctrl+Shift+P` and search/then select "Terminal: Create New Terminal"

Run these commands in that terminal line by line in order:

```sh
git init

git pull https://github.com/wthgame/game.git

git remote add origin https://github.com/wthgame/game.git

rokit install

bun install
```

Restart your code editor so all the editor tools can take in what insanity you
just did.

`Ctrl+Shift+P` and search/then select "Terminal: Create New Terminal".

Verify everything else by Rokit is installed:

```sh
rojo -V
lune -V
```

Install Rojo plugin:

```sh
rojo plugin install
```

Restart your code editor so all the editor tools can take in what insanity you
just did.

### Developing

When new versions are pushed, do this:

```sh
git pull origin main
```

You may often download other dependencies as you work, or need to reinstall it.

You can run this again:

```sh
bun i
```

To sync the project, make a terminal in your editor and run this:

```sh
lune run sync
```

Use arrow keys to pick the target to sync to and press enter to select.

Open the game in Studio. If you installed Rojo correctly, a new `Rojo` plugin
should be there. Click it, and a new panel appears. Click "Connect".

You may be prompted to accept the sync. Just accept it.

If everything works, GG gamer you can now start developing

You will repeat this lots of time for when you need to sync in the codebase to
Roblox Studio.

When you want to sync assets in `assets` and `audios` run
`asphalt run --target=studio`. This just copies over the image/sound asset files
to Studio without actually uploading them.

You may want to use the following resources:

* Roblox Open Source server: <https://discord.gg/VaDCnesCXj>
* roblox-ts server: <https://discord.gg/cMACFmHS7G>
* Rojo: <https://rojo.space/>

## Structure

### `kit`

Contains the user code for the Kit which includes the standard library
(utilities to make client objects) and KitObjects.

* `kit/scripts/Core`: Core KitObjects such as `Button` that is included in the Kit and the main game
* `kit/scripts/Internal`: Internal KitObjects such as `TowerPortal` only synced into the main game
* `kit/std`: Standard library for all KitScripts to use

Read through the KitObjects to know what you should cook up.

Technical documentation is auto generated by a script, see the `kit/core/Modifiers/LimitActivations.luau` for an example

### `src`

Backend code written in TypeScript. Split into `core`, `game`, and `kit`.

* `src/core` contains core code shared between both the game and the Kit
* `src/game` contains game code only synced to the main game
* `src/kit` contains standalone Kit code only synced to the Kit development place

Each of these folders have three folders: `client`, `shared`, and `server`.

These map to client code (`WTHClientX`), shared code both in ReplicatedStorage
(`WTHSharedX`) and server code in ServerScriptService (`WTHServerX`)

My advise is to just sync in the game and look at the explorer.

Networking definitions are in `game.blink` and `kit.blink` and `core.blink`
these will generate to `net.luau` client/server files in the `core`, `game`, and
`kit` folders. Read <https://1axen.github.io/blink> for more info.

If you have questions feel free to ask me znotfireman :))
