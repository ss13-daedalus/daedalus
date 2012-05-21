datum/controller/radio
	var/list/datum/radio_frequency/frequencies = list()

	proc/add_object(obj/device as obj, var/new_frequency as num, var/filter = null as text|null)
		var/f_text = num2text(new_frequency)
		var/datum/radio_frequency/frequency = frequencies[f_text]

		if(!frequency)
			frequency = new
			frequency.frequency = new_frequency
			frequencies[f_text] = frequency

		frequency.add_listener(device, filter)
		return frequency

	proc/remove_object(obj/device, old_frequency)
		var/f_text = num2text(old_frequency)
		var/datum/radio_frequency/frequency = frequencies[f_text]

		if(frequency)
			frequency.remove_listener(device)

			if(frequency.devices.len == 0)
				del(frequency)
				frequencies -= f_text

		return 1

	proc/return_frequency(var/new_frequency as num)
		var/f_text = num2text(new_frequency)
		var/datum/radio_frequency/frequency = frequencies[f_text]

		if(!frequency)
			frequency = new
			frequency.frequency = new_frequency
			frequencies[f_text] = frequency

		return frequency

