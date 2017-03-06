turf
	var/pressure_difference = 0
	var/pressure_direction = 0

	//optimization vars
	var/next_check = 0  //number of ticks before this tile updates
	var/check_delay = 0  //number of ticks between updates

	assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
		del(giver)
		return 0

	return_air()
		//Create gas mixture to hold data for passing
		var/datum/gas_mixture/GM = new

		GM.oxygen = oxygen
		GM.carbon_dioxide = carbon_dioxide
		GM.nitrogen = nitrogen
		GM.toxins = toxins

		GM.temperature = temperature

		return GM

	remove_air(amount as num)
		var/datum/gas_mixture/GM = new

		var/sum = oxygen + carbon_dioxide + nitrogen + toxins
		if(sum>0)
			GM.oxygen = (oxygen/sum)*amount
			GM.carbon_dioxide = (carbon_dioxide/sum)*amount
			GM.nitrogen = (nitrogen/sum)*amount
			GM.toxins = (toxins/sum)*amount

		GM.temperature = temperature

		return GM

	proc
		high_pressure_movements()

			for(var/atom/movable/in_tile in src)
				in_tile.experience_pressure_difference(pressure_difference, pressure_direction)

			pressure_difference = 0

		consider_pressure_difference(connection_difference, connection_direction)
			if(connection_difference < 0)
				connection_difference = -connection_difference
				connection_direction = turn(connection_direction,180)

			if(connection_difference > pressure_difference)
				if(!pressure_difference)
					air_master.high_pressure_delta += src
				pressure_difference = connection_difference
				pressure_direction = connection_direction

	proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)

	CanPass(atom/movable/mover, turf/target, height=1.5,air_group=0)
		if(!target) return 0

		if(istype(mover)) // turf/Enter(...) will perform more advanced checks
			return !density

		else // Now, doing more detailed checks for air movement and air group formation
			if(target.blocks_air||blocks_air)
				return 0

			for(var/obj/obstacle in src)
				if(!obstacle.CanPass(mover, target, height, air_group))
					return 0
			for(var/obj/obstacle in target)
				if(!obstacle.CanPass(mover, src, height, air_group))
					return 0

			return 1
