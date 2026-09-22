import os
import shutil
import subprocess
import sys
import uuid
import zipfile
from datetime import datetime, timezone

import mod_env

NOT_PACKED = ("zone_source", "materials")

LOADS = (
	"common_patch_mp.ff",
	"patch_mp.ff",
	"common_mp.ff",
	"code_post_gfx_mp.ff",
	"code_post_gfx.ff",
	"frontend.ff",
	"ui_mp.ff",
)


def stamp_build_id(env):
	path = os.path.join(env.source, "scripts", "zm", env.modfolder, "_zm_build_id.gsc")
	ident = str(uuid.uuid4())
	when = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
	with open(path, "w", encoding="utf-8", newline="\n") as handle:
		handle.write("build_id()\n{\n\treturn \"%s\";\n}\n\nbuild_time()\n{\n\treturn \"%s\";\n}\n" % (ident, when))
	print("      %s  %s" % (ident, when))


def check_scripts(env):
	tool = env.gsc_tool()

	scratch = os.path.join(os.environ.get("TEMP", "."), env.modfolder + "_check")
	shutil.rmtree(scratch, ignore_errors=True)
	os.makedirs(scratch)

	failed = []
	for base, _, files in os.walk(env.source):
		for name in sorted(f for f in files if f.endswith(".gsc")):
			path = os.path.join(base, name)
			copy = os.path.join(scratch, "check.gsc")
			shutil.copyfile(path, copy)
			run = subprocess.run([tool, "-m", "comp", "-g", "t6", "-s", "pc", "-y", copy], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
			if run.returncode != 0:
				failed.append(os.path.relpath(path, env.root))

	shutil.rmtree(scratch, ignore_errors=True)

	if failed:
		for path in failed:
			print("      FAILED: %s" % path)
		env.die("at least one script did not compile.")

	print("      scripts compiled clean.")


def pack_iwd(env):
	shutil.rmtree(env.build, ignore_errors=True)
	os.makedirs(env.build)
	shutil.copyfile(os.path.join(env.source, "mod.json"), os.path.join(env.build, "mod.json"))

	folders = sorted(d for d in os.listdir(env.source) if os.path.isdir(os.path.join(env.source, d)) and d not in NOT_PACKED)
	if not folders:
		env.die("nothing to pack.")

	with zipfile.ZipFile(os.path.join(env.build, "mod.iwd"), "w", zipfile.ZIP_DEFLATED) as archive:
		for folder in folders:
			count = 0
			for base, _, files in os.walk(os.path.join(env.source, folder)):
				for name in sorted(files):
					path = os.path.join(base, name)
					archive.write(path, os.path.relpath(path, env.source).replace(os.sep, "/"))
					count += 1
			print("      %-10s %d file(s)" % (folder, count))


def link_fastfile(env):
	linker = env.linker()
	game = env.game()

	command = [linker]
	for name in LOADS:
		command += ["--load", os.path.join(game, "zone", "all", name)]
	command += [
		"--base-folder", env.oat_base,
		"--add-asset-search-path", env.source,
		"--add-source-search-path", os.path.join(env.source, "zone_source"),
		"--output-folder", env.build,
		"mod",
	]

	if subprocess.run(command).returncode != 0:
		env.die("the linker failed on mod.zone.")

	out = os.path.join(env.build, "mod.ff")
	if not os.path.isfile(out):
		env.die("mod.ff not there after a successful link report.")
	if os.path.getsize(out) == 0:
		env.die("mod.ff is 0 bytes, the link failed. Search the output above for \"ERROR:\".")


def main(env=None):
	env = env or mod_env.main()

	if not os.path.isfile(os.path.join(env.source, "mod.json")):
		env.die("no mod.json at \"%s\"." % os.path.join(env.source, "mod.json"))

	env.step(1, 4, "Stamping build id...")
	stamp_build_id(env)

	env.step(2, 4, "Checking scripts...")
	check_scripts(env)

	env.step(3, 4, "Packing mod.iwd...")
	pack_iwd(env)

	env.step(4, 4, "Linking mod.ff...")
	link_fastfile(env)

	print("\nBuilt %s into \"%s\"." % (env.modname, env.build))
	return 0


if __name__ == "__main__":
	sys.exit(main(mod_env.main(sys.argv[1:])))
