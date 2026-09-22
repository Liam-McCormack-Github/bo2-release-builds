#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

run(arg)
{
	if (!scripts\zm\mod_to_launch_mp_maps_in_zombies\commands\utility::is_integer_string(arg))
	{
		println("^3zm round: ^1" + arg + " is not a number");
		return;
	}

	set_round(int(arg));
}


set_round(round)
{
	if (round < 1)
	{
		round = 1;
	}

	level.zombie_total = 0;

	zombies = getaispeciesarray(level.zombie_team, "all");

	foreach (zombie in zombies)
	{
		if (isAlive(zombie))
		{
			zombie dodamage(zombie.health + 1000, zombie.origin);
		}
	}

	level.round_number = round - 1;
	wind_spawn_delay(level.round_number);
}


wind_spawn_delay(n_rounds_played)
{

	delay = 2.0;

	for (i = 1; i < n_rounds_played; i++)
	{
		if (delay > 0.08)
		{
			delay = delay * 0.95;
		}
		else if (delay < 0.08)
		{
			delay = 0.08;
		}
	}

	level.zombie_vars["zombie_spawn_delay"] = delay;
}
