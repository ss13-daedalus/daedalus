datum/objective/frame
	New(var/text,var/joba,var/datum/mind/targeta)
		target = targeta
		job = joba
		weight = get_points(job)
		explanation_text = "Frame [target.current.real_name], the [target.assigned_role] for a crime and make sure they are arrested and brought back to the Centcom station alive.  We'll handle the rest from there."

	check_completion()
		if(emergency_shuttle.location<2)
			return 0
		if(target.current.stat == 2)
			return 0
		var/turf/location = get_turf(target.current.loc)
		if(!location)
			return 0
		if(!target.current:handcuffed && !istype(location, /turf/simulated/shuttle/floor4))
			return 0

		if(location in locate(/area/shuttle/escape/centcom))
			return 1

		return 0

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
			return INFINITY

	get_weight()
		if(target)
			return 1
		return 0

