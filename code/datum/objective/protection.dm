datum/objective/protection
	New(var/text,var/joba,var/datum/mind/targeta)
		target = targeta
		job = joba
		weight = get_points(job)
		explanation_text = "[target.current.real_name], the [target.assigned_role] is a relative of a high ranking Syndicate Leader.  Make sure they get off the ship safely, while minimizing intervention."

	check_completion()
		if(emergency_shuttle.location<2)
			return 0

		if(target.current.stat == 2)
			return 0

		var/turf/location = get_turf(target.current.loc)
		if(!location)
			return 0

		if(location in locate(/area/shuttle/escape/centcom))
			return 1

		return 0

	get_points()
		if(target)
			return 30
		else
			return INFINITY

	get_weight()
		if(target)
			return 1
		return 0

	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Protect [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : (!role_type ? target.assigned_role : target.special_role)]."
		else
			explanation_text = "Free Objective"
		return target

