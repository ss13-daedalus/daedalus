datum/objective/escape
	explanation_text = "Escape on the shuttle alive, without being arrested."

	check_completion()
		if(emergency_shuttle.location<2)
			return 0

		if(!owner.current || owner.current.stat ==2)
			return 0

		var/turf/location = get_turf(owner.current.loc)
		if(!location)
			return 0

		if(owner.current:handcuffed || istype(location, /turf/simulated/shuttle/floor4))
			return 0

		if(location in locate(/area/shuttle/escape/centcom))
			return 1

		return 0
	get_points()
		return INFINITY

	get_weight(var/job)
		return 1

