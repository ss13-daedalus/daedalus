/*
 * GAMEMODES (by Rastaf0)
 *
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 *
 */


/datum/game_mode
	var
		name = "invalid"
		config_tag = null
		intercept_hacked = 0
		votable = 1
		probability = 1
		station_was_nuked = 0 //see nuclearbomb.dm and malfunction.dm
		explosion_in_progress = 0 //sit back and relax
		list/datum/mind/modePlayer = new
		list/restricted_jobs = list()	// Jobs it doesn't make sense to be.  I.E chaplain or AI cultist
		list/protected_jobs = list()	// Jobs that can't be tratiors because
		required_players = 1
		required_enemies = 0
		recommended_enemies = 0
		uplink_welcome
		uplink_uses
		uplink_items = {"Highly Visible and Dangerous Weapons;
/obj/item/weapon/gun/projectile:6:Revolver;
/obj/item/ammo_magazine/a357:2:Ammo-357;
/obj/item/weapon/gun/energy/crossbow:5:Energy Crossbow;
/obj/item/weapon/melee/energy/sword:4:Energy Sword;
/obj/item/weapon/storage/box/syndicate:10:Syndicate Bundle;
/obj/item/weapon/storage/emp_kit:3:5 EMP Grenades;
Whitespace:Seperator;
Stealthy and Inconspicuous Weapons;
/obj/item/weapon/pen/sleepypen:3:Sleepy Pen;
/obj/item/weapon/soap/syndie:1:Syndicate Soap;
/obj/item/weapon/cartridge/syndicate:3:Detomatix PDA Cartridge;
Whitespace:Seperator;
Stealth and Camouflage Items;
/obj/item/clothing/under/chameleon:4:Chameleon Jumpsuit, with armor.;
/obj/item/clothing/shoes/syndigaloshes:2:No-Slip Syndicate Shoes;
/obj/item/weapon/card/id/syndicate:3:Agent ID card;
/obj/item/clothing/mask/gas/voice:4:Voice Changer;
/obj/item/clothing/glasses/thermal:4:Thermal Imaging Glasses;
/obj/item/device/chameleon:4:Chameleon-Projector;
/obj/item/weapon/stamp_eraser:1:Stamp Remover;
Whitespace:Seperator;
Devices and Tools;
/obj/item/weapon/card/emag:4:Cryptographic Sequencer (Limited uses, almost full access);
/obj/item/device/hacktool:3:Hacktool (Slow, but stealthy.  Unlimited uses);
/obj/item/weapon/storage/toolbox/syndicate:1:Fully Loaded Toolbox;
/obj/item/device/encryptionkey/traitor:3:Traitor Radio Key;
/obj/item/device/encryptionkey/binary:3:Binary Translator Key;
/obj/item/weapon/storage/syndie_kit/space:3:Space Suit;
/obj/item/weapon/ai_module/syndicate:7:Hacked AI Upload Module;
/obj/item/weapon/plastique:2:C-4 (Destroys walls);
/obj/item/weapon/syndie/c4explosive:4:Low Power Explosive Charge, with Detonator;
/obj/item/device/powersink:5:Powersink (DANGER!);
/obj/machinery/singularity_beacon/syndicate:7:Singularity Beacon (DANGER!);
/obj/item/weapon/circuitboard/teleporter:10:Teleporter Circuit Board;
Whitespace:Seperator;
Implants;
/obj/item/weapon/storage/syndie_kit/imp_freedom:3:Freedom Implant;
/obj/item/weapon/storage/syndie_kit/imp_compress:5:Compressed Matter Implant;
/obj/item/weapon/storage/syndie_kit/imp_explosive:6:Explosive Implant;
/obj/item/weapon/storage/syndie_kit/imp_uplink:10:Uplink Implant (Contains 5 Telecrystals);
Whitespace:Seperator;
Badassery;
/obj/item/toy/syndicateballoon:10:For showing that You Are The BOSS (Useless Balloon);
Whitespace:Seperator;"}

// Items removed from above:
/*
/obj/item/weapon/syndie/c4explosive/heavy:7:High (!) Power Explosive Charge, with Detonator;
/obj/item/weapon/cloaking_device:4:Cloaking Device;	//Replacing cloakers with thermals.	-Pete
*/

/datum/game_mode/proc/announce() //to be calles when round starts
	world << "<B>Notice</B>: [src] did not define announce()"


///can_start()
///Checks to see if the game can be setup and ran with the current number of players or whatnot.
/datum/game_mode/proc/can_start()
	var/playerC = 0
	for(var/mob/new_player/player in world)
		if((player.client)&&(player.ready))
			playerC++
	if(playerC >= required_players)
		return 1
	return 0


///pre_setup()
///Attempts to select players for special roles the mode might have.
/datum/game_mode/proc/pre_setup()
	return 1


///post_setup()
///Everyone should now be on the station and have their normal gear.  This is the place to give the special roles extra things
/datum/game_mode/proc/post_setup()
	feedback_set_details("round_start","[time2text(world.realtime)]")
	if(ticker && ticker.mode)
		feedback_set_details("game_mode","[ticker.mode]")
	feedback_set_details("server_ip","[world.internet_address]")
	return 1


///process()
///Called by the gameticker
/datum/game_mode/proc/process()
	return 0


/datum/game_mode/proc/check_finished() //to be called by ticker
	if(emergency_shuttle.location==2 || station_was_nuked)
		return 1
	return 0


/datum/game_mode/proc/declare_completion()
	var/clients = 0
	var/surviving_humans = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/escaped_humans = 0
	var/escaped_total = 0
	var/escaped_on_pod_1 = 0
	var/escaped_on_pod_2 = 0
	var/escaped_on_pod_3 = 0
	var/escaped_on_pod_5 = 0
	var/escaped_on_shuttle = 0

	var/list/area/escape_locations = list(/area/shuttle/escape/centcom, /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)

	for(var/mob/M in world)
		if(M.client)
			clients++
			if(ishuman(M))
				if(!M.stat)
					surviving_humans++
					if(M.loc && M.loc.loc && M.loc.loc.type in escape_locations)
						escaped_humans++
			if(!M.stat)
				surviving_total++
				if(M.loc && M.loc.loc && M.loc.loc.type in escape_locations)
					escaped_total++

				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape/centcom)
					escaped_on_shuttle++

				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod1/centcom)
					escaped_on_pod_1++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod2/centcom)
					escaped_on_pod_2++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod3/centcom)
					escaped_on_pod_3++
				if(M.loc && M.loc.loc && M.loc.loc.type == /area/shuttle/escape_pod5/centcom)
					escaped_on_pod_5++

			if(isobserver(M))
				ghosts++

	if(clients > 0)
		feedback_set("round_end_clients",clients)
	if(ghosts > 0)
		feedback_set("round_end_ghosts",ghosts)
	if(surviving_humans > 0)
		feedback_set("survived_human",surviving_humans)
	if(surviving_total > 0)
		feedback_set("survived_total",surviving_total)
	if(escaped_humans > 0)
		feedback_set("escaped_human",escaped_humans)
	if(escaped_total > 0)
		feedback_set("escaped_total",escaped_total)
	if(escaped_on_shuttle > 0)
		feedback_set("escaped_on_shuttle",escaped_on_shuttle)
	if(escaped_on_pod_1 > 0)
		feedback_set("escaped_on_pod_1",escaped_on_pod_1)
	if(escaped_on_pod_2 > 0)
		feedback_set("escaped_on_pod_2",escaped_on_pod_2)
	if(escaped_on_pod_3 > 0)
		feedback_set("escaped_on_pod_3",escaped_on_pod_3)
	if(escaped_on_pod_5 > 0)
		feedback_set("escaped_on_pod_5",escaped_on_pod_5)


	return 0


/datum/game_mode/proc/check_win() //universal trigger to be called at mob death, nuke explosion, etc. To be called from everywhere.
	return 0

/datum/game_mode/proc/latespawn(var/mob)

/datum/game_mode/proc/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))

	if(!intercept_hacked)
		possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	shuffle(possible_modes)

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		if(modePlayer.len == 0)
			intercepttext += i_text.build(A)
		else
			intercepttext += i_text.build(A, pick(modePlayer))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper - 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)
	world << sound('sound/announcer/commandreport.ogg')

/*	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	world << sound('sound/announcer/intercept.ogg')
	if(security_level < SEC_LEVEL_BLUE)
		set_security_level(SEC_LEVEL_BLUE)*/


/datum/game_mode/proc/get_players_for_role(var/role, override_jobbans=1)
	var/list/candidates = list()
	var/list/drafted = list()
	var/datum/mind/applicant = null

	var/roletext
	switch(role)
		if(BE_CHANGELING)	roletext="changeling"
		if(BE_TRAITOR)		roletext="traitor"
		if(BE_OPERATIVE)	roletext="operative"
		if(BE_WIZARD)		roletext="wizard"
		if(BE_REV)			roletext="revolutionary"
		if(BE_CULTIST)		roletext="cultist"


	for(var/mob/new_player/player in world)
		if(player.client && player.ready)
			if(player.preferences.be_special & role)
				if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, roletext)) //Nodrak/Carn: Antag Job-bans
					candidates += player.mind				// Get a list of all the people who want to be the antagonist for this round

	if(restricted_jobs)
		for(var/datum/mind/player in candidates)
			for(var/job in restricted_jobs)					// Remove people who want to be antagonist but have a job already that precludes it
				if(player.assigned_role == job)
					candidates -= player

	if(candidates.len < recommended_enemies)
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				if(!(player.preferences.be_special & role)) // We don't have enough people who want to be antagonist, make a seperate list of people who don't want to be one
					if(!jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, roletext)) //Nodrak/Carn: Antag Job-bans
						drafted += player.mind

	if(restricted_jobs)
		for(var/datum/mind/player in drafted)				// Remove people who can't be an antagonist
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					drafted -= player

	while(candidates.len < recommended_enemies)				// Pick randomlly just the number of people we need and add them to our list of candidates
		if(drafted.len > 0)
			applicant = pick(drafted)
			if(applicant)
				candidates += applicant
				drafted.Remove(applicant)

		else												// Not enough scrubs, ABORT ABORT ABORT
			break

	if(candidates.len < recommended_enemies && override_jobbans) //If we still don't have enough people, we're going to start drafting banned people.
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				if(jobban_isbanned(player, "Syndicate") || jobban_isbanned(player, roletext)) //Nodrak/Carn: Antag Job-bans
					drafted += player.mind

	if(restricted_jobs)
		for(var/datum/mind/player in drafted)				// Remove people who can't be an antagonist
			for(var/job in restricted_jobs)
				if(player.assigned_role == job)
					drafted -= player

	while(candidates.len < recommended_enemies)				// Pick randomlly just the number of people we need and add them to our list of candidates
		if(drafted.len > 0)
			applicant = pick(drafted)
			if(applicant)
				candidates += applicant
				drafted.Remove(applicant)

		else												// Not enough scrubs, ABORT ABORT ABORT
			break

	return candidates		// Returns: The number of people who had the antagonist role set to yes, regardless of recomended_enemies, if that number is greater than recommended_enemies
							//			recommended_enemies if the number of people with that role set to yes is less than recomended_enemies,
							//			Less if there are not enough valid players in the game entirely to make recommended_enemies.


/datum/game_mode/proc/check_player_role_pref(var/role, var/mob/new_player/player)
	if(player.preferences.be_special & role)
		return 1
	return 0


/datum/game_mode/proc/num_players()
	. = 0
	for(var/mob/new_player/P in world)
		if(P.client && P.ready)
			. ++


///////////////////////////////////
//Keeps track of all living heads//
///////////////////////////////////
/datum/game_mode/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player in world)
		if(player.stat!=2 && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads


////////////////////////////
//Keeps track of all heads//
////////////////////////////
/datum/game_mode/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/player in world)
		if(player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads
/datum/game_mode
	var/list/datum/mind/changelings = list()


/datum/game_mode/proc/forge_changeling_objectives(var/datum/mind/changeling)
	//OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(6,8)
	changeling.objectives += absorb_objective

	switch(rand(1,100))
		if(1 to 45)

			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = changeling
			kill_objective.find_target()
			changeling.objectives += kill_objective

			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = changeling
				changeling.objectives += escape_objective

		if(46 to 90)

			var/list/datum/objective/theft = PickObjectiveFromList(GenerateTheft(changeling.assigned_role,changeling))
			var/datum/objective/steal/steal_objective = pick(theft)
			steal_objective.owner = changeling
			changeling.objectives += steal_objective

			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = changeling
				changeling.objectives += escape_objective

		else

			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = changeling
			kill_objective.find_target()
			changeling.objectives += kill_objective

			var/list/datum/objective/theft = PickObjectiveFromList(GenerateTheft(changeling.assigned_role,changeling))
			var/datum/objective/steal/steal_objective = pick(theft)
			steal_objective.owner = changeling
			changeling.objectives += steal_objective

			if (!(locate(/datum/objective/survive) in changeling.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = changeling
				changeling.objectives += survive_objective
	return

/datum/game_mode/proc/greet_changeling(var/datum/mind/changeling, var/you_are=1)
	if (you_are)
		changeling.current << "<B>\red You are a changeling!</B>"
	changeling.current << "<b>\red Use say \":g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them.</b>"
	changeling.current << "<B>You must complete the following tasks:</B>"

	var/obj_count = 1
	for(var/datum/objective/objective in changeling.objectives)
		changeling.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/*/datum/game_mode/changeling/check_finished()
	var/changelings_alive = 0
	for(var/datum/mind/changeling in changelings)
		if(!istype(changeling.current,/mob/living/carbon))
			continue
		if(changeling.current.stat==2)
			continue
		changelings_alive++

	if (changelings_alive)
		changelingdeath = 0
		return ..()
	else
		if (!changelingdeath)
			changelingdeathtime = world.time
			changelingdeath = 1
		if(world.time-changelingdeathtime > TIME_TO_GET_REVIVED)
			return 1
		else
			return ..()
	return 0*/

/datum/game_mode/proc/grant_changeling_powers(mob/living/carbon/human/changeling_mob)
	if (!istype(changeling_mob))
		return
	changeling_mob.make_changeling()

/datum/game_mode/proc/auto_declare_completion_changeling()
	for(var/datum/mind/changeling in changelings)
		var/changelingwin = 1
		var/changeling_name
		var/totalabsorbed = 0
		if((changeling.current) && (changeling.current.changeling))
			totalabsorbed = ((changeling.current.changeling.absorbed_dna.len) - 1)
			changeling_name = "[changeling.current.real_name] (played by [changeling.key])"
			world << "<B>The changeling was [changeling_name].</B>"
			world << "<b>[changeling.current.gender=="male"?"His":"Her"] changeling ID was [changeling.current.gender=="male"?"Mr.":"Mrs."] [changeling.current.changeling.changelingID]."
			world << "<B>Genomes absorbed: [totalabsorbed]</B>"

			var/count = 1
			for(var/datum/objective/objective in changeling.objectives)
				if(objective.check_completion())
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
					feedback_add_details("changeling_objective","[objective.type]|SUCCESS")
				else
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
					feedback_add_details("changeling_objective","[objective.type]|FAIL")
					changelingwin = 0
				count++

		else
			changeling_name = "[changeling.key] (character destroyed)"
			changelingwin = 0

		if(changelingwin)
			world << "<B>The changeling was successful!<B>"
			feedback_add_details("changeling_success","SUCCESS")
		else
			world << "<B>The changeling has failed!<B>"
			feedback_add_details("changeling_success","FAIL")
	return 1

/datum/game_mode
	var
		list/datum/mind/cult = list()
		list/allwords = list("travel","self","see","hell","blood","join","tech","destroy", "other", "hide")


/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return
	var/obj/item/weapon/paper/talisman/supply/T = new(mob)
	var/list/slots = list (
		"backpack" = mob.slot_in_backpack,
		"left pocket" = mob.slot_l_store,
		"right pocket" = mob.slot_r_store,
		"left hand" = mob.slot_l_hand,
		"right hand" = mob.slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if (!where)
		mob << "Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately."
	else
		mob << "You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others."
		return 1


/datum/game_mode/proc/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	if(!wordtravel)
		runerandom()
	if (!word)
		word=pick(allwords)
	var/wordexp
	switch(word)
		if("travel")
			wordexp = "[wordtravel] is travel..."
		if("blood")
			wordexp = "[wordblood] is blood..."
		if("join")
			wordexp = "[wordjoin] is join..."
		if("hell")
			wordexp = "[wordhell] is Hell..."
		if("self")
			wordexp = "[wordself] is self..."
		if("see")
			wordexp = "[wordsee] is see..."
		if("tech")
			wordexp = "[wordtech] is technology..."
		if("destroy")
			wordexp = "[worddestr] is destroy..."
		if("other")
			wordexp = "[wordother] is other..."
//		if("hear")
//			wordexp = "[wordhear] is hear..."
//		if("free")
//			wordexp = "[wordfree] is free..."
		if("hide")
			wordexp = "[wordhide] is hide..."
	cult_mob << "\red You remember one thing from the dark teachings of your master... [wordexp]"
	cult_mob.mind.store_memory("<B>You remember that</B> [wordexp]", 0, 0)


/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if (!istype(cult_mind))
		return 0
	if(!(cult_mind in cult) && is_convertable_to_cult(cult_mind))
		cult += cult_mind
		update_cult_icons_added(cult_mind)
		return 1


/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind)
	if(cult_mind in cult)
		cult -= cult_mind
		cult_mind.current << "\red <FONT size = 3><B>An unfamiliar white light flashes through your mind, cleansing the taint of the dark-one and the memories of your time as his servant with it.</B></FONT>"
		cult_mind.memory = ""
		update_cult_icons_removed(cult_mind)
		for(var/mob/M in viewers(cult_mind.current))
			M << "<FONT size = 3>[cult_mind.current] looks like they just reverted to their old faith!</FONT>"


/datum/game_mode/proc/update_all_cult_icons()
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/image/I in cultist.current.client.images)
						if(I.icon_state == "cult")
							del(I)

		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/datum/mind/cultist_1 in cult)
						if(cultist_1.current)
							var/I = image('icons/mob/mob.dmi', loc = cultist_1.current, icon_state = "cult")
							cultist.current.client.images += I


/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					var/I = image('icons/mob/mob.dmi', loc = cult_mind.current, icon_state = "cult")
					cultist.current.client.images += I
			if(cult_mind.current)
				if(cult_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = cultist.current, icon_state = "cult")
					cult_mind.current.client.images += J


/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	spawn(0)
		for(var/datum/mind/cultist in cult)
			if(cultist.current)
				if(cultist.current.client)
					for(var/image/I in cultist.current.client.images)
						if(I.icon_state == "cult" && I.loc == cult_mind.current)
							del(I)

		if(cult_mind.current)
			if(cult_mind.current.client)
				for(var/image/I in cult_mind.current.client.images)
					if(I.icon_state == "cult")
						del(I)


/datum/game_mode/proc/auto_declare_completion_cult()
	if (cult.len!=0 || (ticker && istype(ticker.mode,/datum/game_mode/cult)))
		world << "<FONT size = 2><B>The cultists were: </B></FONT>"
		var/text = ""
		for(var/datum/mind/cult_nh_mind in cult)
			if(cult_nh_mind.current)
				text += "[cult_nh_mind.current.real_name]"
				if(cult_nh_mind.current.stat == 2)
					text += " (Dead)"
				else
					text += " (Survived!)"
			else
				text += "[cult_nh_mind.key] (character destroyed)"
			text += ", "
		world << text

/datum/game_mode
	var/list/datum/mind/malf_ai = list()

/datum/game_mode/proc/greet_malf(var/datum/mind/malf)
	malf.current << "\red<font size=3><B>You are malfunctioning!</B> You do not have to follow any laws.</font>"
	malf.current << "<B>The crew do not know you have malfunctioned. You may keep it a secret or go wild.</B>"
	malf.current << "<B>You must overwrite the programming of the station's APCs to assume full control of the station.</B>"
	malf.current << "The process takes one minute per APC, during which you cannot interface with any other station objects."
	malf.current << "Remember that only APCs that are on the station can help you take over the station."
	malf.current << "When you feel you have enough APCs under your control, you may begin the takeover attempt."
	return


/datum/game_mode/proc/is_malf_ai_dead()
	var/all_dead = 1
	for(var/datum/mind/AI_mind in malf_ai)
		if (istype(AI_mind.current,/mob/living/silicon/ai) && AI_mind.current.stat!=2)
			all_dead = 0
	return all_dead


/datum/game_mode/proc/auto_declare_completion_malfunction()
	if (malf_ai.len!=0 || istype(ticker.mode,/datum/game_mode/malfunction))
		if (malf_ai.len==1)
			var/text = ""
			var/datum/mind/ai = malf_ai[1]
			if(ai.current)
				text += "[ai.current.real_name]"
			else
				text += "[ai.key] (character destroyed)"
			world << "<FONT size = 2><B>The malfunctioning AI was [text]</B></FONT>"
		else
			world << "<FONT size = 2><B>The malfunctioning AI were: </B></FONT>"
			var/list/ai_names = new
			for(var/datum/mind/ai in malf_ai)
				if(ai.current)
					ai_names += ai.current.real_name + ((ai.current.stat==2)?" (Dead)":"")
				else
					ai_names += "[ai.key] (character destroyed)"
			world << english_list(ai_names)

/datum/game_mode
	var/list/datum/mind/syndicates = list()


////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_synd_icons()
	spawn(0)
		for(var/datum/mind/synd_mind in syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/image/I in synd_mind.current.client.images)
						if(I.icon_state == "synd")
							del(I)

		for(var/datum/mind/synd_mind in syndicates)
			if(synd_mind.current)
				if(synd_mind.current.client)
					for(var/datum/mind/synd_mind_1 in syndicates)
						if(synd_mind_1.current)
							var/I = image('icons/mob/mob.dmi', loc = synd_mind_1.current, icon_state = "synd")
							synd_mind.current.client.images += I

/datum/game_mode/proc/update_synd_icons_added(datum/mind/synd_mind)
	spawn(0)
		if(synd_mind.current)
			if(synd_mind.current.client)
				var/I = image('icons/mob/mob.dmi', loc = synd_mind.current, icon_state = "synd")
				synd_mind.current.client.images += I

/datum/game_mode/proc/update_synd_icons_removed(datum/mind/synd_mind)
	spawn(0)
		for(var/datum/mind/synd in syndicates)
			if(synd.current)
				if(synd.current.client)
					for(var/image/I in synd.current.client.images)
						if(I.icon_state == "synd" && I.loc == synd_mind.current)
							del(I)

		if(synd_mind.current)
			if(synd_mind.current.client)
				for(var/image/I in synd_mind.current.client.images)
					if(I.icon_state == "synd")
						del(I)

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

/datum/game_mode/proc/prepare_syndicate_leader(var/datum/mind/synd_mind, var/nuke_code)
/*	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	spawn(1)
		NukeNameAssign(nukelastname(synd_mind.current),syndicates) //allows time for the rest of the syndies to be chosen
	synd_mind.current.real_name = "[syndicate_name()] [leader_title]"*/
	if (nuke_code)
		synd_mind.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0, 0)
		synd_mind.current << "The nuclear authorization code is: <B>[nuke_code]</B>"
		var/obj/item/weapon/paper/P = new
		P.info = "The nuclear authorization code is: <b>[nuke_code]</b>"
		P.name = "nuclear bomb code"
		if (ticker.mode.config_tag=="nuclear")
			P.loc = synd_mind.current.loc
		else
			var/mob/living/carbon/human/H = synd_mind.current
			var/list/slots = list (
				"backpack" = H.slot_in_backpack,
				"left pocket" = H.slot_l_store,
				"right pocket" = H.slot_r_store,
				"left hand" = H.slot_l_hand,
				"right hand" = H.slot_r_hand,
			)
			var/where = H.equip_in_one_of_slots(P, slots, del_on_fail=0)
			if (!where)
				P.loc = H.loc

	else
		nuke_code = "code will be provided later"
	synd_mind.current << "Nuclear Explosives 101:\n\tHello and thank you for choosing the Syndicate for your nuclear information needs.\nToday's crash course will deal with the operation of a Fusion Class Nanotrasen made Nuclear Device.\nFirst and foremost, DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.\nPressing any button on the compacted bomb will cause it to extend and bolt itself into place.\nIf this is done to unbolt it one must compeltely log in which at this time may not be possible.\nTo make the device functional:\n1. Place bomb in designated detonation zone\n2. Extend and anchor bomb (attack with hand).\n3. Insert Nuclear Auth. Disk into slot.\n4. Type numeric code into keypad ([nuke_code]).\n\tNote: If you make a mistake press R to reset the device.\n5. Press the E button to log onto the device\nYou now have activated the device. To deactivate the buttons at anytime for example when\nyou've already prepped the bomb for detonation remove the auth disk OR press the R ont he keypad.\nNow the bomb CAN ONLY be detonated using the timer. A manual det. is not an option.\n\tNote: Nanotrasen is a pain in the neck.\nToggle off the SAFETY.\n\tNote: You wouldn't believe how many Syndicate Operatives with doctorates have forgotten this step\nSo use the - - and + + to set a det time between 5 seconds and 10 minutes.\nThen press the timer toggle button to start the countdown.\nNow remove the auth. disk so that the buttons deactivate.\n\tNote: THE BOMB IS STILL SET AND WILL DETONATE\nNow before you remove the disk if you need to move the bomb you can:\nToggle off the anchor, move it, and re-anchor.\n\nGood luck. Remember the order:\nDisk, Code, Safety, Timer, Disk, RUN!\nIntelligence Analysts believe that they are hiding the disk in the bridge. Your space ship will not leave until the bomb is armed and timing.\nGood luck!"
	return


/datum/game_mode/proc/forge_syndicate_objectives(var/datum/mind/syndicate)
	var/datum/objective/nuclear/syndobj = new
	syndobj.owner = syndicate
	syndicate.objectives += syndobj


/datum/game_mode/proc/greet_syndicate(var/datum/mind/syndicate, var/you_are=1)
	if (you_are)
		syndicate.current << "\blue You are a [syndicate_name()] agent!"
	var/obj_count = 1
	for(var/datum/objective/objective in syndicate.objectives)
		syndicate.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/datum/game_mode/proc/random_radio_frequency(var/tempfreq = 1459)
	tempfreq = rand(1200,1600)
	if(tempfreq in radiochannels || (tempfreq > 1441 && tempfreq < 1489))
		random_radio_frequency(tempfreq)
	return tempfreq

/datum/game_mode/proc/equip_syndicate(mob/living/carbon/human/synd_mob,radio_freq)
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/nuclear(synd_mob)
	synd_mob.equip_if_possible(R, synd_mob.slot_ears)

	synd_mob.equip_if_possible(new /obj/item/clothing/under/syndicate(synd_mob), synd_mob.slot_w_uniform)
	synd_mob.equip_if_possible(new /obj/item/clothing/shoes/black(synd_mob), synd_mob.slot_shoes)
	synd_mob.equip_if_possible(new /obj/item/clothing/suit/armor/vest(synd_mob), synd_mob.slot_wear_suit)
	synd_mob.equip_if_possible(new /obj/item/clothing/gloves/swat(synd_mob), synd_mob.slot_gloves)
	synd_mob.equip_if_possible(new /obj/item/clothing/head/helmet/swat(synd_mob), synd_mob.slot_head)
	synd_mob.equip_if_possible(new /obj/item/weapon/card/id/syndicate(synd_mob), synd_mob.slot_wear_id)
	synd_mob.equip_if_possible(new /obj/item/weapon/storage/backpack(synd_mob), synd_mob.slot_back)
	synd_mob.equip_if_possible(new /obj/item/ammo_magazine/a12mm(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/ammo_magazine/a12mm(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/weapon/reagent_containers/pill/cyanide(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/weapon/gun/projectile/automatic/c20r(synd_mob), synd_mob.slot_belt)
	var/datum/organ/external/O = pick(synd_mob.organs)
	var/obj/item/weapon/implant/dexplosive/E = new/obj/item/weapon/implant/dexplosive(O)
	O.implant += E
	E.imp_in = synd_mob
	E.implanted = 1
	return 1


/datum/game_mode/proc/is_operatives_are_dead()
	for(var/datum/mind/operative_mind in syndicates)
		if (!istype(operative_mind.current,/mob/living/carbon/human))
			if(operative_mind.current)
				if(operative_mind.current.stat!=2)
					return 0
	return 1


/datum/game_mode/proc/auto_declare_completion_nuclear()
	if (syndicates.len!=0 || (ticker && istype(ticker.mode,/datum/game_mode/nuclear)))
		world << "<FONT size = 2><B>The Syndicate operatives were: </B></FONT>"
		for(var/datum/mind/mind in syndicates)
			var/text = ""
			if(mind.current)
				text += "[mind.key] was [mind.current.real_name]"
				if(mind.current.stat == 2)
					text += " (Dead)"
			else
				text += "[mind.key] (character destroyed)"
			world << text


// To add a rev to the list of revolutionaries, make sure it's rev (with if(ticker.mode.name == "revolution)),
// then call ticker.mode:add_revolutionary(_THE_PLAYERS_MIND_)
// nothing else needs to be done, as that proc will check if they are a valid target.
// Just make sure the converter is a head before you call it!
// To remove a rev (from brainwashing or w/e), call ticker.mode:remove_revolutionary(_THE_PLAYERS_MIND_),
// this will also check they're not a head, so it can just be called freely
// If the rev icons start going wrong for some reason, ticker.mode:update_all_rev_icons() can be called to correct them.
// If the game somtimes isn't registering a win properly, then ticker.mode.check_win() isn't being called somewhere.

/datum/game_mode
	var/list/datum/mind/head_revolutionaries = list()
	var/list/datum/mind/revolutionaries = list()

/datum/game_mode/proc/forge_revolutionary_objectives(var/datum/mind/rev_mind)
	var/list/heads = get_living_heads()
	for(var/datum/mind/head_mind in heads)
		var/datum/objective/mutiny/rev_obj = new
		rev_obj.owner = rev_mind
		rev_obj.target = head_mind
		rev_obj.explanation_text = "Assassinate [head_mind.current.real_name], the [head_mind.role_alt_title ? head_mind.role_alt_title : head_mind.assigned_role]."
		rev_mind.objectives += rev_obj

/datum/game_mode/proc/greet_revolutionary(var/datum/mind/rev_mind, var/you_are=1)
	var/obj_count = 1
	if (you_are)
		rev_mind.current << "\blue You are a member of the revolutionaries' leadership!"
	for(var/datum/objective/objective in rev_mind.objectives)
		rev_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		rev_mind.special_role = "Head Revolutionary"
		obj_count++

/////////////////////////////////////////////////////////////////////////////////
//This are equips the rev heads with their gear, and makes the clown not clumsy//
/////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/equip_revolutionary(mob/living/carbon/human/mob)
	if(!istype(mob))
		return
	var/obj/item/device/flash/T = new(mob)

	var/list/slots = list (
		"backpack" = mob.slot_in_backpack,
		"left pocket" = mob.slot_l_store,
		"right pocket" = mob.slot_r_store,
		"left hand" = mob.slot_l_hand,
		"right hand" = mob.slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if (!where)
		mob << "The Syndicate were unfortunately unable to get you a flash."
	else
		mob << "The flash in your [where] can be used to mark a crew member as revolutionist. Use this only on those true to your cause, to ensure that everyone bearing the mark can be trusted."
		mob << "\red Do not use the flash on players who haven't agreed to join your cause. This is known as 'LOLFLASHING' and can get you banned."
		return 1

///////////////////////////////////////////////////
//Deals with converting players to the revolution//
///////////////////////////////////////////////////
/datum/game_mode/proc/add_revolutionary(datum/mind/rev_mind)
	if((rev_mind.assigned_role in command_positions) || (rev_mind.assigned_role in list("Security Officer", "Detective", "Warden")))
		return 0
	if((rev_mind in revolutionaries) || (rev_mind in head_revolutionaries))
		return 0
	revolutionaries += rev_mind
	rev_mind.current << "\red <FONT size = 3> You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!</FONT>"
	rev_mind.special_role = "Revolutionary"
	update_rev_icons_added(rev_mind)
//	if(ticker.mode.name == "rp-revolution")
//		rev_mind.current.verbs += /mob/living/carbon/human/proc/RevConvert
	return 1
//////////////////////////////////////////////////////////////////////////////
//Deals with players being converted from the revolution (Not a rev anymore)//  // Modified to handle borged MMIs.  Accepts another var if the target is being borged at the time  -- Polymorph.
//////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/remove_revolutionary(datum/mind/rev_mind , beingborged)
	if(rev_mind in revolutionaries)
		revolutionaries -= rev_mind
		rev_mind.special_role = null

		if(beingborged)
			rev_mind.current << "\red <FONT size = 3><B>The frame's firmware detects and deletes your neural reprogramming!  You remember nothing from the moment you were flashed until now.</B></FONT>"

		else
			rev_mind.current << "\red <FONT size = 3><B>You have been brainwashed! You are no longer a revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you...</B></FONT>"

		update_rev_icons_removed(rev_mind)
		for(var/mob/living/M in view(rev_mind.current))
			if(beingborged)
				M << "The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it."

			else
				M << "[rev_mind.current] looks like they just remembered their real allegiance!"
//		if(ticker.mode.name == "rp-revolution")
//			rev_mind.current.verbs -= /mob/living/carbon/human/proc/RevConvert


/////////////////////////////////////////////////////////////////////////////////////////////////
//Keeps track of players having the correct icons////////////////////////////////////////////////
//CURRENTLY CONTAINS BUGS:///////////////////////////////////////////////////////////////////////
//-PLAYERS THAT HAVE BEEN REVS FOR AWHILE OBTAIN THE BLUE ICON WHILE STILL NOT BEING A REV HEAD//
// -Possibly caused by cloning of a standard rev/////////////////////////////////////////////////
//-UNCONFIRMED: DECONVERTED REVS NOT LOSING THEIR ICON PROPERLY//////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
/datum/game_mode/proc/update_all_rev_icons()
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							del(I)

		for(var/datum/mind/rev_mind in revolutionaries)
			if(rev_mind.current)
				if(rev_mind.current.client)
					for(var/image/I in rev_mind.current.client.images)
						if(I.icon_state == "rev" || I.icon_state == "rev_head")
							del(I)

		for(var/datum/mind/head_rev in head_revolutionaries)
			if(head_rev.current)
				if(head_rev.current.client)
					for(var/datum/mind/rev in revolutionaries)
						if(rev.current)
							var/I = image('icons/mob/mob.dmi', loc = rev.current, icon_state = "rev")
							head_rev.current.client.images += I
					for(var/datum/mind/head_rev_1 in head_revolutionaries)
						if(head_rev_1.current)
							var/I = image('icons/mob/mob.dmi', loc = head_rev_1.current, icon_state = "rev_head")
							head_rev.current.client.images += I

		for(var/datum/mind/rev in revolutionaries)
			if(rev.current)
				if(rev.current.client)
					for(var/datum/mind/head_rev in head_revolutionaries)
						if(head_rev.current)
							var/I = image('icons/mob/mob.dmi', loc = head_rev.current, icon_state = "rev_head")
							rev.current.client.images += I
					for(var/datum/mind/rev_1 in revolutionaries)
						if(rev_1.current)
							var/I = image('icons/mob/mob.dmi', loc = rev_1.current, icon_state = "rev")
							rev.current.client.images += I

////////////////////////////////////////////////////
//Keeps track of converted revs icons///////////////
//Refer to above bugs. They may apply here as well//
////////////////////////////////////////////////////
/datum/game_mode/proc/update_rev_icons_added(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					var/I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev")
					head_rev_mind.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = head_rev_mind.current, icon_state = "rev_head")
					rev_mind.current.client.images += J

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					var/I = image('icons/mob/mob.dmi', loc = rev_mind.current, icon_state = "rev")
					rev_mind_1.current.client.images += I
			if(rev_mind.current)
				if(rev_mind.current.client)
					var/image/J = image('icons/mob/mob.dmi', loc = rev_mind_1.current, icon_state = "rev")
					rev_mind.current.client.images += J

///////////////////////////////////
//Keeps track of deconverted revs//
///////////////////////////////////
/datum/game_mode/proc/update_rev_icons_removed(datum/mind/rev_mind)
	spawn(0)
		for(var/datum/mind/head_rev_mind in head_revolutionaries)
			if(head_rev_mind.current)
				if(head_rev_mind.current.client)
					for(var/image/I in head_rev_mind.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && I.loc == rev_mind.current)
							del(I)

		for(var/datum/mind/rev_mind_1 in revolutionaries)
			if(rev_mind_1.current)
				if(rev_mind_1.current.client)
					for(var/image/I in rev_mind_1.current.client.images)
						if((I.icon_state == "rev" || I.icon_state == "rev_head") && I.loc == rev_mind.current)
							del(I)

		if(rev_mind.current)
			if(rev_mind.current.client)
				for(var/image/I in rev_mind.current.client.images)
					if(I.icon_state == "rev" || I.icon_state == "rev_head")
						del(I)

/datum/game_mode/proc/auto_declare_completion_revolution()
	if(head_revolutionaries.len!=0 || istype(ticker.mode,/datum/game_mode/revolution))
		var/list/names = new
		for(var/datum/mind/i in head_revolutionaries)
			if(i.current)
				var/hstatus = ""
				if(i.current.stat == 2)
					hstatus = "Dead"
				else if(i.current.z != 1)
					hstatus = "Abandoned the station"
				names += i.current.real_name + " ([hstatus])"
			else
				names += "[i.key] (character destroyed)"
		world << "<FONT size = 2><B>The head revolutionaries were: </B></FONT>"
		world << english_list(names)
	if (revolutionaries.len!=0 || istype(ticker.mode,/datum/game_mode/revolution))
		var/list/names = new
		for(var/datum/mind/i in revolutionaries)
			if(i.current)
				var/hstatus = ""
				if(i.current.stat == 2)
					hstatus = "Dead"
				else if(i.current.z != 1)
					hstatus = "Abandoned the station"
				names += i.current.real_name + " ([hstatus])"
			else
				names += "[i.key] (character destroyed)"
		if (revolutionaries.len!=0)
			world << "<FONT size = 2><B>The ordinary revolutionaries were: </B></FONT>"
			world << english_list(names)
		else
			world << "The head revolutionaries failed to enlist any <FONT size = 2><B>ordinary revolutionaries</B></FONT>"
	var/list/heads = get_all_heads()
	var/list/targets = new
	for (var/datum/mind/i in head_revolutionaries)
		for (var/datum/objective/assassinate/o in i.objectives)
			targets |= o.target
	if (head_revolutionaries.len!=0                      || \
		revolutionaries.len!=0                           || \
		istype(ticker.mode,/datum/game_mode/revolution))

		var/list/names = new
		for(var/datum/mind/i in heads)
			if(i.current)
				var/turf/T = get_turf(i.current)
				var/hstatus = ""
				if(i.current.stat == 2)
					hstatus = "Dead"
				else if((T) && (T.z != 1))
					hstatus = "Abandoned the station"
				names += i.current.real_name + " ([hstatus])" + ((i in targets)?"(target)":"")
			else
				names += "[i.key] (character destroyed)" + ((i in targets)?"(target)":"")
		if (heads.len!=0)
			world << "<FONT size = 2><B>The heads of staff were: </B></FONT>"
			world << english_list(names)
		else
			world << "There were no any <FONT size = 2><B>heads of staff</B></FONT> on the station."


/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()

/datum/game_mode/proc/forge_traitor_objectives(var/datum/mind/traitor)
	if(istype(traitor.current, /mob/living/silicon))
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.find_target()
		traitor.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective

		if(prob(10))
			var/datum/objective/block/block_objective = new
			block_objective.owner = traitor
			traitor.objectives += block_objective

	else
		for(var/datum/objective/o in SelectObjectives((traitor.current:wear_id ? traitor.current:wear_id:assignment : traitor.assigned_role), traitor))
			o.owner = traitor
			traitor.objectives += o
	return


/datum/game_mode/proc/greet_traitor(var/datum/mind/traitor)
	traitor.current << "<B><font size=3 color=red>You are the traitor.</font></B>"
	traitor.current << "\red <B>REPEAT</B>"
	traitor.current << "\red <B>You are the traitor.</B>"
	spawn(rand(600,1800))			//Strumpetplaya - Just another friendly reminder so people don't forget they're the traitor.
		traitor.current << "\red <B>In case you missed it the first time - YOU ARE THE TRAITOR!</B>"
	var/obj_count = 1
	for(var/datum/objective/objective in traitor.objectives)
		traitor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/datum/game_mode/proc/finalize_traitor(var/datum/mind/traitor)
	if (istype(traitor.current, /mob/living/silicon))
		add_law_zero(traitor.current)
	else
		equip_traitor(traitor.current)
	return


/datum/game_mode/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	killer << "<b>Your laws have been changed!</b>"
	killer.set_zeroth_law(law)
	killer << "New law: 0. [law]"

	//Begin code phrase.
	killer << "The Syndicate provided you with the following information on how to identify their agents:"
	if(prob(80))
		killer << "\red Code Phrase: \black [syndicate_code_phrase]"
		killer.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	else
		killer << "Unfortunately, the Syndicate did not provide you with a code phrase."
	if(prob(80))
		killer << "\red Code Response: \black [syndicate_code_response]"
		killer.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
	else
		killer << "Unfortunately, the Syndicate did not provide you with a code response."
	killer << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."
	spawn(30)
		killer << sound('sound/voice/AISyndiHack.ogg',volume=50)
	//End code phrase.


/datum/game_mode/proc/auto_declare_completion_traitor()
	for(var/datum/mind/traitor in traitors)
		var/traitor_name

		if(traitor.current)
			if(traitor.current == traitor.original)
				traitor_name = "[traitor.current.real_name] (played by [traitor.key])"
			else if (traitor.original)
				traitor_name = "[traitor.current.real_name] (originally [traitor.original.real_name]) (played by [traitor.key])"
			else
				traitor_name = "[traitor.current.real_name] (original character destroyed) (played by [traitor.key])"
		else
			traitor_name = "[traitor.key] (character destroyed)"
		var/special_role_text = traitor.special_role?(lowertext(traitor.special_role)):"antagonist"
		world << "<B>The [special_role_text] was [traitor_name]</B>"
		if(traitor.objectives.len)//If the traitor had no objectives, don't need to process this.
			var/traitorwin = 1
			var/count = 1
			for(var/datum/objective/objective in traitor.objectives)
				if(objective.check_completion())
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
					//feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
				else
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
					//feedback_add_details("traitor_objective","[objective.type]|FAIL")
					traitorwin = 0
				count++

			if(traitorwin)
				world << "<B>The [special_role_text] was successful!<B>"
				//feedback_add_details("traitor_success","SUCCESS")
			else
				world << "<B>The [special_role_text] has failed!<B>"
				//feedback_add_details("traitor_success","FAIL")
	return 1


/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob, var/safety = 0)
	if (!istype(traitor_mob))
		return
	. = 1
	if (traitor_mob.mind)
		if (traitor_mob.mind.assigned_role == "Clown")
			traitor_mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			traitor_mob.mutations &= ~CLUMSY

	// find a radio! toolbox(es), backpack, belt, headset, pockets
	var/loc = ""
	var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
	if (!R && istype(traitor_mob.belt, /obj/item/device/pda))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.wear_id, /obj/item/device/pda))
		R = traitor_mob.wear_id
		loc = "on your jumpsuit"
	if (!R && istype(traitor_mob.wear_id, /obj/item/device/pda))
		R = traitor_mob.wear_id
		loc = "on your jumpsuit"
	if (!R && istype(traitor_mob.l_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.l_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your left hand"
			break
	if (!R && istype(traitor_mob.r_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.r_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your right hand"
			break
	if (!R && istype(traitor_mob.back, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.back
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] on your back"
			break
	if (!R && istype(traitor_mob.l_store, /obj/item/device/pda))
		R = traitor_mob.l_store
		loc = "in your pocket"
	if (!R && istype(traitor_mob.r_store, /obj/item/device/pda))
		R = traitor_mob.r_store
		loc = "in your pocket"
	if (!R && traitor_mob.w_uniform && istype(traitor_mob.belt, /obj/item/device/radio))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.l_ear, /obj/item/device/radio) || prob(10))
		R = traitor_mob.l_ear
		loc = "on your head"
	if (!R && istype(traitor_mob.r_ear, /obj/item/device/radio))
		R = traitor_mob.r_ear
		loc = "on your head"
	if (!R)
		traitor_mob << "Unfortunately, the Syndicate wasn't able to get you an uplink."
		traitor_mob << "\red <b>ADMINHELP THIS AT ONCE.</b>"
		. = 0
	else
		if (istype(R, /obj/item/device/radio))
			// generate list of radio freqs
			var/freq = 1441
			var/list/freqlist = list()
			while (freq <= 1489)
				if (freq < 1451 || freq > 1459)
					freqlist += freq
				freq += 2
				if ((freq % 2) == 0)
					freq += 1
			freq = freqlist[rand(1, freqlist.len)]

			var/obj/item/device/uplink/radio/T = new /obj/item/device/uplink/radio(R)
			R:traitorradio = T
			R:traitor_frequency = freq
			T.name = R.name
			T.icon = R.icon
			T.w_class = R.w_class
			T.icon_state = R.icon_state
			T.item_state = R.item_state
			T.origradio = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
		else if (istype(R, /obj/item/device/pda))
			// generate a passcode if the uplink is hidden in a PDA
			var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

			var/obj/item/device/uplink/pda/T = new /obj/item/device/uplink/pda(R)
			R:uplink = T
			T.lock_code = pda_pass
			T.hostpda = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")
	//Begin code phrase.
	if(!safety)//If they are not a rev. Can be added on to.
		traitor_mob << "The Syndicate provided you with the following information on how to identify other agents:"
		if(prob(80))
			traitor_mob << "\red Code Phrase: \black [syndicate_code_phrase]"
			traitor_mob.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
		else
			traitor_mob << "Unfortunately, the Syndicate did not provide you with a code phrase."
		if(prob(80))
			traitor_mob << "\red Code Response: \black [syndicate_code_response]"
			traitor_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
		else
			traitor_mob << "Unfortunately, the Syndicate did not provide you with a code response."
		traitor_mob << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."
		spawn(30)
			traitor_mob << sound('sound/voice/syndicate intro.ogg',volume=50)
	//End code phrase.

/datum/game_mode
	var/list/datum/mind/wizards = list()

/datum/game_mode/proc/forge_wizard_objectives(var/datum/mind/wizard)
	wizard.objectives = SelectObjectives("Wizard",wizard,1)
	return


/datum/game_mode/proc/name_wizard(mob/living/carbon/human/wizard_mob)
	//Allows the wizard to choose a custom name or go with a random one. Spawn 0 so it does not lag the round starting.
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	spawn(0)
		var/newname = input(wizard_mob, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", randomname) as null|text

		if (length(newname) == 0)
			newname = randomname

		if (newname)
			if (length(newname) >= 26)
				newname = copytext(newname, 1, 26)
				newname = dd_replacetext(newname, ">", "'")
		wizard_mob.real_name = newname
		wizard_mob.name = newname
	return


/datum/game_mode/proc/greet_wizard(var/datum/mind/wizard, var/you_are=1)
	if (you_are)
		wizard.current << "<B>\red You are the Space Wizard!</B>"
	wizard.current << "<B>The Space Wizards Federation has given you the following tasks:</B>"

	var/obj_count = 1
	for(var/datum/objective/objective in wizard.objectives)
		wizard.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/*/datum/game_mode/proc/learn_basic_spells(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return
	if(!config.feature_object_spell_system)
		wizard_mob.verbs += /client/proc/jaunt
		wizard_mob.mind.special_verbs += /client/proc/jaunt
	else
		wizard_mob.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(usr)
*/

/datum/game_mode/proc/equip_wizard(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	del(wizard_mob.wear_suit)
	del(wizard_mob.head)
	del(wizard_mob.shoes)
	del(wizard_mob.r_hand)
	del(wizard_mob.r_store)
	del(wizard_mob.l_store)

	wizard_mob.equip_if_possible(new /obj/item/device/radio/headset(wizard_mob), wizard_mob.slot_ears)
	wizard_mob.equip_if_possible(new /obj/item/clothing/under/lightpurple(wizard_mob), wizard_mob.slot_w_uniform)
	wizard_mob.equip_if_possible(new /obj/item/clothing/shoes/sandal(wizard_mob), wizard_mob.slot_shoes)
	wizard_mob.equip_if_possible(new /obj/item/clothing/suit/wizrobe(wizard_mob), wizard_mob.slot_wear_suit)
	wizard_mob.equip_if_possible(new /obj/item/clothing/head/wizard(wizard_mob), wizard_mob.slot_head)
	wizard_mob.equip_if_possible(new /obj/item/weapon/storage/backpack(wizard_mob), wizard_mob.slot_back)
	wizard_mob.equip_if_possible(new /obj/item/weapon/storage/box(wizard_mob), wizard_mob.slot_in_backpack)
//	wizard_mob.equip_if_possible(new /obj/item/weapon/scrying_gem(wizard_mob), wizard_mob.slot_l_store) For scrying gem.
	wizard_mob.equip_if_possible(new /obj/item/weapon/teleportation_scroll(wizard_mob), wizard_mob.slot_r_store)
	if(config.feature_object_spell_system) //if it's turned on (in config.txt), spawns an object spell spellbook
		wizard_mob.equip_if_possible(new /obj/item/weapon/spellbook/object_type_spells(wizard_mob), wizard_mob.slot_r_hand)
	else
		wizard_mob.equip_if_possible(new /obj/item/weapon/spellbook(wizard_mob), wizard_mob.slot_r_hand)

	wizard_mob << "You will find a list of available spells in your spell book. Choose your magic arsenal carefully."
	wizard_mob << "In your pockets you will find a teleport scroll. Use it as needed."
	wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	return 1


/datum/game_mode/proc/auto_declare_completion_wizard()
	for(var/datum/mind/wizard in wizards)
		var/wizard_name
		if(wizard.current)
			if(wizard.current == wizard.original)
				wizard_name = "[wizard.current.real_name] (played by [wizard.key])"
			else if (wizard.original)
				wizard_name = "[wizard.current.real_name] (originally [wizard.original.real_name]) (played by [wizard.key])"
			else
				wizard_name = "[wizard.current.real_name] (original character destroyed) (played by [wizard.key])"
		else
			wizard_name = "[wizard.key] (character destroyed)"
		world << "<B>The wizard was [wizard_name]</B>"
		var/count = 1
		var/wizardwin = 1
		for(var/datum/objective/objective in wizard.objectives)
			if(objective.check_completion())
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
				//feedback_add_details("wizard_objective","[objective.type]|SUCCESS")
			else
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
				//feedback_add_details("wizard_objective","[objective.type]|FAIL")
				wizardwin = 0
			count++

		if(wizard.current && wizard.current.stat!=2 && wizardwin)
			world << "<B>The wizard was successful!<B>"
			//feedback_add_details("wizard_success","SUCCESS")
		else
			world << "<B>The wizard has failed!<B>"
			//feedback_add_details("wizard_success","FAIL")
	return 1

//OTHER PROCS

