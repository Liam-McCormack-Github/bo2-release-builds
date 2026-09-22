import os
import shutil
import sys

import mod_env

FILES = ("mod.json", "mod.iwd", "mod.ff")


def main(env=None, dest=None):
	env = env or mod_env.main()

	if not os.path.isfile(os.path.join(env.build, "mod.iwd")):
		env.die("no mod.iwd at \"%s\". Run zz_build.bat first." % env.build)

	dest = dest or env.mods_dir()
	os.makedirs(dest, exist_ok=True)

	for name in FILES:
		source = os.path.join(env.build, name)
		if not os.path.isfile(source):
			continue
		try:
			shutil.copyfile(source, os.path.join(dest, name))
		except PermissionError:
			env.die("could not write %s, quit the game and run this again." % name)
		print("      %s" % name)

	print("Deployed to \"%s\"" % dest)
	return 0


if __name__ == "__main__":
	env, rest = mod_env.parse(sys.argv[1:])
	sys.exit(main(env, dest=rest[0] if rest else None))
