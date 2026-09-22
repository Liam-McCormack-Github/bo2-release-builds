# mod_to_launch_mp_maps_in_zombies

This is a simple mod for loading BO2 multiplayer maps that have been ported into BO2 zombies. It ships **almost no gameplay modifications at all**: the maps carry their own scripts and their own assets.

Plutonium currently requires any mod to be active to launch a custom usermap. **This mod is not required to launch the ported maps**.

This mod modifies the main menu adding buttons to launch the usermaps through a menu rather than via console commands.

This mod ships art and localisation for loading screens.

This mod ships with `sv_cheats 1` and a custom command listener which are set via `set zm_cmd [custom command]`.

## Building

Change `.env.template` to `.env` and fill in the necessary variables.
Then run `zz_build.bat` and then you can copy those content of the build directory into your `~\AppData\Local\Plutonium\storage\t6\mods` directory.

## Bugs

Raise an issue on the monorepo github.

## Disclaimer

Partially developed with generative ai.
