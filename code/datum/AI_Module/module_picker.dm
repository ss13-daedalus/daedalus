/datum/AI_Module/module_picker
	var/temp = null
	var/processing_time = 100
	var/list/possible_modules = list()

/datum/AI_Module/module_picker/New()
	src.possible_modules += new /datum/AI_Module/large/fireproof_core
	src.possible_modules += new /datum/AI_Module/large/upgrade_turrets
	src.possible_modules += new /datum/AI_Module/large/disable_rcd
	src.possible_modules += new /datum/AI_Module/small/overload_machine
	src.possible_modules += new /datum/AI_Module/small/interhack
	src.possible_modules += new /datum/AI_Module/small/blackout
	src.possible_modules += new /datum/AI_Module/small/reactivate_camera
	return

/datum/AI_Module/module_picker/proc/use(user as mob)
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else if(src.processing_time <= 0)
		dat = "<B> No processing time is left available. No more modules are able to be chosen at this time."
	else
		dat = "<B>Select use of processing time: (currently [src.processing_time] left.)</B><BR>"
		dat += "<HR>"
		dat += "<B>Install Module:</B><BR>"
		dat += "<I>The number afterwards is the amount of processing time it consumes.</I><BR>"
		for(var/datum/AI_Module/large/module in src.possible_modules)
			dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A> (50)<BR>"
		for(var/datum/AI_Module/small/module in src.possible_modules)
			dat += "<A href='byond://?src=\ref[src];[module.mod_pick_name]=1'>[module.module_name]</A> (15)<BR>"
		dat += "<HR>"

	user << browse(dat, "window=modpicker")
	onclose(user, "modpicker")
	return

/datum/AI_Module/module_picker/Topic(href, href_list)
	..()
	if (href_list["coreup"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/large/fireproof_core))
				already = 1
		if (!already)
			usr.verbs += /client/proc/fireproof_core
			usr:current_modules += new /datum/AI_Module/large/fireproof_core
			src.temp = "An upgrade to improve core resistance, making it immune to fire and heat. This effect is permanent."
			src.processing_time -= 50
		else src.temp = "This module is only needed once."

	else if (href_list["turret"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/large/upgrade_turrets))
				already = 1
		if (!already)
			usr.verbs += /client/proc/upgrade_turrets
			usr:current_modules += new /datum/AI_Module/large/upgrade_turrets
			src.temp = "Improves the firing speed and health of all AI turrets. This effect is permanent."
			src.processing_time -= 50
		else src.temp = "This module is only needed once."

	else if (href_list["rcd"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/large/disable_rcd))
				mod:uses += 1
				already = 1
		if (!already)
			usr:current_modules += new /datum/AI_Module/large/disable_rcd
			usr.verbs += /client/proc/disable_rcd
			src.temp = 	"Send a specialised pulse to break all RCD devices on the station."
		else src.temp = "Additional use added to RCD disabler."
		src.processing_time -= 50

	else if (href_list["overload"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/small/overload_machine))
				mod:uses += 2
				already = 1
		if (!already)
			usr.verbs += /client/proc/overload_machine
			usr:current_modules += new /datum/AI_Module/small/overload_machine
			src.temp = "Overloads an electrical machine, causing a small explosion. 2 uses."
		else src.temp = "Two additional uses added to Overload module."
		src.processing_time -= 15

	else if (href_list["blackout"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/small/blackout))
				mod:uses += 3
				already = 1
		if (!already)
			usr.verbs += /client/proc/blackout
			src.temp = "Attempts to overload the lighting circuits on the station, destroying some bulbs. 3 uses."
			usr:current_modules += new /datum/AI_Module/small/blackout
		else src.temp = "Three additional uses added to Blackout module."
		src.processing_time -= 15

	else if (href_list["interhack"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/small/interhack))
				already = 1
		if (!already)
			usr.verbs += /client/proc/interhack
			src.temp = "Tricks the station's automated diagnosis suite for a while, giving you more time until you are revealed."
			usr:current_modules += new /datum/AI_Module/small/interhack
			src.processing_time -= 15
		else src.temp = "This module is only needed once."

	else if (href_list["recam"])
		var/already
		for (var/datum/AI_Module/mod in usr:current_modules)
			if(istype(mod, /datum/AI_Module/small/reactivate_camera))
				mod:uses += 10
				already = 1
		if (!already)
			usr.verbs += /client/proc/reactivate_camera
			src.temp = "Reactivates a currently disabled camera. 10 uses."
			usr:current_modules += new /datum/AI_Module/small/reactivate_camera
		else src.temp = "Ten additional uses added to ReCam module."
		src.processing_time -= 15

	else
		if (href_list["temp"])
			src.temp = null
	src.use(usr)
	return

