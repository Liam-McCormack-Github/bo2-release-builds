# BO2 Multiplayer Maps in Zombies (Beta Release)

Pre-built ports of Call of Duty: Black Ops II multiplayer maps for Zombies mode. The ported maps carry their own scripts and assets and include almost no gameplay modifications.

---

## Installation

1. **Install Maps**: Copy the `usermaps` directory into your Plutonium directory, typically located at:
   `~\\AppData\\Local\\Plutonium\\storage\\t6`
2. **Install Menu Mod (Optional)**: If you are using the optional menu launcher mod, copy its files into:
   `~\\AppData\\Local\\Plutonium\\storage\\t6\\mods`

---

## Launching Maps

### Console Launch (No Menu Mod Required)

- Plutonium currently requires **any mod** to be active to launch a custom usermap.
- **The launcher mod is not required to play these maps**.
- To launch a map via the console, ensure any mod is loaded and run: `g_gametype zstandard;map zm_{{map name}}`

_(Replace `{{map name}}` with the console name listed below)._

### Optional Menu Launcher Mod Features

If you choose to install the included launcher mod:

- Modifies the main menu to add buttons for launching usermaps directly without typing console commands.
- Adds custom art and localisation for loading screens.
- Ships with `sv_cheats 1` enabled and a custom command listener configured via `set zm_cmd [custom command]`.

---

## Bugs???

This is in early beta. Please create a issue on my github:

- [My Github](https://github.com/Liam-McCormack-Github/bo2-release-builds)

---

## Map List & Console Commands

The console names for all ported maps are listed below:

| Map           | Console Name       | Console Command                             |
| :------------ | :----------------- | :------------------------------------------ |
| Aftermath     | `zm_la`            | `g_gametype zstandard;map zm_la`            |
| Cargo         | `zm_dockside`      | `g_gametype zstandard;map zm_dockside`      |
| Carrier       | `zm_carrier`       | `g_gametype zstandard;map zm_carrier`       |
| Cove          | `zm_castaway`      | `g_gametype zstandard;map zm_castaway`      |
| Detour        | `zm_bridge`        | `g_gametype zstandard;map zm_bridge`        |
| Dig           | `zm_dig`           | `g_gametype zstandard;map zm_dig`           |
| Downhill      | `zm_downhill`      | `g_gametype zstandard;map zm_downhill`      |
| Drone         | `zm_drone`         | `g_gametype zstandard;map zm_drone`         |
| Encore        | `zm_concert`       | `g_gametype zstandard;map zm_concert`       |
| Express       | `zm_express`       | `g_gametype zstandard;map zm_express`       |
| Frost         | `zm_frostbite`     | `g_gametype zstandard;map zm_frostbite`     |
| Grind         | `zm_skate`         | `g_gametype zstandard;map zm_skate`         |
| Hijacked      | `zm_hijacked`      | `g_gametype zstandard;map zm_hijacked`      |
| Hydro         | `zm_hydro`         | `g_gametype zstandard;map zm_hydro`         |
| Magma         | `zm_magma`         | `g_gametype zstandard;map zm_magma`         |
| Meltdown      | `zm_meltdown`      | `g_gametype zstandard;map zm_meltdown`      |
| Mirage        | `zm_mirage`        | `g_gametype zstandard;map zm_mirage`        |
| Nuketown 2025 | `zm_nuketown_2020` | `g_gametype zstandard;map zm_nuketown_2020` |
| Overflow      | `zm_overflow`      | `g_gametype zstandard;map zm_overflow`      |
| Plaza         | `zm_nightclub`     | `g_gametype zstandard;map zm_nightclub`     |
| Pod           | `zm_pod`           | `g_gametype zstandard;map zm_pod`           |
| Raid          | `zm_raid`          | `g_gametype zstandard;map zm_raid`          |
| Rush          | `zm_paintball`     | `g_gametype zstandard;map zm_paintball`     |
| Slums         | `zm_slums`         | `g_gametype zstandard;map zm_slums`         |
| Standoff      | `zm_village`       | `g_gametype zstandard;map zm_village`       |
| Studio        | `zm_studio`        | `g_gametype zstandard;map zm_studio`        |
| Takeoff       | `zm_takeoff`       | `g_gametype zstandard;map zm_takeoff`       |
| Turbine       | `zm_turbine`       | `g_gametype zstandard;map zm_turbine`       |
| Uplink        | `zm_uplink`        | `g_gametype zstandard;map zm_uplink`        |
| Vertigo       | `zm_vertigo`       | `g_gametype zstandard;map zm_vertigo`       |
| Yemen         | `zm_socotra`       | `g_gametype zstandard;map zm_socotra`       |

---

## Disclaimer

Partially developed with generative AI.
