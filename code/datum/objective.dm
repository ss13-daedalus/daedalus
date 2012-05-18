datum/objective
	var/datum/mind/owner
	var/datum/mind/target
	var/explanation_text = "text not set"
	var/job
	var/points = INFINITY //If this isn't set to something else, the objective is bugged and should be ignored
	var/weight = INFINITY

	New(var/text,var/joba)
		if(text)
			src.explanation_text = text
		job=joba
		weight = get_weight(job)
		points = get_points(job)

	proc/check_completion()
		return 1
	proc/get_points(var/job)
		return INFINITY
	proc/get_weight(var/job)
		return INFINITY
	proc/find_target_by_role(role, role_type=0)//Option sets either to check assigned role or special role. Default to assigned.
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && ishuman(possible_target.current) && ((role_type ? possible_target.special_role : possible_target.assigned_role) == role) )
				target = possible_target
				break

