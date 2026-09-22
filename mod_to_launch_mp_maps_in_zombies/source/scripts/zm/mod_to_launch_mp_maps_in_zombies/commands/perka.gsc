#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

run()
{
	player = scripts\zm\mod_to_launch_mp_maps_in_zombies\commands\utility::get_command_player();

	if (isDefined(player))
	{

		player thread give_every_perk();
	}
}


give_every_perk()
{
	if (!isDefined(level._random_perk_machine_perk_list))
	{
		println("^3zm perka: ^1der wunderfizz has not built its rotation yet");
		return;
	}

	foreach (perk in level._random_perk_machine_perk_list)
	{
		if (!self hasperk(perk))
		{
			self maps\mp\zombies\_zm_perks::give_perk(perk, 0);
		}

		wait 0.25;
	}

	self iprintln("^3zm perka ^7gave " + level._random_perk_machine_perk_list.size + " perks");
}
