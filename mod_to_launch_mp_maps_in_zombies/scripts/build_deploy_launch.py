import sys

import build
import deploy
import launch
import mod_env


def main(argv=None):
	env = mod_env.main(argv)

	for step in (build.main, deploy.main, launch.main):
		if step(env) != 0:
			return 1

	return 0


if __name__ == "__main__":
	sys.exit(main(sys.argv[1:]))
