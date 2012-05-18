datum/objective/hijack
	explanation_text = "Hijack the emergency shuttle by escaping alone."

	check_completion()
		if(emergency_shuttle.location<2)
			return 0

		if(!owner.current || owner.current.stat == 2)
			return 0
		var/turf/location = get_turf(owner.current.loc)

		if(location in locate(/area/shuttle/escape/centcom))
			for(var/mob/living/player in locate(/area/shuttle/escape/centcom))
				if (player.mind && (player.mind != owner))
					if (player.stat != 2) //they're not dead
						return 0
			return 1

		return 0
	get_points(var/job)
		switch(GetRank(job))
			if(0)
				return 75
			if(1)
				return 65
			if(2)
				return 65
			if(3)
				return 50
			if(4)
				return 35

	get_weight(var/job)
		return 1

