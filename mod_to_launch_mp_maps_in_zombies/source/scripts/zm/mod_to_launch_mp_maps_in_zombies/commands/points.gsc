#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;

run(arg)
{
	if (!scripts\zm\mod_to_launch_mp_maps_in_zombies\commands\utility::is_integer_string(arg))
	{
		println("^3zm points: ^1" + arg + " is not a number");
		return;
	}

	value = int(arg);
	players = get_players();

	foreach (player in players)
	{
		player set_player_points(value);
	}
}


set_player_points(points)
{
	if (points < 0)
	{
		points = 0;
	}

	if (!isDefined(self.score))
	{
		return;
	}

	difference = points - self.score;

	if (difference > 0)
	{
		self maps\mp\zombies\_zm_score::add_to_player_score(difference, 0);
	}
	else if (difference < 0)
	{
		self maps\mp\zombies\_zm_score::minus_to_player_score(difference * -1, 1);
	}
}
