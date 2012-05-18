datum/objective/assassinate
	New(var/text,var/joba,var/datum/mind/targeta)
		target = targeta
		job = joba
		weight = get_points(job)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."

	check_completion()
		if(target && target.current)
			if(target.current.stat == 2 || istype(get_area(target.current), /area/tdome) || issilicon(target.current) || isbrain(target.current))
				return 1
			else
				return 0
		else
			return 1
	get_points()
		if(target)
			var/difficulty = GetRank(target.assigned_role) + 1
			switch(GetRank(job))
				if(4)
					return 20*difficulty
				if(3)
					return 30*difficulty
				if(2)
					return 40*difficulty
				if(1)
					return 55*difficulty
				if(0)
					return 60*difficulty
		else
			return 0

	get_weight()
		if(target)
			return 1
		return 0

	find_target_by_role(var/role)
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human) && (possible_target.assigned_role == role))
				target = possible_target
				break

		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"

		return target


	proc/find_target()
		var/list/possible_targets = list()

		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human))
				possible_targets += possible_target

		if(possible_targets.len > 0)
			target = pick(possible_targets)

		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"

		return target

