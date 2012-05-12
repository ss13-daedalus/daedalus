/proc/station_name()
	if (station_name)
		return station_name

	var/name = LOCATION_NAME

	station_name = name

	if (config && config.server_name)
		world.name = "[config.server_name]: [name]"
	else
		world.name = "Daedalus"

	return name

/proc/world_name(var/name)

	if (config && config.server_name)
		world.name = "[config.server_name]: [name]"
	else
		world.name = name

	return name
