/datum/station_state
	var
		floor = 0
		wall = 0
		r_wall = 0
		window = 0
		door = 0
		grille = 0
		mach = 0


	proc/count()
		for(var/turf/T in world)
			if(T.z != 1)
				continue

			if(istype(T,/turf/simulated/floor))
				if(!(T:burnt))
					src.floor += 12
				else
					src.floor += 1

			if(istype(T, /turf/simulated/wall))
				if(T:intact)
					src.wall += 2
				else
					src.wall += 1

			if(istype(T, /turf/simulated/wall/r_wall))
				if(T:intact)
					src.r_wall += 2
				else
					src.r_wall += 1

		for(var/obj/O in world)
			if(O.z != 1)
				continue

			if(istype(O, /obj/structure/window))
				src.window += 1
			else if(istype(O, /obj/structure/grille) && (!O:destroyed))
				src.grille += 1
			else if(istype(O, /obj/machinery/door))
				src.door += 1
			else if(istype(O, /obj/machinery))
				src.mach += 1
		return


	proc/score(var/datum/station_state/result)
		if(!result)	return 0
		var/output = 0
		output += (result.floor / max(floor,1))
		output += (result.r_wall/ max(r_wall,1))
		output += (result.wall / max(wall,1))
		output += (result.window / max(window,1))
		output += (result.door / max(door,1))
		output += (result.grille / max(grille,1))
		output += (result.mach / max(mach,1))
		return (output/7)
