/datum/module_types
	var/list/modcount = list()	// assoc list of the count of modules for a type

/datum/module_types/proc/addmod(var/type, var/modtextlist)
	modules += type	// index by type text
	modules[type] = modtextlist

/datum/module_types/proc/inmodlist(var/type)
	return ("[type]" in modules)

/datum/module_types/proc/getbitmask(var/type)
	var/count = modcount["[type]"]
	if(count)
		return 2**count-1

	var/modtext = modules["[type]"]
	var/num = 1
	var/pos = 1

	while(1)
		pos = findtext(modtext, ",", pos, 0)
		if(!pos)
			break
		else
			pos++
			num++

	modcount += "[type]"
	modcount["[type]"] = num

	return 2**num-1
