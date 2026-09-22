import argparse
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class ModEnv:

	MODFOLDER = "mod_to_launch_mp_maps_in_zombies"
	MODNAME = "Mod to launch MP Maps in Zombies"

	def __init__(self, root, oat_base="", oat_game="", gsc_tool="", player_name="", plutonium_dir=""):
		self.root = root
		self.source = os.path.join(root, "source")
		self.build = os.path.join(root, "build", "mods", self.MODFOLDER)
		self.modfolder = self.MODFOLDER
		self.modname = self.MODNAME

		self.oat_base = oat_base
		self.oat_game = oat_game
		self.gsc_tool_path = gsc_tool
		self.player_name = player_name
		self.plutonium_dir = plutonium_dir

	def linker(self):
		return self._tool("--oat-base", self.oat_base, "Linker.exe", "mod.zone needs the linker")

	def gsc_tool(self):
		return self._tool("--gsc-tool", self.gsc_tool_path, None, "the scripts cannot be checked without it")

	def game(self):
		if not self.oat_game:
			self.die("--oat-game is empty, and the linker reads the stock fastfiles while Plutonium runs the install itself. Set OAT_GAME in .env.")
		if not os.path.isdir(self.oat_game):
			self.die("--oat-game points at \"%s\", which does not exist." % self.oat_game)
		return self.oat_game

	def plutonium(self):
		if self.plutonium_dir:
			if not os.path.isdir(self.plutonium_dir):
				self.die("--plutonium-dir points at \"%s\", which does not exist." % self.plutonium_dir)
			return self.plutonium_dir
		local = os.environ.get("LOCALAPPDATA")
		if not local:
			self.die("LOCALAPPDATA is not set, so set PLUTONIUM_DIR in .env instead.")
		return os.path.join(local, "Plutonium")

	def mods_dir(self):
		return os.path.join(self.plutonium(), "storage", "t6", "mods", self.modfolder)

	def _tool(self, flag, value, exe, why):
		if not value:
			self.die("%s is empty, and %s. Set it in .env." % (flag, why))
		path = os.path.join(value, exe) if exe else value
		if not os.path.isfile(path):
			self.die("%s does not resolve to a file, \"%s\" is not there." % (flag, path))
		return path

	def step(self, n, total, text):
		print("[%d/%d] %s" % (n, total, text))

	def die(self, message):
		sys.stderr.write("ERROR: %s\n" % message)
		sys.exit(1)


def parse(argv=None):
	parser = argparse.ArgumentParser(add_help=False)
	parser.add_argument("--oat-base", default="")
	parser.add_argument("--oat-game", default="")
	parser.add_argument("--gsc-tool", default="")
	parser.add_argument("--player-name", default="")
	parser.add_argument("--plutonium-dir", default="")
	args, rest = parser.parse_known_args(argv)

	env = ModEnv(
		ROOT,
		args.oat_base or os.environ.get("OAT_BASE", ""),
		args.oat_game or os.environ.get("OAT_GAME", ""),
		args.gsc_tool or os.environ.get("GSC_TOOL", ""),
		args.player_name or os.environ.get("PLAYER_NAME", ""),
		args.plutonium_dir or os.environ.get("PLUTONIUM_DIR", ""),
	)
	return env, rest


def main(argv=None):
	return parse(argv)[0]


if __name__ == "__main__":
	env = main(sys.argv[1:])
	print("%s  ->  mods\\%s" % (env.modname, env.modfolder))
	for flag, value in (("--oat-base", env.oat_base), ("--oat-game", env.oat_game), ("--gsc-tool", env.gsc_tool_path), ("--player-name", env.player_name), ("--plutonium-dir", env.plutonium_dir or "(LOCALAPPDATA)")):
		print("  %-16s %s" % (flag, value or "(empty)"))
