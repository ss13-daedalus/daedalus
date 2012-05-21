datum/signal
	var/obj/source

	var/transmission_method = 0
	//0 = wire
	//1 = radio transmission
	//2 = subspace transmission

	var/data = list()
	var/encryption

	var/frequency = 0

	proc/copy_from(datum/signal/model)
		source = model.source
		transmission_method = model.transmission_method
		data = model.data
		encryption = model.encryption
		frequency = model.frequency

	proc/debug_print()
		if (source)
			. = "signal = {source = '[source]' ([source:x],[source:y],[source:z])\n"
		else
			. = "signal = {source = '[source]' ()\n"
		for (var/i in data)
			. += "data\[\"[i]\"\] = \"[data[i]]\"\n"

