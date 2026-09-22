import os
import subprocess
import sys

import mod_env


def main(env=None):
	env = env or mod_env.main()
	game = env.game()

	plutonium = env.plutonium()
	bootstrapper = os.path.join(plutonium, "bin", "plutonium-bootstrapper-win32.exe")
	if not os.path.isfile(bootstrapper):
		env.die("no Plutonium bootstrapper at \"%s\"." % bootstrapper)

	subprocess.Popen([
		bootstrapper, "t6zm", game, "+name", env.player_name, "-lan",
		"+set", "fs_game", "mods/" + env.modfolder,
		"+set", "developer", "1",
		"+set", "developer_script", "1",
		"+set", "logfile", "2",
	], cwd=plutonium)

	print("Launched %s as %s (fs_game mods/%s)." % (env.modname, env.player_name, env.modfolder))
	return 0


if __name__ == "__main__":
	sys.exit(main(mod_env.main(sys.argv[1:])))
