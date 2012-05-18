/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	required_players = 3
	required_enemies = 2
	recommended_enemies = 5

	uplink_welcome = "Corporate Backed Uplink Console:"
	uplink_uses = 40

	var/const/agents_possible = 5 //If we ever need more syndicate agents.
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/nukes_left = 1 // Call 3714-PRAY right now and order more nukes! Limited offer!
	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/herp = 0 //Used for tracking if the syndies got the shuttle off of the z-level
	//It is so hillarious so I wont rename those two variables --rastaf0


/datum/game_mode/nuclear/announce()
	world << "<B>The current game mode is - Nuclear Emergency!</B>"
	world << "<B>A [syndicate_name()] Strike Force is approaching [station_name()]!</B>"
	world << "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!"

/datum/game_mode/nuclear/can_start()//This could be better, will likely have to recode it later
	if(!..())
		return 0

	var/list/possible_syndicates = get_players_for_role(BE_OPERATIVE)
	var/agent_number = 0

	syndicate_begin()

	if(possible_syndicates.len < 1)
		return 0

	if(possible_syndicates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = possible_syndicates.len

	var/n_players = num_players()
	if(agent_number > (n_players - agent_number))
		agent_number = (n_players - agent_number)/2
	if(agent_number < required_enemies)
		agent_number  = required_enemies

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(possible_syndicates)
		syndicates += new_syndicate
		possible_syndicates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.
		synd_mind.special_role = "Syndicate"//So they actually have a special role/N
	return 1


/datum/game_mode/nuclear/pre_setup()
	return 1


/datum/game_mode/nuclear/post_setup()
	var/obj/effect/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
	var/obj/effect/landmark/closet_spawn = locate("landmark*Nuclear-Closet")

	var/nuke_code = "[rand(10000, 99999)]"
	var/leader_selected = 0
	var/freq = random_radio_frequency()
	radiochannels += list("Nuclear" = freq)
	NUKE_FREQ = freq
	//var/agent_number = 1

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.current.loc = get_turf(synd_spawn)

		forge_syndicate_objectives(synd_mind)
		greet_syndicate(synd_mind)


		if(!leader_selected)
			prepare_syndicate_leader(synd_mind, nuke_code)
			leader_selected = 1
/*		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++*/

		equip_syndicate(synd_mind.current,freq)
		update_synd_icons_added(synd_mind)

	update_all_synd_icons()

	if(nuke_spawn)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	if(closet_spawn)
		new /obj/structure/closet/syndicate/nuclear(closet_spawn.loc)

	for (var/obj/effect/landmark/A in world)
		if (A.name == "Syndicate-Gear-Closet")
			new /obj/structure/closet/syndicate/personal(A.loc)
			del(A)
			continue

		if (A.name == "Syndicate-Bomb")
			new /obj/effect/spawner/newbomb/timer/syndicate(A.loc)
			del(A)
			continue

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

	return ..()


/datum/game_mode/nuclear/check_win()
	if (nukes_left == 0)
		return 1
	return ..()


/datum/game_mode/nuclear/declare_completion()
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in world)
		var/disk_area = get_area(D)
		if(!is_type_in_list(disk_area, centcom_areas))
			disk_rescued = 0
			break
	var/crew_evacuated = (emergency_shuttle.location==2)
	//var/operatives_are_dead = is_operatives_are_dead()


	//nukes_left
	//station_was_nuked
	//derp //Used for tracking if the syndies actually haul the nuke to the station
	//herp //Used for tracking if the syndies got the shuttle off of the z-level

	if      (!disk_rescued &&  station_was_nuked &&          !herp)
		feedback_set_details("round_end_result","win - syndicate nuke")
		world << "<FONT size = 3><B>Syndicate Major Victory!</B></FONT>"
		world << "<B>[syndicate_name()] operatives have destroyed [station_name()]!</B>"

	else if (!disk_rescued &&  station_was_nuked &&           herp)
		feedback_set_details("round_end_result","halfwin - syndicate nuke - did not evacuate in time")
		world << "<FONT size = 3><B>Total Annihilation</B></FONT>"
		world << "<B>[syndicate_name()] operatives destroyed [station_name()] but did not leave the area in time and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station && !herp)
		feedback_set_details("round_end_result","halfwin - blew wrong station")
		world << "<FONT size = 3><B>Crew Minor Victory</B></FONT>"
		world << "<B>[syndicate_name()] operatives secured the authentication disk but blew up something that wasn't [station_name()].</B> Next time, don't lose the disk!"

	else if (!disk_rescued && !station_was_nuked &&  nuke_off_station &&  herp)
		feedback_set_details("round_end_result","halfwin - blew wrong station - did not evacuate in time")
		world << "<FONT size = 3><B>[syndicate_name()] operatives have earned Darwin Award!</B></FONT>"
		world << "<B>[syndicate_name()] operatives blew up something that wasn't [station_name()] and got caught in the explosion.</B> Next time, don't lose the disk!"

	else if ( disk_rescued                                         && is_operatives_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk secured - syndi team dead")
		world << "<FONT size = 3><B>Crew Major Victory!</B></FONT>"
		world << "<B>The Research Staff has saved the disc and killed the [syndicate_name()] Operatives</B>"

	else if ( disk_rescued                                        )
		feedback_set_details("round_end_result","loss - evacuation - disk secured")
		world << "<FONT size = 3><B>Crew Major Victory</B></FONT>"
		world << "<B>The Research Staff has saved the disc and stopped the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued                                         && is_operatives_are_dead())
		feedback_set_details("round_end_result","loss - evacuation - disk not secured")
		world << "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>"
		world << "<B>The Research Staff failed to secure the authentication disk but did manage to kill most of the [syndicate_name()] Operatives!</B>"

	else if (!disk_rescued                                         &&  crew_evacuated)
		feedback_set_details("round_end_result","halfwin - detonation averted")
		world << "<FONT size = 3><B>Syndicate Minor Victory!</B></FONT>"
		world << "<B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!"

	else if (!disk_rescued                                         && !crew_evacuated)
		feedback_set_details("round_end_result","halfwin - interrupted")
		world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
		world << "<B>Round was mysteriously interrupted!</B>"

	..()
	return


