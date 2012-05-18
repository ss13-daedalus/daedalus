/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	restricted_jobs = list("AI", "Cyborg")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var
		const
			prob_int_murder_target = 50 // intercept names the assassination target half the time
			prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
			prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

			prob_int_item = 50 // intercept names the theft target half the time
			prob_right_item_l = 25 // lower bound on probability of naming right theft target
			prob_right_item_h = 50 // upper bound on probability of naming the right theft target

			prob_int_sab_target = 50 // intercept names the sabotage target half the time
			prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
			prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

			prob_right_killer_l = 25 //lower bound on probability of naming the right operative
			prob_right_killer_h = 50 //upper bound on probability of naming the right operative
			prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
			prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

			waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
			waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

			const/changeling_amount = 4

/datum/game_mode/changeling/announce()
	world << "<B>The current game mode is - Changeling!</B>"
	world << "<B>There are alien changelings on the station. Do not let the changelings succeed!</B>"

/datum/game_mode/changeling/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(BE_CHANGELING)

	for(var/datum/mind/player in possible_changelings)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				possible_changelings -= player

	if(possible_changelings.len>0)
		for(var/i = 0, i < changeling_amount, i++)
			if(!possible_changelings.len) break
			var/datum/mind/changeling = pick(possible_changelings)
			possible_changelings -= changeling
			changelings += changeling
			modePlayer += changelings
		return 1
	else
		return 0

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return


