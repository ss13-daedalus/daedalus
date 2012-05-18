/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Captain", "Head of Security")
	required_players = 3
	required_enemies = 3
	recommended_enemies = 4

	uplink_welcome = "Nar-Sie Uplink Console:"
	uplink_uses = 10

	var/datum/mind/sacrifice_target = null
	var/finished = 0
	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/startwords = list("blood","join","self","hell")

	var/list/objectives = list()

	var/eldergod = 1 //for the summon god objective

	var/const/acolytes_needed = 5 //for the survive objective
	var/const/min_cultists_to_start = 3
	var/const/max_cultists_to_start = 4
	var/acolytes_survived = 0


/datum/game_mode/cult/announce()
	world << "<B>The current game mode is - Cult!</B>"
	world << "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the convert rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with the chaplain's bible reverts them to whatever CentCom-allowed faith they had.</B>"


/datum/game_mode/cult/pre_setup()
	if(prob(50) || num_players() < 10) // don't give summon nar-sie if less than 10 people, it's literally impossible in that case!
		objectives += "survive"
		objectives += "sacrifice"
	else
		objectives += "eldergod"
		objectives += "sacrifice"

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/cultists_possible = get_players_for_role(BE_CULTIST)
	for(var/datum/mind/player in cultists_possible)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				cultists_possible -= player

	for(var/cultists_number = 1 to max_cultists_to_start)
		if(!cultists_possible.len)
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		cult += cultist

	return (cult.len>0)


/datum/game_mode/cult/post_setup()
	modePlayer += cult
	if("sacrifice" in objectives)
		var/list/possible_targets = get_unconvertables()

		if(!possible_targets.len)
			for(var/mob/living/carbon/human/player in world)
				if(player.mind && !(player.mind in cult))
					possible_targets += player.mind

		if(possible_targets.len > 0)
			sacrifice_target = pick(possible_targets)

	for(var/datum/mind/cult_mind in cult)
		equip_cultist(cult_mind.current)
		grant_runeword(cult_mind.current)
		update_cult_icons_added(cult_mind)
		cult_mind.current << "\blue You are a member of the cult!"
		memoize_cult_objectives(cult_mind)
		cult_mind.special_role = "Cultist"

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()


/datum/game_mode/cult/proc/memoize_cult_objectives(var/datum/mind/cult_mind)
	for(var/obj_count = 1,obj_count <= objectives.len,obj_count++)
		var/explanation
		switch(objectives[obj_count])
			if("survive")
				explanation = "Our knowledge must live on. Make sure at least [acolytes_needed] acolytes escape on the shuttle to spread their work on an another station."
			if("sacrifice")
				if(sacrifice_target && sacrifice_target.current)
					explanation = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.role_alt_title ? sacrifice_target.role_alt_title : sacrifice_target.assigned_role]. You will need the sacrifice rune (Hell blood join) and three acolytes to do so."
				else
					explanation = "Free objective."
			if("eldergod")
				explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
		cult_mind.current << "<B>Objective #[obj_count]</B>: [explanation]"
		cult_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"
	cult_mind.current << "The convert rune is join blood self"
	cult_mind.memory += "The convert rune is join blood self<BR>"


/datum/game_mode/cult/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	if (!word)
		if(startwords.len > 0)
			word=pick(startwords)
			startwords -= word
	return ..(cult_mob,word)


/datum/game_mode/cult/add_cultist(datum/mind/cult_mind) //INHERIT
	if (!..(cult_mind))
		return
	memoize_cult_objectives(cult_mind)


/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in world)
		if(!is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs


/datum/game_mode/cult/proc/check_cult_victory()
	var/cult_fail = 0
	if(objectives.Find("survive"))
		cult_fail += check_survive() //the proc returns 1 if there are not enough cultists on the shuttle, 0 otherwise
	if(objectives.Find("eldergod"))
		cult_fail += eldergod //1 by default, 0 if the elder god has been summoned at least once
	if(objectives.Find("sacrifice"))
		if(!sacrificed.Find(sacrifice_target)) //if the target has been sacrificed, ignore this step. otherwise, add 1 to cult_fail
			cult_fail++

	return cult_fail //if any objectives aren't met, failure


/datum/game_mode/cult/proc/check_survive()
	acolytes_survived = 0
	for(var/datum/mind/cult_mind in cult)
		if (cult_mind.current && cult_mind.current.stat!=2)
			var/area/A = get_area(cult_mind.current )
			if ( is_type_in_list(A, centcom_areas))
				acolytes_survived++
	if(acolytes_survived>=acolytes_needed)
		return 0
	else
		return 1


/datum/game_mode/cult/declare_completion()

	if(!check_cult_victory())
		feedback_set_details("round_end_result","win - cult win")
		feedback_set("round_end_result",acolytes_survived)
		world << "\red <FONT size = 3><B> The cult wins! It has succeeded in serving its dark masters!</B></FONT>"
	else
		feedback_set_details("round_end_result","loss - staff stopped the cult")
		feedback_set("round_end_result",acolytes_survived)
		world << "\red <FONT size = 3><B> The staff managed to stop the cult!</B></FONT>"

	world << "\b Cultists escaped: [acolytes_survived]"

	world << "The cultists' objectives were:"

	for(var/obj_count=1,obj_count <= objectives.len,obj_count++)
		var/explanation
		switch(objectives[obj_count])
			if("survive")
				if(!check_survive())
					explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. \green <b>Success!</b>"
					//feedback_add_details("cult_objective","cult_survive|SUCCESS|[acolytes_needed]")
				else
					explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. \red Failed."
					//feedback_add_details("cult_objective","cult_survive|FAIL|[acolytes_needed]")
			if("sacrifice")
				if(!sacrifice_target)
					explanation = "Free objective"
				else
					if(sacrificed.Find(sacrifice_target))
						explanation = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.role_alt_title ? sacrifice_target.role_alt_title : sacrifice_target.assigned_role]. \green <b>Success!</b>"
						//feedback_add_details("cult_objective","cult_sacrifice|SUCCESS")
					else if(sacrifice_target && sacrifice_target.current)
						explanation = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.role_alt_title ? sacrifice_target.role_alt_title : sacrifice_target.assigned_role]. \red Failed."
						//feedback_add_details("cult_objective","cult_sacrifice|FAIL")
					else
						explanation = "Sacrifice Unknown, the Unknown whos body was likely gibbed. \red Failed."
						//feedback_add_details("cult_objective","cult_sacrifice|FAIL|GIBBED")
			if("eldergod")
				if(!eldergod)
					explanation = "Summon Nar-Sie. \green <b>Success!</b>"
					//feedback_add_details("cult_objective","cult_narsie|SUCCESS")
				else
					explanation = "Summon Nar-Sie. \red Failed."
					//feedback_add_details("cult_objective","cult_narsie|FAIL")
		world << "<B>Objective #[obj_count]</B>: [explanation]"

	..()
	return 1


