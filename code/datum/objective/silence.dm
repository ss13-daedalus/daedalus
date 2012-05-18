datum/objective/silence
	explanation_text = "Do not allow anyone to escape the station.  Only allow the shuttle to be called when everyone is dead and your story is the only one left."

	check_completion()
		if(emergency_shuttle.location<2)
			return 0

		var/area/shuttle = locate(/area/shuttle/escape/centcom)
		var/area/pod1 =    locate(/area/shuttle/escape_pod1/centcom)
		var/area/pod2 =    locate(/area/shuttle/escape_pod2/centcom)
		var/area/pod3 =    locate(/area/shuttle/escape_pod3/centcom)
		var/area/pod4 =    locate(/area/shuttle/escape_pod5/centcom)

		for(var/mob/living/player in world)
			if (player == owner.current)
				continue
			if (player.mind)
				if (player.stat != 2)
					if (get_turf(player) in shuttle)
						return 0
					if (get_turf(player) in pod1)
						return 0
					if (get_turf(player) in pod2)
						return 0
					if (get_turf(player) in pod3)
						return 0
					if (get_turf(player) in pod4)
						return 0
		return 1
