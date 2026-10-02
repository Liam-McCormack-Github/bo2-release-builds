main()
{ }

init()
{
	println("^2mod_to_launch_mp_maps_in_zombies: build " + scripts\zm\mod_to_launch_mp_maps_in_zombies\_zm_build_id::build_id());

	level thread scripts\zm\mod_to_launch_mp_maps_in_zombies\_zm_commands::command_watcher();
}
