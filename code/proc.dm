/* 
This file is for procs that have to be global for some reason or another
(for example, they are called by various other modules without prior
instantiation of related objects).

As the mere existence of this file is offensive to all right-thinking
programmers, do your best to keep things out of here, and document those
things that have to be put in here.
*/

// The following functions involve the "disease2" implementation.

proc/airborne_can_reach(turf/source, turf/target)
	var/obj/dummy = new(source)
	dummy.flags = FPRINT | TABLEPASS
	dummy.pass_flags = PASSTABLE

	for(var/i=0, i<5, i++) if(!step_towards(dummy, target)) break

	var/rval = (dummy.loc in range(1,target))
	del dummy
	return rval

/proc/infect_virus2(var/mob/living/carbon/M,var/datum/disease2/disease/disease,var/forced = 0)
	if(M.virus2)
		return
	if(!disease)
		return
	//immunity
	/*for(var/iii = 1, iii <= M.immunevirus2.len, iii++)
		if(disease.issame(M.immunevirus2[iii]))
			return*/

	// if one of the antibodies in the mob's body matches one of the disease's antigens, don't infect
	if(M.antibodies & disease.antigen != 0) return

	for(var/datum/disease2/resistance/res in M.resistances)
		if(res.resistsdisease(disease))
			return
	if(prob(disease.infectionchance) || forced)
		if(M.virus2)
			return
		else
			// certain clothes can prevent an infection
			if(!forced && !M.get_infection_chance())
				return

			M.virus2 = disease.getcopy()
			M.virus2.minormutate()

			for(var/datum/disease2/resistance/res in M.resistances)
				if(res.resistsdisease(M.virus2))
					M.virus2 = null

/proc/infect_mob_random_lesser(var/mob/living/carbon/M)
	if(!M.virus2)
		M.virus2 = new /datum/disease2/disease
		M.virus2.makerandom()

/proc/infect_mob_random_greater(var/mob/living/carbon/M)
	if(!M.virus2)
		M.virus2 = new /datum/disease2/disease
		M.virus2.makerandom(1)

// The preceding functions involved the "disease2" implementation.

proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"

// add a new news data
proc/make_news(title, body, author)
	var/savefile/News = new("data/news.sav")
	var/list/news
	var/lastID

	News["news"]   >> news
	News["lastID"] >> lastID

	if(!news) 	news = list()
	if(!lastID) lastID = 0

	var/datum/news/created = new()
	created.ID 		= ++lastID
	created.title 	= title
	created.body 	= body
	created.author 	= author
	created.date    = world.realtime

	news.Insert(1, created)

	News["news"]   << news
	News["lastID"] << lastID

// load the news from disk
proc/load_news()
	var/savefile/News = new("data/news.sav")
	var/list/news

	News["news"] >> news

	if(!news) news = list()

	return news

// save the news to disk
proc/save_news(var/list/news)
	var/savefile/News = new("data/news.sav")
	News << news

// This function counts a passed job.
proc/countJob(rank)
	var/jobCount = 0
	for(var/mob/H in world)
		if(H.mind && H.mind.assigned_role == rank)
			jobCount++
	return jobCount

/proc/AutoUpdateAI(obj/subject)
	if (subject!=null)
		for(var/mob/living/silicon/ai/M in world)
			if ((M.client && M.machine == subject))
				subject.attack_ai(M)

/proc/AutoUpdateTK(obj/subject)
	if (subject!=null)
		for(var/obj/item/tk_grab/T in world)
			if (T.host)
				var/mob/M = T.host
				if(M.client && M.machine == subject)
					subject.attack_hand(M)

/proc/religion_name()
	if (religion_name)
		return religion_name

	var/name = ""

	name += pick("bee", "science", "edu", "captain", "assistant", "monkey", "alien", "space", "unit", "sprocket", "gadget", "bomb", "revolution", "beyond", "station", "robot", "ivor", "hobnob")
	name += pick("ism", "ia", "ology", "istism", "ites", "ick", "ian", "ity")

	return capitalize(name)

proc/equalize_gases(datum/FEA_gas_mixture/list/gases)
	//Perfectly equalize all gases members instantly

	//Calculate totals from individual components
	var/total_volume = 0
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0

	var/total_oxygen = 0
	var/total_nitrogen = 0
	var/total_toxins = 0
	var/total_carbon_dioxide = 0

	var/list/total_trace_gases = list()

	for(var/datum/FEA_gas_mixture/gas in gases)
		total_volume += gas.volume
		total_thermal_energy += gas.thermal_energy()
		total_heat_capacity += gas.heat_capacity()

		total_oxygen += gas.oxygen
		total_nitrogen += gas.nitrogen
		total_toxins += gas.toxins
		total_carbon_dioxide += gas.carbon_dioxide

		if(gas.trace_gases.len)
			for(var/datum/gas/trace_gas in gas.trace_gases)
				var/datum/gas/corresponding = locate(trace_gas.type) in total_trace_gases
				if(!corresponding)
					corresponding = new trace_gas.type()
					total_trace_gases += corresponding

				corresponding.moles += trace_gas.moles

	if(total_volume > 0)

		//Calculate temperature
		var/temperature = 0

		if(total_heat_capacity > 0)
			temperature = total_thermal_energy/total_heat_capacity

		//Update individual FEA_gas_mixtures by volume ratio
		for(var/datum/FEA_gas_mixture/gas in gases)
			gas.oxygen = total_oxygen*gas.volume/total_volume
			gas.nitrogen = total_nitrogen*gas.volume/total_volume
			gas.toxins = total_toxins*gas.volume/total_volume
			gas.carbon_dioxide = total_carbon_dioxide*gas.volume/total_volume

			gas.temperature = temperature

			if(total_trace_gases.len)
				for(var/datum/gas/trace_gas in total_trace_gases)
					var/datum/gas/corresponding = locate(trace_gas.type) in gas.trace_gases
					if(!corresponding)
						corresponding = new trace_gas.type()
						gas.trace_gases += corresponding

					corresponding.moles = trace_gas.moles*gas.volume/total_volume

	return 1


/*
	Relevant for all security level stuff:
	//0 = code green
	//1 = code blue
	//2 = code red
	//3 = code delta
*/

/proc/set_security_level(var/level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				world << "<font size=4 color='red'>Attention! Security level lowered to green</font>"
				world << "<font color='red'>[config.alert_desc_green]</font>"
				security_level = SEC_LEVEL_GREEN
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_green")
			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					world << "<font size=4 color='red'>Attention! Security level elevated to blue</font>"
					world << "<font color='red'>[config.alert_desc_blue_upto]</font>"
				else
					world << "<font size=4 color='red'>Attention! Security level lowered to blue</font>"
					world << "<font color='red'>[config.alert_desc_blue_downto]</font>"
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_blue")
			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					world << "<font size=4 color='red'>Attention! Code red!</font>"
					world << "<font color='red'>[config.alert_desc_red_upto]</font>"
				else
					world << "<font size=4 color='red'>Attention! Code red!</font>"
					world << "<font color='red'>[config.alert_desc_red_downto]</font>"
				security_level = SEC_LEVEL_RED

				/*	- At the time of commit, setting status displays didn't work properly
				var/obj/machinery/computer/communications/CC = locate(/obj/machinery/computer/communications,world)
				if(CC)
					CC.post_status("alert", "redalert")*/

				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_red")

				// trigger a response team
				spawn
					sleep(100)
					if(security_level == SEC_LEVEL_RED) trigger_armed_response_team()
			if(SEC_LEVEL_DELTA)
				world << "<font size=4 color='red'>Attention! Delta security level reached!</font>"
				world << "<font color='red'>[config.alert_desc_delta]</font>"
				security_level = SEC_LEVEL_DELTA
				for(var/obj/machinery/firealarm/FA in world)
					if(FA.z == 1)
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_delta")
	else
		return

/proc/get_security_level()
	switch(security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(var/num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(var/seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("delta")
			return SEC_LEVEL_DELTA

//  /proc/select_recipe(list/datum/recipe/available_recipes, obj/obj as obj, exact = 1)
//    Wonderful function that selects suitable recipe for you.
//    obj is a machine (or magik hat) with prerequisites,
//    exact = 0 forces algorithm to ignore superfluous stuff.

/proc/select_recipe(var/list/datum/recipe/available_recipes, var/obj/obj as obj, var/exact = 1 as num)
	if (!exact)
		exact = -1
	var/list/datum/recipe/possible_recipes = new
	for (var/datum/recipe/recipe in available_recipes)
		if (recipe.check_reagents(obj.reagents)==exact && recipe.check_items(obj)==exact)
			possible_recipes+=recipe
	if (possible_recipes.len==0)
		return null
	else if (possible_recipes.len==1)
		return possible_recipes[1]
	else //okay, let's select the most complicated recipe
		var/r_count = 0
		var/i_count = 0
		. = possible_recipes[1]
		for (var/datum/recipe/recipe in possible_recipes)
			var/N_i = (recipe.items)?(recipe.items.len):0
			var/N_r = (recipe.reagents)?(recipe.reagents.len):0
			if (N_i > i_count || (N_i== i_count && N_r > r_count ))
				r_count = N_r
				i_count = N_i
				. = recipe
		return .

//returns the north-zero clockwise angle in degrees, given a direction

/proc/dir2angle(var/D)
	switch(D)
		if(1)
			return 0
		if(2)
			return 180
		if(4)
			return 90
		if(8)
			return 270
		if(5)
			return 45
		if(6)
			return 135
		if(9)
			return 315
		if(10)
			return 225
		else
			return null

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

/proc/do_teleport(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
	new /datum/teleport/instant/science(arglist(args))
	return

/proc/do_teleport_stealth(ateleatom, adestination, aprecision=0, afteleport=1, aeffectin=null, aeffectout=null, asoundin=null, asoundout=null)
	new /datum/teleport/instant(arglist(args))
	return

/proc/get_access(job)
	switch(job)
		if("Geneticist")
			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MEDLAB)
		if("Station Engineer")
			return list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION)
		if("Assistant")
			return list()
		if("Chaplain")
			return list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM)
		if("Detective")
			return list(ACCESS_SECURITY, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT)
		if("Medical Doctor")
			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_VIROLOGY)
		if("Botanist")	// -- TLE
			return list(ACCESS_HYDROPONICS) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT
		if("Librarian") // -- TLE
			return list(ACCESS_LIBRARY)
		if("Lawyer") //Muskets 160910
			return list(ACCESS_LAWYER, ACCESS_COURT)
		if("Captain")
			return get_all_accesses()
		if("Security Officer")
			return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS)
		if("Warden")
			return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS)
		if("Scientist")
			return list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY)
		if("Head of Security")
			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_MEDLAB, ACCESS_COURT,
			            ACCESS_TELEPORTER, ACCESS_HEADS, ACCESS_TECH_STORAGE, ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ATMOSPHERICS,
			            ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_KITCHEN, ACCESS_ROBOTICS, ACCESS_ARMORY, ACCESS_HYDROPONICS,
			            ACCESS_THEATRE, ACCESS_RESEARCH, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_FORENSICS_LOCKERS, ACCESS_KEYCARD_AUTH)
		if("Head of Personnel")
			return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
			            ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_MEDICAL, ACCESS_MEDLAB, ACCESS_ENGINE,
			            ACCESS_EMERGENCY_STORAGE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_ROBOTICS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            ACCESS_THEATRE, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
			            ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH)
		if("Atmospheric Technician")
			return list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EMERGENCY_STORAGE)
		if("Bartender")
			return list(ACCESS_BAR)
		if("Chemist")
			return list(ACCESS_MEDICAL, ACCESS_CHEMISTRY)
		if("Janitor")
			return list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS)
		if("Clown")
			return list(ACCESS_CLOWN, ACCESS_THEATRE)
		if("Mime")
			return list(ACCESS_MIME, ACCESS_THEATRE)
		if("Chef")
			return list(ACCESS_KITCHEN)
		if("Roboticist")
			return list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS)
		if("Cargo Technician")
			return list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING)
		if("Shaft Miner")
			return list(ACCESS_MINING, ACCESS_MINT, ACCESS_MINING_STATION)
		if("Quartermaster")
			return list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING)
		if("Chief Engineer")
			return list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
			            ACCESS_HEADS, ACCESS_AI_UPLOAD, ACCESS_CONSTRUCTION, ACCESS_ROBOTICS,
			            ACCESS_MINT, ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT)
		if("Research Director")
			return list(ACCESS_MEDLAB, ACCESS_RD,
			            ACCESS_HEADS, ACCESS_TOX,
			            ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_TELEPORTER,
			            ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_RC_ANNOUNCE,
			            ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT)
		/*if("Virologist")
			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_VIROLOGY)*/
		if("Chief Medical Officer")
			return list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MEDLAB, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH)
		else
			return list()

/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(ACCESS_CENT_GENERAL)
		if("Custodian")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("Thunderdome Overseer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER)
		if("Intel Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING)
		if("Medical Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_LIVING, ACCESS_CENT_MEDICAL)
		if("Death Commando")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE)
		if("Research Officer")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_TELEPORTED, ACCESS_CENT_STORAGE)
		if("BlackOps Commander")
			return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE, ACCESS_CENT_CREED)
		if("Supreme Commander")
			return get_all_centcom_access()

/proc/get_all_accesses()
	return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT,
	            ACCESS_MEDICAL, ACCESS_MEDLAB, ACCESS_MORGUE, ACCESS_RD,
	            ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS,
	            ACCESS_EXTERNAL_AIRLOCKS, ACCESS_EMERGENCY_STORAGE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD,
	            ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_ALL_PERSONAL_LOCKERS,
	            ACCESS_TECH_STORAGE, ACCESS_CHAPEL_OFFICE, ACCESS_ATMOSPHERICS, ACCESS_KITCHEN,
	            ACCESS_BAR, ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_ROBOTICS, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_CONSTRUCTION,
	            ACCESS_HYDROPONICS, ACCESS_LIBRARY, ACCESS_MANUFACTURING, ACCESS_LAWYER, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_QM, ACCESS_CLOWN, ACCESS_MIME, ACCESS_SURGERY,
	            ACCESS_THEATRE, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_MAILSORTING, ACCESS_MINT_VAULT, ACCESS_MINT,
	            ACCESS_HEADS_VAULT, ACCESS_MINING_STATION, ACCESS_XENOBIOLOGY, ACCESS_CE, ACCESS_HOP, ACCESS_HOS, ACCESS_RC_ANNOUNCE,
	            ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT)

/proc/get_all_centcom_access()
	return list(ACCESS_CENT_GENERAL, ACCESS_CENT_THUNDER, ACCESS_CENT_SPECOPS, ACCESS_CENT_MEDICAL, ACCESS_CENT_LIVING, ACCESS_CENT_STORAGE, ACCESS_CENT_TELEPORTED, ACCESS_CENT_CREED, ACCESS_CENT_CAPTAIN)

/proc/get_all_syndicate_access()
	return list(ACCESS_SYNDICATE)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //security
			return list(ACCESS_SECURITY, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, ACCESS_COURT, ACCESS_HOS)
		if(2) //medbay
			return list(ACCESS_MEDICAL, ACCESS_MEDLAB, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY)
		if(3) //research
			return list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RD, ACCESS_HYDROPONICS, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY)
		if(4) //engineering and maintenance
			return list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_EMERGENCY_STORAGE, ACCESS_TECH_STORAGE, ACCESS_ATMOSPHERICS, ACCESS_CONSTRUCTION, ACCESS_ROBOTICS, ACCESS_CE)
		if(5) //command
			return list(ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MINT_VAULT, ACCESS_HEADS_VAULT, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT)
		if(6) //station general
			return list(ACCESS_CHAPEL_OFFICE, ACCESS_KITCHEN,ACCESS_BAR, ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_LIBRARY, ACCESS_THEATRE, ACCESS_LAWYER, ACCESS_CLOWN, ACCESS_MIME)
		if(7) //supply
			return list(ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MINT)

/proc/get_region_accesses_name(var/code)
	switch(code)
		if(0)
			return "All"
		if(1) //security
			return "Security"
		if(2) //medbay
			return "Medbay"
		if(3) //research
			return "Research"
		if(4) //engineering and maintenance
			return "Engineering"
		if(5) //command
			return "Command"
		if(6) //station general
			return "Station General"
		if(7) //supply
			return "Supply"


/proc/get_access_desc(A)
	switch(A)
		if(ACCESS_CARGO)
			return "Cargo Bay"
		if(ACCESS_CARGO_BOT)
			return "Cargo Bot Delivery"
		if(ACCESS_SECURITY)
			return "Security"
		if(ACCESS_BRIG)
			return "Brig"
		if(ACCESS_COURT)
			return "Courtroom"
		if(ACCESS_FORENSICS_LOCKERS)
			return "Forensics"
		if(ACCESS_MEDICAL)
			return "Medical"
		if(ACCESS_MEDLAB)
			return "Med-Sci"
		if(ACCESS_MORGUE)
			return "Morgue"
		if(ACCESS_TOX)
			return "Toxins Research"
		if(ACCESS_TOX_STORAGE)
			return "Toxins Storage"
		if(ACCESS_CHEMISTRY)
			return "Toxins Chemical Lab"
		if(ACCESS_RD)
			return "RD Private"
		if(ACCESS_BAR)
			return "Bar"
		if(ACCESS_JANITOR)
			return "Janitorial Equipment"
		if(ACCESS_ENGINE)
			return "Engineering"
		if(ACCESS_ENGINE_EQUIP)
			return "APCs"
		if(ACCESS_MAINT_TUNNELS)
			return "Maintenance"
		if(ACCESS_EXTERNAL_AIRLOCKS)
			return "External Airlock"
		if(ACCESS_EMERGENCY_STORAGE)
			return "Emergency Storage"
		if(ACCESS_CHANGE_IDS)
			return "ID Computer"
		if(ACCESS_AI_UPLOAD)
			return "AI Upload"
		if(ACCESS_TELEPORTER)
			return "Teleporter"
		if(ACCESS_EVA)
			return "EVA"
		if(ACCESS_HEADS)
			return "Head's Quarters/Bridge"
		if(ACCESS_CAPTAIN)
			return "Captain's Quarters"
		if(ACCESS_ALL_PERSONAL_LOCKERS)
			return "Personal Locker"
		if(ACCESS_CHAPEL_OFFICE)
			return "Chapel Office"
		if(ACCESS_TECH_STORAGE)
			return "Technical Storage"
		if(ACCESS_ATMOSPHERICS)
			return "Atmospherics"
		if(ACCESS_CREMATORIUM)
			return "Crematorium"
		if(ACCESS_ARMORY)
			return "Armory"
		if(ACCESS_CONSTRUCTION)
			return "Construction Site"
		if(ACCESS_KITCHEN)
			return "Kitchen"
		if(ACCESS_HYDROPONICS)
			return "Hydroponics"
		if(ACCESS_LIBRARY)
			return "Library"
		if(ACCESS_LAWYER)
			return "Law Office"
		if(ACCESS_ROBOTICS)
			return "Robotics"
		if(ACCESS_VIROLOGY)
			return "Virology"
		if(ACCESS_CMO)
			return "CMO Private"
		if(ACCESS_QM)
			return "Quartermaster's Office"
		if(ACCESS_CLOWN)
			return "HONK! Access"
		if(ACCESS_MIME)
			return "Silent Access"
		if(ACCESS_SURGERY)
			return "Operating Room"
		if(ACCESS_THEATRE)
			return "Theatre"
		if(ACCESS_MANUFACTURING)
			return "Manufacturing"
		if(ACCESS_RESEARCH)
			return "Research"
		if(ACCESS_MINING)
			return "Mining"
		if(ACCESS_MINING_OFFICE)
			return "Mining Office"
		if(ACCESS_MAILSORTING)
			return "Delivery Office"
		if(ACCESS_MINT)
			return "Mint"
		if(ACCESS_MINT_VAULT)
			return "Mint Vault"
		if(ACCESS_HEADS_VAULT)
			return "Main Vault"
		if(ACCESS_MINING_STATION)
			return "Mining Station"
		if(ACCESS_XENOBIOLOGY)
			return "Xenobiology"
		if(ACCESS_HOP)
			return "HoP Private"
		if(ACCESS_HOS)
			return "HoS Private"
		if(ACCESS_CE)
			return "CE Private"
		if(ACCESS_RC_ANNOUNCE)
			return "RC announcements"
		if(ACCESS_KEYCARD_AUTH)
			return "Keycode auth. device"
		if(ACCESS_TCOMSAT)
			return "Telecommunications Satellite"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(ACCESS_CENT_GENERAL)
			return "Code Grey"
		if(ACCESS_CENT_THUNDER)
			return "Code Yellow"
		if(ACCESS_CENT_STORAGE)
			return "Code Orange"
		if(ACCESS_CENT_LIVING)
			return "Code Green"
		if(ACCESS_CENT_MEDICAL)
			return "Code White"
		if(ACCESS_CENT_TELEPORTED)
			return "Code Blue"
		if(ACCESS_CENT_SPECOPS)
			return "Code Black"
		if(ACCESS_CENT_CREED)
			return "Code Silver"
		if(ACCESS_CENT_CAPTAIN)
			return "Code Gold"

/proc/get_all_jobs()
	return list("Assistant", "Station Engineer", "Shaft Miner", "Detective", "Medical Doctor", "Captain", "Security Officer", "Warden",
				"Geneticist", "Scientist", "Head of Security", "Head of Personnel", "Atmospheric Technician",
				"Chaplain", "Bartender", "Chemist", "Janitor", "Chef", "Roboticist", "Quartermaster",
				"Chief Engineer", "Research Director", "Botanist", "Librarian", "Lawyer", "Virologist", "Cargo Technician", "Chief Medical Officer")

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer","BlackOps Commander","Supreme Commander")

proc/process_teleport_locs()
	for(var/area/AR in world)
		if(istype(AR, /area/shuttle) || istype(AR, /area/syndicate_station) || istype(AR, /area/wizard_station)) continue
		if(teleport_locs.Find(AR.name)) continue
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == 1)
			teleport_locs += AR.name
			teleport_locs[AR.name] = AR

	var/not_in_order = 0
	do
		not_in_order = 0
		if(teleport_locs.len <= 1)
			break
		for(var/i = 1, i <= (teleport_locs.len - 1), i++)
			if(sorttext(teleport_locs[i], teleport_locs[i+1]) == -1)
				teleport_locs.Swap(i, i+1)
				not_in_order = 1
	while(not_in_order)

proc/process_ghost_teleport_locs()
	for(var/area/AR in world)
		if(ghost_teleport_locs.Find(AR.name)) continue
		if(istype(AR, /area/turret_protected/aisat) || istype(AR, /area/derelict) || istype(AR, /area/tdome))
			ghost_teleport_locs += AR.name
			ghost_teleport_locs[AR.name] = AR
		var/turf/picked = pick(get_area_turfs(AR.type))
		if (picked.z == 1 || picked.z == 5 || picked.z == 3)
			ghost_teleport_locs += AR.name
			ghost_teleport_locs[AR.name] = AR

	var/not_in_order = 0
	do
		not_in_order = 0
		if(ghost_teleport_locs.len <= 1)
			break
		for(var/i = 1, i <= (ghost_teleport_locs.len - 1), i++)
			if(sorttext(ghost_teleport_locs[i], ghost_teleport_locs[i+1]) == -1)
				ghost_teleport_locs.Swap(i, i+1)
				not_in_order = 1
	while(not_in_order)

/proc/isassembly(O)
	if(istype(O, /obj/item/device/assembly))
		return 1
	return 0

/proc/isigniter(O)
	if(istype(O, /obj/item/device/assembly/igniter))
		return 1
	return 0

/proc/isprox(O)
	if(istype(O, /obj/item/device/assembly/proximity_sensor))
		return 1
	return 0

/proc/issignaler(O)
	if(istype(O, /obj/item/device/assembly/signaler))
		return 1
	return 0

/proc/GenerateTheft(var/job,var/datum/mind/traitor)
	var/list/datum/objective/objectives = list()
	var/list/weight = list()
	var/index = 1

	for(var/o in typesof(/datum/objective/steal))
		if(o != /datum/objective/steal)		//Make sure not to get a blank steal objective.
			var/datum/objective/target = new o(null,job)
			weight += list("[index]" = target.weight)
			objectives += target
			index++
	return list(objectives, weight)

/proc/GenerateAssassinate(var/job,var/datum/mind/traitor)
	var/list/datum/objective/assassinate/missions = list()
	var/list/weight = list()
	var/index = 1

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				var/datum/objective/target_obj = new /datum/objective/assassinate(null,job,target)
				weight += list("[index]" = target_obj.weight)
				missions += target_obj
				index++
	return list(missions, weight)

/proc/GenerateFrame(var/job,var/datum/mind/traitor)
	var/list/datum/objective/frame/missions = list()
	var/list/weight = list()
	var/index = 1

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				var/datum/objective/target_obj = new /datum/objective/frame(null,job,target)
				weight += list("[index]" = target_obj.weight)
				missions += target_obj
				index++
	return list(missions, weight)

/proc/GenerateProtection(var/job,var/datum/mind/traitor)
	var/list/datum/objective/frame/missions = list()
	var/list/weight = list()
	var/index = 1

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				var/datum/objective/target_obj = new /datum/objective/protection(null,job,target)
				weight += list("[index]" = target_obj.weight)
				missions += target_obj
				index++
	return list(missions, weight)

/proc/PickObjectiveFromList(var/list/objectivesArray)
	var/list/datum/objectives = objectivesArray[1]
	var/pick_index = text2num(pickweight(objectivesArray[2]))
	if (pick_index > objectives.len || pick_index < 1)
		log_admin("Objective picking failed. Error logged. One or more traitors will need to be manually-assigned objectives. Pick_index was [pick_index].  Tell Sky.")
		message_admins("Objective picking failed. Error logged. One or more traitors will need to be manually-assigned objectives. Pick_index was [pick_index]. Tell Sky.")
		CRASH("Objective picking failed. Pick_index was [pick_index].")

	return objectives[pick_index]

/proc/RemoveObjectiveFromList(var/list/objectiveArray, var/datum/objective/objective)
	var/list/datum/objective/temp = objectiveArray[1]
	var/list/weight = objectiveArray[2]
	var/index = temp.Find(objective)
	if(index == temp.len)
		temp.Cut(index)
		weight.Cut(index)
	else
		temp.Cut(index, index+1)
		weight.Cut(index, index+1)
	return list(temp,weight)

/proc/SelectObjectives(var/job,var/datum/mind/traitor,var/hijack = 0)
	var/list/chosenobjectives = list()
	var/list/theftobjectives = GenerateTheft(job,traitor)		//Separated all the objective types so they can be picked independantly of each other.
	var/list/killobjectives = GenerateAssassinate(job,traitor)
	var/list/frameobjectives = GenerateFrame(job,traitor)
	var/list/protectobjectives = GenerateProtection(job,traitor)
	//var/points
	var/totalweight
	var/selectobj
	var/conflict

	while(totalweight < 100)
		selectobj = rand(1,100)	//Randomly determine the type of objective to be given.
		if(!length(killobjectives[1]) || !length(protectobjectives[1])|| !length(frameobjectives[1]))	//If any of these lists are empty, just give them theft objectives.
			var/datum/objective/objective = PickObjectiveFromList(theftobjectives)
			chosenobjectives += objective
			totalweight += objective.points
			theftobjectives = RemoveObjectiveFromList(theftobjectives, objective)
		else switch(selectobj)
			if(1 to 55)		//Theft Objectives (55% chance)
				var/datum/objective/objective = PickObjectiveFromList(theftobjectives)
				for(1 to 10)
					if(objective.points + totalweight <= 100)
						break
					objective = PickObjectiveFromList(theftobjectives)
				chosenobjectives += objective
				totalweight += objective.points
				theftobjectives = RemoveObjectiveFromList(theftobjectives, objective)
			if(56 to 92)	//Assassination Objectives (37% chance)
				var/datum/objective/assassinate/objective = PickObjectiveFromList(killobjectives)
				world << objective
				for(1 to 10)
					if(objective.points + totalweight <= 100)
						break
					objective = PickObjectiveFromList(killobjectives)
				if(!objective)
					continue
				for(var/datum/objective/protection/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Assassinate somebody they need to Protect.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				for(var/datum/objective/frame/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				if(!conflict)
					chosenobjectives += objective
					totalweight += objective.points
					killobjectives = RemoveObjectiveFromList(killobjectives, objective)
				conflict = 0
			if(93 to 95)	//Framing Objectives (3% chance)
				var/datum/objective/objective = PickObjectiveFromList(frameobjectives)
				for(1 to 10)
					if(objective.points + totalweight <= 100)
						break
					objective = PickObjectiveFromList(frameobjectives)
				if(!objective)
					continue
				for(var/datum/objective/protection/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Assassinate somebody they need to Protect.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				for(var/datum/objective/assassinate/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				if(!conflict)
					chosenobjectives += objective
					totalweight += objective.points
					frameobjectives = RemoveObjectiveFromList(frameobjectives, objective)
				conflict = 0
			if(96 to 100)	//Protection Objectives (5% chance)
				var/datum/objective/protection/objective = PickObjectiveFromList(protectobjectives)
				for(1 to 10)
					if(objective.points + totalweight <= 100)
						break
					objective = PickObjectiveFromList(protectobjectives)
				if(!objective)
					continue
				for(var/datum/objective/assassinate/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				for(var/datum/objective/frame/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
						break
				if(!conflict)
					chosenobjectives += objective
					totalweight += objective.points
					protectobjectives = RemoveObjectiveFromList(protectobjectives, objective)
				conflict = 0

	var/hasendgame = 0
	for(var/datum/objective/o in chosenobjectives)
		if(o.type == /datum/objective/hijack || o.type == /datum/objective/escape)
			hasendgame = 1
			break
	for(var/datum/objective/o in chosenobjectives)
		if(o.explanation_text == "Free Objective")
			del(o) //Cleaning up any sillies.
	if(hasendgame == 0)
		if(hijack)
			chosenobjectives += new /datum/objective/hijack(null,job)
		else
			chosenobjectives += new /datum/objective/escape(null,job)
	return chosenobjectives

/proc/setupgenetics()

	if (prob(50))
		BLOCKADD = rand(-300,300)
	if (prob(75))
		DIFFMUT = rand(0,20)

	var/list/avnums = list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26)
	var/tempnum

	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	HULKBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	TELEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	FIREBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	XRAYBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	CLUMSYBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	FAKEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	DEAFBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	BLINDBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	HEADACHEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	COUGHBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	TWITCHBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	NERVOUSBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	NOBREATHBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	REMOTEVIEWBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	REGENERATEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	INCREASERUNBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	REMOTETALKBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	MORPHBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	BLENDBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	HALLUCINATIONBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	NOPRINTSBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	SHOCKIMMUNITYBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	SMALLSIZEBLOCK = tempnum
	tempnum = pick(avnums)
	avnums.Remove(tempnum)
	GLASSESBLOCK = tempnum


	// HIDDEN MUTATIONS / SUPERPOWERS INITIALIZTION

	for(var/x in typesof(/datum/mutations) - /datum/mutations)
		var/datum/mutations/mut = new x

		for(var/i = 1, i <= mut.required, i++)
			var/datum/mutationreq/require = new/datum/mutationreq
			require.block = rand(1, 13)
			require.subblock = rand(1, 3)

			// Create random requirement identification
			require.reqID = pick("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", \
							 "B", "C", "D", "E", "F")

			mut.requirements += require


		global_mutations += mut// add to global mutations list!






/* This was used for something before, I think, but is not worth the effort to process now.
/proc/setupcorpses()
	for (var/obj/effect/landmark/A in world)
		if (A.name == "Corpse")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			del(A)
			continue
		if (A.name == "Corpse-Engineer")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/device/pda/engineering(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/rank/engineer(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/orange(M), M.slot_shoes)
		//	M.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/clothing/gloves/yellow(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/t_scanner(M), M.slot_r_store)
			//M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/mask/gas(M), M.slot_wear_mask)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(M), M.slot_head)
			else
				if (prob(50))
					M.equip_if_possible(new /obj/item/clothing/head/helmet/welding(M), M.slot_head)
			del(A)
			continue
		if (A.name == "Corpse-Engineer-Space")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/weapon/tank/emergency_oxygen(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/rank/engineer(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/orange(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/suit/space(M), M.slot_wear_suit)
		//	M.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/clothing/gloves/yellow(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/t_scanner(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/clothing/mask/gas(M), M.slot_wear_mask)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(M), M.slot_head)
			else
				if (prob(50))
					M.equip_if_possible(new /obj/item/clothing/head/helmet/welding(M), M.slot_head)
				else
					M.equip_if_possible(new /obj/item/clothing/head/helmet/space(M), M.slot_head)
			del(A)
			continue
		if (A.name == "Corpse-Engineer-Chief")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_if_possible(new /obj/item/device/radio/headset/headset_eng(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/weapon/storage/utilitybelt(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/rank/chief_engineer(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/orange(M), M.slot_shoes)
		//	M.equip_if_possible(new /obj/item/weapon/storage/toolbox/mechanical(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/clothing/gloves/yellow(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/t_scanner(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/mask/gas(M), M.slot_wear_mask)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/head/helmet/hardhat(M), M.slot_head)
			else
				if (prob(50))
					M.equip_if_possible(new /obj/item/clothing/head/helmet/welding(M), M.slot_head)
			del(A)
			continue
		if (A.name == "Corpse-Syndicate")
			var/mob/living/carbon/human/M = new /mob/living/carbon/human(A.loc)
			M.real_name = "Corpse"
			M.death()
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			//M.equip_if_possible(new /obj/item/weapon/gun/revolver(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/syndicate(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/swat(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/weapon/tank/jetpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/clothing/mask/gas(M), M.slot_wear_mask)
			if (prob(50))
				M.equip_if_possible(new /obj/item/clothing/suit/space/syndicate(M), M.slot_wear_suit)
				if (prob(50))
					M.equip_if_possible(new /obj/item/clothing/head/helmet/swat(M), M.slot_head)
				else
					M.equip_if_possible(new /obj/item/clothing/head/helmet/space/syndicate(M), M.slot_head)
			else
				M.equip_if_possible(new /obj/item/clothing/suit/armor/vest(M), M.slot_wear_suit)
				M.equip_if_possible(new /obj/item/clothing/head/helmet/swat(M), M.slot_head)
			del(A)
			continue
*/

/proc/iscultist(mob/living/carbon/M as mob)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.cult)

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))	return 0
/*	if(istype(mind.current, /mob/living/carbon/human) && (mind.assigned_role in list("Captain", "Head of Security", "Security Officer", "Detective", "Chaplain", "Warden")))	return 0
	for(var/obj/item/weapon/implant/loyalty/L in mind.current)
		if(L && L.implanted)
			return 0*/
	return 1


/proc/nukelastname(var/mob/M as mob) //--All praise goes to NEO|Phyte, all blame goes to DH, and it was Cindi-Kate's idea. Also praise Urist for copypasta ho.
	var/randomname = pick(last_names)
	var/newname = input(M,"You are the nuke operative [pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")]. Please choose a last name for your family.", "Name change",randomname)

	if (length(newname) == 0)
		newname = randomname

	if (newname)
		if (newname == "Unknown")
			M << "That name is reserved."
			return nukelastname(M)
		if (length(newname) >= 26)
			newname = copytext(newname, 1, 26)
		newname = dd_replacetext(newname, ">", "'")

	return newname

/proc/NukeNameAssign(var/lastname,var/list/syndicates)
	for(var/datum/mind/synd_mind in syndicates)
		switch(synd_mind.current.gender)
			if("male")
				synd_mind.current.real_name = "[pick(first_names_male)] [lastname]"
			if("female")
				synd_mind.current.real_name = "[pick(first_names_female)] [lastname]"

	return
/proc/is_convertable_to_rev(datum/mind/mind)
	return istype(mind) && \
		istype(mind.current, /mob/living/carbon/human) && \
		!(mind.assigned_role in command_positions) && \
		!(mind.assigned_role in list("Security Officer", "Detective", "Warden"))

/proc/spell_jaunt(var/mob/H, time = 50)
	if(H.stat) return
	spawn(0)
		var/mobloc = get_turf(H.loc)
		var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
		var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
		animation.name = "water"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "liquify"
		animation.layer = 5
		animation.master = holder
		flick("liquify",animation)
		H.loc = holder
		H.client.eye = holder
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, mobloc)
		steam.start()
		sleep(time)
		mobloc = get_turf(H.loc)
		animation.loc = mobloc
		steam.location = mobloc
		steam.start()
		H.canmove = 0
		sleep(20)
		flick("reappear",animation)
		sleep(5)
		H.loc = mobloc
		H.canmove = 1
		H.client.eye = H
		del(animation)
		del(holder)
/*
/obj/effect/dummy/spell_jaunt
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1

/obj/effect/dummy/spell_jaunt/relaymove(var/mob/user, direction)
	if (!src.canmove) return
	switch(direction)
		if(NORTH)
			src.y++
		if(SOUTH)
			src.y--
		if(EAST)
			src.x++
		if(WEST)
			src.x--
		if(NORTHEAST)
			src.y++
			src.x++
		if(NORTHWEST)
			src.y++
			src.x--
		if(SOUTHEAST)
			src.y--
			src.x++
		if(SOUTHWEST)
			src.y--
			src.x--
	src.canmove = 0
	spawn(2) src.canmove = 1

/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return
/obj/effect/dummy/spell_jaunt/bullet_act(blah,blah)
	return
*/
//MUTATE

proc/make_mining_asteroid_secret(var/size = 5)
	var/valid = 0
	var/turf/T = null
	var/sanity = 0
	var/list/room = null
	var/list/turfs = null


	turfs = get_area_turfs(/area/mine/unexplored)

	if(!turfs.len)
		return 0

	while(!valid)
		valid = 1
		sanity++
		if(sanity > 100)
			return 0

		T=pick(turfs)
		if(!T)
			return 0

		var/list/surroundings = list()

		surroundings += range(7, locate(T.x,T.y,T.z))
		surroundings += range(7, locate(T.x+size,T.y,T.z))
		surroundings += range(7, locate(T.x,T.y+size,T.z))
		surroundings += range(7, locate(T.x+size,T.y+size,T.z))

		if(locate(/area/mine/explored) in surroundings)			// +5s are for view range
			valid = 0
			continue

		if(locate(/turf/space) in surroundings)
			valid = 0
			continue

		if(locate(/area/asteroid/artifactroom) in surroundings)
			valid = 0
			continue

		if(locate(/turf/simulated/floor/plating/airless/asteroid) in surroundings)
			valid = 0
			continue

	if(!T)
		return 0

	room = spawn_room(T,size,size,,,1)

	if(room)
		T = pick(room["floors"])
		if(T)
			var/surprise = null
			valid = 0
			while(!valid)
				surprise = pickweight(space_surprises)
				if(surprise in spawned_surprises)
					if(prob(20))
						valid++
					else
						continue
				else
					valid++

			spawned_surprises.Add(surprise)
			new surprise(T)

	return 1

proc/spawn_room(var/atom/start_loc,var/x_size,var/y_size,var/wall,var/floor , var/clean = 0 , var/name)
	var/list/room_turfs = list("walls"=list(),"floors"=list())

	//world << "Room spawned at [start_loc.x],[start_loc.y],[start_loc.z]"
	if(!wall)
		wall = pick(/turf/simulated/wall/r_wall,/turf/simulated/wall,/obj/effect/alien/resin)
	if(!floor)
		floor = pick(/turf/simulated/floor,/turf/simulated/floor/engine)

	for(var/x = 0,x<x_size,x++)
		for(var/y = 0,y<y_size,y++)
			var/turf/T
			var/cur_loc = locate(start_loc.x+x,start_loc.y+y,start_loc.z)
			if(clean)
				for(var/O in cur_loc)
					del(O)

			var/area/asteroid/artifactroom/A = new
			if(name)
				A.name = name
			else
				A.name = "Artifact Room #[start_loc.x][start_loc.y][start_loc.z]"



			if(x == 0 || x==x_size-1 || y==0 || y==y_size-1)
				if(wall == /obj/effect/alien/resin)
					T = new floor(cur_loc)
					new /obj/effect/alien/resin(T)
				else
					T = new wall(cur_loc)
					room_turfs["walls"] += T
			else
				T = new floor(cur_loc)
				room_turfs["floors"] += T

			A.contents += T


	return room_turfs

/proc/CanReachThrough(turf/srcturf, turf/targetturf, atom/target)
	var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( srcturf )

	if(targetturf.density && targetturf != get_turf(target))
		return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in srcturf)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CheckExit(D, targetturf))
				del D
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in targetturf)
		if((border_obstacle.flags & ON_BORDER) && (target != border_obstacle))
			if(!border_obstacle.CanPass(D, srcturf, 1, 0))
				del D
				return 0

	del D
	return 1

/*
  HOW IT WORKS

  The radio_controller is a global object maintaining all radio transmissions, think about it as about "ether".
  Note that walkie-talkie, intercoms and headsets handle transmission using nonstandard way.
  procs:

    add_object(obj/device as obj, var/new_frequency as num, var/filter as text|null = null)
      Adds listening object.
      parameters:
        device - device receiving signals, must have proc receive_signal (see description below).
          one device may listen several frequencies, but not same frequency twice.
        new_frequency - see possibly frequencies below;
        filter - thing for optimization. Optional, but recommended.
                 All filters should be consolidated in this file, see defines later.
                 Device without listening filter will receive all signals (on specified frequency).
                 Device with filter will receive any signals sent without filter.
                 Device with filter will not receive any signals sent with different filter.
      returns:
       Reference to frequency object.

    remove_object (obj/device, old_frequency)
      Obliviously, after calling this proc, device will not receive any signals on old_frequency.
      Other frequencies will left unaffected.

   return_frequency(var/frequency as num)
      returns:
       Reference to frequency object. Use it if you need to send and do not need to listen.

  radio_frequency is a global object maintaining list of devices that listening specific frequency.
  procs:

    post_signal(obj/source as obj|null, datum/signal/signal, var/filter as text|null = null, var/range as num|null = null)
      Sends signal to all devices that wants such signal.
      parameters:
        source - object, emitted signal. Usually, devices will not receive their own signals.
        signal - see description below.
        filter - described above.
        range - radius of regular byond's square circle on that z-level. null means everywhere, on all z-levels.

  obj/proc/receive_signal(datum/signal/signal, var/receive_method as num, var/receive_param)
    Handler from received signals. By default does nothing. Define your own for your object.
    Avoid of sending signals directly from this proc, use spawn(-1). Do not use sleep() here please.
      parameters:
        signal - see description below. Extract all needed data from the signal before doing sleep(), spawn() or return!
        receive_method - may be TRANSMISSION_WIRE or TRANSMISSION_RADIO.
          TRANSMISSION_WIRE is currently unused.
        receive_param - for TRANSMISSION_RADIO here comes frequency.

  datum/signal
    vars:
    source
      an object that emitted signal. Used for debug and bearing.
    data
      list with transmitting data. Usual use pattern:
        data["msg"] = "hello world"
    encryption
      Some number symbolizing "encryption key".
      Note that game actually do not use any cryptography here.
      If receiving object don't know right key, it must ignore encrypted signal in its receive_signal.

*/

/*
Frequency range: 1200 to 1600
Radiochat range: 1441 to 1489 (most devices refuse to be tune to other frequency, even during mapmaking)

Radio:
1459 - standard radio chat
1351 - Science
1353 - Command
1355 - Medical
1357 - Engineering
1359 - Security
1441 - death squad
1443 - Confession Intercom
1349 - Miners
1347 - Cargo techs

Devices:
1451 - tracking implant
1457 - RSD default

On the map:
1311 for prison shuttle console (in fact, it is not used)
1435 for status displays
1437 for atmospherics/fire alerts
1439 for engine components
1439 for air pumps, air scrubbers, atmo control
1441 for atmospherics - supply tanks
1443 for atmospherics - distribution loop/mixed air tank
1445 for bot nav beacons
1447 for mulebot, secbot and ed209 control
1449 for airlock controls, electropack, magnets
1451 for toxin lab access
1453 for engineering access
1455 for AI access
*/

/proc/radioalert(var/message,var/from)
	var/obj/item/device/radio/intercom/a = new /obj/item/device/radio/intercom(null)
	a.autosay(message,from)

/////////////////////////// DNA HELPER-PROCS
/proc/getleftblocks(input,blocknumber,blocksize)
	var/string

	if (blocknumber > 1)
		string = copytext(input,1,((blocksize*blocknumber)-(blocksize-1)))
		return string
	else
		return null

/proc/getrightblocks(input,blocknumber,blocksize)
	var/string
	if (blocknumber < (length(input)/blocksize))
		string = copytext(input,blocksize*blocknumber+1,length(input)+1)
		return string
	else
		return null

/proc/getblock(input,blocknumber,blocksize)
	var/result
	result = copytext(input ,(blocksize*blocknumber)-(blocksize-1),(blocksize*blocknumber)+1)
	return result

/proc/getblockbuffer(input,blocknumber,blocksize)
	var/result[3]
	var/block = copytext(input ,(blocksize*blocknumber)-(blocksize-1),(blocksize*blocknumber)+1)
	for(var/i = 1, i <= 3, i++)
		result[i] = copytext(block, i, i+1)
	return result

/proc/setblock(istring, blocknumber, replacement, blocksize)
	if(!istring || !blocknumber || !replacement || !blocksize)	return 0
	var/result = getleftblocks(istring, blocknumber, blocksize) + replacement + getrightblocks(istring, blocknumber, blocksize)
	return result

/proc/add_zero2(t, u)
	var/temp1
	while (length(t) < u)
		t = "0[t]"
	temp1 = t
	if (length(t) > u)
		temp1 = copytext(t,2,u+1)
	return temp1

/proc/miniscramble(input,rs,rd)
	var/output
	output = null
	if (input == "C" || input == "D" || input == "E" || input == "F")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"6",prob((rs*10));"7",prob((rs*5)+(rd));"0",prob((rs*5)+(rd));"1",prob((rs*10)-(rd));"2",prob((rs*10)-(rd));"3")
	if (input == "8" || input == "9" || input == "A" || input == "B")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "4" || input == "5" || input == "6" || input == "7")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "0" || input == "1" || input == "2" || input == "3")
		output = pick(prob((rs*10));"8",prob((rs*10));"9",prob((rs*10));"A",prob((rs*10));"B",prob((rs*10)-(rd));"C",prob((rs*10)-(rd));"D",prob((rs*5)+(rd));"E",prob((rs*5)+(rd));"F")
	if (!output) output = "5"
	return output

/proc/isblockon(hnumber, bnumber)
	var/temp2
	temp2 = hex2num(hnumber)
	if (bnumber == HULKBLOCK || bnumber == TELEBLOCK)
		if (temp2 >= 3500 + BLOCKADD)
			return 1
		else
			return 0
	if (bnumber == XRAYBLOCK || bnumber == FIREBLOCK)
		if (temp2 >= 3050 + BLOCKADD)
			return 1
		else
			return 0
	if (temp2 >= 2050 + BLOCKADD)
		return 1
	else
		return 0

/proc/randmutb(mob/M as mob)
	if(!M)	return
	var/num
	var/newdna
	num = pick(GLASSESBLOCK,COUGHBLOCK,FAKEBLOCK,NERVOUSBLOCK,CLUMSYBLOCK,TWITCHBLOCK,HEADACHEBLOCK,BLINDBLOCK,DEAFBLOCK)
	M.dna.check_integrity()
	newdna = setblock(M.dna.struc_enzymes,num,toggledblock(getblock(M.dna.struc_enzymes,num,3)),3)
	M.dna.struc_enzymes = newdna
	return

/proc/randmutg(mob/M as mob)
	if(!M)	return
	var/num
	var/newdna
	num = pick(HULKBLOCK,XRAYBLOCK,FIREBLOCK,TELEBLOCK)
	M.dna.check_integrity()
	newdna = setblock(M.dna.struc_enzymes,num,toggledblock(getblock(M.dna.struc_enzymes,num,3)),3)
	M.dna.struc_enzymes = newdna
	return

/proc/scramble(var/type, mob/M as mob, var/p)
	if(!M)	return
	M.dna.check_integrity()
	if(type)
		for(var/i = 1, i <= 26, i++)
			if(prob(p))
				M.dna.uni_identity = setblock(M.dna.uni_identity, i, add_zero2(num2hex(rand(1,4095), 1), 3), 3)
		updateappearance(M, M.dna.uni_identity)

	else
		for(var/i = 1, i <= 26, i++)
			if(prob(p))
				M.dna.struc_enzymes = setblock(M.dna.struc_enzymes, i, add_zero2(num2hex(rand(1,4095), 1), 3), 3)
		domutcheck(M, null)
	return

/proc/randmuti(mob/M as mob)
	if(!M)	return
	var/num
	var/newdna
	num = pick(1,2,3,4,5,6,7,8,9,10,11,12,13)
	M.dna.check_integrity()
	newdna = setblock(M.dna.uni_identity,num,add_zero2(num2hex(rand(1,4095),1),3),3)
	M.dna.uni_identity = newdna
	return

/proc/toggledblock(hnumber) //unused
	var/temp3
	var/chtemp
	temp3 = hex2num(hnumber)
	if (temp3 < 2050)
		chtemp = rand(2050,4095)
		return add_zero2(num2hex(chtemp,1),3)
	else
		chtemp = rand(1,2049)
		return add_zero2(num2hex(chtemp,1),3)
/////////////////////////// DNA HELPER-PROCS

/////////////////////////// DNA MISC-PROCS
/proc/updateappearance(mob/M as mob,structure)
	if(istype(M, /mob/living/carbon/human))
		M.dna.check_integrity()
		var/mob/living/carbon/human/H = M
		H.r_hair = hex2num(getblock(structure,1,3))
		H.b_hair = hex2num(getblock(structure,2,3))
		H.g_hair = hex2num(getblock(structure,3,3))
		H.r_facial = hex2num(getblock(structure,4,3))
		H.b_facial = hex2num(getblock(structure,5,3))
		H.g_facial = hex2num(getblock(structure,6,3))
		H.s_tone = round(((hex2num(getblock(structure,7,3)) / 16) - 220))
		H.r_eyes = hex2num(getblock(structure,8,3))
		H.g_eyes = hex2num(getblock(structure,9,3))
		H.b_eyes = hex2num(getblock(structure,10,3))

		if (isblockon(getblock(structure, 11,3),11))
			H.gender = FEMALE
		else
			H.gender = MALE


		/// BEARDS

		var/beardnum = hex2num(getblock(structure,12,3))
		var/list/facial_styles = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
		var/fstyle = round(1 +(beardnum / 4096)*facial_styles.len)

		var/fpath = text2path("[facial_styles[fstyle]]")
		var/datum/sprite_accessory/facial_hair/fhair = new fpath

		H.face_icon_state = fhair.icon_state
		H.f_style = fhair.icon_state
		H.facial_hair_style = fhair


		// HAIR
		var/hairnum = hex2num(getblock(structure,13,3))
		var/list/styles = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
		var/style = round(1 +(hairnum / 4096)*styles.len)

		var/hpath = text2path("[styles[style]]")
		var/datum/sprite_accessory/hair/hair = new hpath

		H.hair_icon_state = hair.icon_state
		H.h_style = hair.icon_state
		H.hair_style = hair

		H.update_face()
		H.update_body()

		H.warn_flavor_changed()

		return 1
	else
		return 0

/proc/ismuton(var/block,var/mob/M)
	return isblockon(getblock(M.dna.struc_enzymes, block,3),block)

/proc/domutcheck(mob/living/M as mob, connected, inj)
	if (!M) return
	//mutations
	/*
	TK				=(1<<0)	1
	COLD_RESISTANCE	=(1<<1)	2
	XRAY			=(1<<2)	4
	HULK			=(1<<3)	8
	CLUMSY			=(1<<4)	16
	//FAT				=(1<<5) 32
	HUSK			=(1<<6)	64
	LASER			=(1<<7)	128
	HEAL			=(1<<8)	256
	mNobreath		=(1<<9)	512
	mRemote			=(1<<10)	1024
	mRegen			=(1<<11)	2048
	mRun			=(1<<12)	4096
	mRemotetalk		=(1<<13)	8192
	mMorph			=(1<<14)	16384
	mBlend			=(1<<15)	32768

	mutations2:
	mHallucination	=(1<<0) 1
	mFingerprints	=(1<<1) 2
	mShock			=(1<<2) 4
	mSmallsize		=(1<<3)	8
	*/

	//disabilities
	//1 = blurry eyes
	//2 = headache
	//4 = coughing
	//8 = twitch
	//16 = nervous
	//32 = deaf
	//64 = mute
	//128 = blind

	M.dna.check_integrity()

	M.disabilities = 0
	M.mutations = 0
	M.mutations2 = 0

	M.see_in_dark = 2
	M.see_invisible = 0

	if(ismuton(NOBREATHBLOCK,M))
		if(prob(50))
			M << "\blue You feel no need to breathe."
			M.mutations |= mNobreath
	if(ismuton(REMOTEVIEWBLOCK,M))
		if(prob(50))
			M << "\blue Your mind expands"
			M.mutations |= mRemote
	if(ismuton(REGENERATEBLOCK,M))
		if(prob(50))
			M << "\blue You feel strange"
			M.mutations |= mRegen
	if(ismuton(INCREASERUNBLOCK,M))
		if(prob(50))
			M << "\blue You feel quick"
			M.mutations |= mRun
	if(ismuton(REMOTETALKBLOCK,M))
		if(prob(50))
			M << "\blue You expand your mind outwards"
			M.mutations |= mRemotetalk
	if(ismuton(MORPHBLOCK,M))
		if(prob(50))
			M.mutations |= mMorph
			M << "\blue Your skin feels strange"
	if(ismuton(BLENDBLOCK,M))
		if(prob(50))
			M.mutations |= mBlend
			M << "\blue You feel alone"
	if(ismuton(HALLUCINATIONBLOCK,M))
		if(prob(50))
			M.mutations2 |= mHallucination
			M << "\blue Your mind says 'Hello'"
	if(ismuton(NOPRINTSBLOCK,M))
		if(prob(50))
			M.mutations2 |= mFingerprints
			M << "\blue Your fingers feel numb"
	if(ismuton(SHOCKIMMUNITYBLOCK,M))
		if(prob(50))
			M.mutations2 |= mShock
			M << "\blue You feel strange"
	if(ismuton(SMALLSIZEBLOCK,M))
		if(prob(50))
			M << "\blue Your skin feels rubbery"
			M.mutations2 |= mSmallsize



	if (isblockon(getblock(M.dna.struc_enzymes, HULKBLOCK,3),HULKBLOCK))
		if(inj || prob(5))
			M << "\blue Your muscles hurt."
			M.mutations |= HULK
	if (isblockon(getblock(M.dna.struc_enzymes, HEADACHEBLOCK,3),HEADACHEBLOCK))
		M.disabilities |= 2
		M << "\red You get a headache."
	if (isblockon(getblock(M.dna.struc_enzymes, FAKEBLOCK,3),FAKEBLOCK))
		M << "\red You feel strange."
		if (prob(95))
			if(prob(50))
				randmutb(M)
			else
				randmuti(M)
		else
			randmutg(M)
	if (isblockon(getblock(M.dna.struc_enzymes, COUGHBLOCK,3),COUGHBLOCK))
		M.disabilities |= 4
		M << "\red You start coughing."
	if (isblockon(getblock(M.dna.struc_enzymes, CLUMSYBLOCK,3),CLUMSYBLOCK))
		M << "\red You feel lightheaded."
		M.mutations |= CLUMSY
	if (isblockon(getblock(M.dna.struc_enzymes, TWITCHBLOCK,3),TWITCHBLOCK))
		M.disabilities |= 8
		M << "\red You twitch."
	if (isblockon(getblock(M.dna.struc_enzymes, XRAYBLOCK,3),XRAYBLOCK))
		if(inj || prob(30))
			M << "\blue The walls suddenly disappear."
			M.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			M.see_in_dark = 8
			M.see_invisible = 2
			M.mutations |= XRAY
	if (isblockon(getblock(M.dna.struc_enzymes, NERVOUSBLOCK,3),NERVOUSBLOCK))
		M.disabilities |= 16
		M << "\red You feel nervous."
	if (isblockon(getblock(M.dna.struc_enzymes, FIREBLOCK,3),FIREBLOCK))
		if(inj || prob(30))
			M << "\blue Your body feels warm."
			M.mutations |= COLD_RESISTANCE
	if (isblockon(getblock(M.dna.struc_enzymes, BLINDBLOCK,3),BLINDBLOCK))
		M.disabilities |= 128
		M << "\red You can't seem to see anything."
	if (isblockon(getblock(M.dna.struc_enzymes, TELEBLOCK,3),TELEBLOCK))
		if(inj || prob(15))
			M << "\blue You feel smarter."
			M.mutations |= TK
	if (isblockon(getblock(M.dna.struc_enzymes, DEAFBLOCK,3),DEAFBLOCK))
		M.disabilities |= 32
		M.ear_deaf = 1
		M << "\red Its kinda quiet.."
	if (isblockon(getblock(M.dna.struc_enzymes, GLASSESBLOCK,3),GLASSESBLOCK))
		M.disabilities |= 1
		M << "Your eyes feel weird..."

//////////////////////////////////////////////////////////// Monkey Block
	if (isblockon(getblock(M.dna.struc_enzymes, MONKEYBLOCK,3),MONKEYBLOCK) && istype(M, /mob/living/carbon/human))
	// human > monkey
		var/mob/living/carbon/human/H = M
		H.monkeyizing = 1
		if(!connected)
			for(var/obj/item/W in (H.contents))
				if (W==H.w_uniform) // will be teared
					continue
				H.drop_from_slot(W)
			M.update_clothing()
			M.monkeyizing = 1
			M.canmove = 0
			M.icon = null
			M.invisibility = 101
			var/atom/movable/overlay/animation = new( M.loc )
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = src
			flick("h2monkey", animation)
			sleep(48)
			del(animation)

		var/mob/living/carbon/monkey/O = new(src)
		del(O.organs)
		O.organs = H.organs
		for(var/name in O.organs)
			var/datum/organ/external/organ = O.organs[name]
			organ.owner = O
			for(var/obj/item/weapon/implant/implant in organ.implant)
				implant.imp_in = O

		if(M)
			if (M.dna)
				O.dna = M.dna
				M.dna = null


		for(var/datum/disease/D in M.viruses)
			O.viruses += D
			D.affected_mob = O
			M.viruses -= D


		for(var/obj/T in (M.contents))
			del(T)
		//for(var/R in M.organs)
		//	del(M.organs[text("[]", R)])

		O.loc = M.loc

		if(M.mind)
			M.mind.transfer_to(O)

		if (connected) //inside dna thing
			var/obj/machinery/dna_scannernew/C = connected
			O.loc = C
			C.occupant = O
			connected = null
		O.name = text("monkey ([])",copytext(md5(M.real_name), 2, 6))
		O.take_overall_damage(M.getBruteLoss() + 40, M.getFireLoss())
		O.adjustToxLoss(M.getToxLoss() + 20)
		O.adjustOxyLoss(M.getOxyLoss())
		O.stat = M.stat
		O.a_intent = "hurt"
		O.flavor_text = M.flavor_text
		O.warn_flavor_changed()
		O.update_clothing()
		del(M)
		return

	if (!isblockon(getblock(M.dna.struc_enzymes, MONKEYBLOCK,3),MONKEYBLOCK) && !istype(M, /mob/living/carbon/human))
	// monkey > human,
		var/mob/living/carbon/monkey/Mo = M
		Mo.monkeyizing = 1
		if(!connected)
			for(var/obj/item/W in (Mo.contents))
				Mo.drop_from_slot(W)
			M.update_clothing()
			M.monkeyizing = 1
			M.canmove = 0
			M.icon = null
			M.invisibility = 101
			var/atom/movable/overlay/animation = new( M.loc )
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = src
			flick("monkey2h", animation)
			sleep(48)
			del(animation)

		var/mob/living/carbon/human/O = new( src )
		if (isblockon(getblock(M.dna.uni_identity, 11,3),11))
			O.gender = FEMALE
		else
			O.gender = MALE
		O.dna = M.dna
		M.dna = null
		del(O.organs)
		O.organs = M.organs
		for(var/name in O.organs)
			var/datum/organ/external/organ = O.organs[name]
			organ.owner = O
			for(var/obj/item/weapon/implant/implant in organ.implant)
				implant.imp_in = O

		for(var/datum/disease/D in M.viruses)
			O.viruses += D
			D.affected_mob = O
			M.viruses -= D

		//for(var/obj/T in M)
		//	del(T)

		O.loc = M.loc

		if(M.mind)
			M.mind.transfer_to(O)

		if (connected) //inside dna thing
			var/obj/machinery/dna_scannernew/C = connected
			O.loc = C
			C.occupant = O
			connected = null

		var/i
		while (!i)
			var/randomname
			if (O.gender == MALE)
				randomname = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
			else
				randomname = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
			if (findname(randomname))
				continue
			else
				O.real_name = randomname
				i++
		updateappearance(O,O.dna.uni_identity)
		O.take_overall_damage(M.getBruteLoss(), M.getFireLoss())
		O.adjustToxLoss(M.getToxLoss())
		O.adjustOxyLoss(M.getOxyLoss())
		O.stat = M.stat
		O.flavor_text = M.flavor_text
		O.warn_flavor_changed()
		O.update_clothing()
		del(M)
		return
//////////////////////////////////////////////////////////// Monkey Block
	if (M)
		M.update_clothing()
	return null
/////////////////////////// DNA MISC-PROCS


/proc/mini_blob_event()

	var/turf/T = pick(blobstart)
	if(istype(T, /turf/simulated/wall))
		T.ReplaceWithPlating()
	for(var/atom/A in T)
		if(A.density)
			del(A)
	var/obj/effect/blob/bl = new /obj/effect/blob( T, 30 )
	spawn(0)
		bl.Life()
		bl.Life()
		bl.Life()
		bl.Life()
		bl.blobdebug = 1
		bl.Life()
	blobevent = 1
	spawn(0)
		dotheblobbaby()
	spawn(15000)
		blobevent = 0
	spawn(rand(600, 1800)) //Delayed announcements to keep the crew on their toes.
		command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()].", "Biohazard Alert")
		world << sound('sound/announcer/outbreak5.ogg')

/proc/dotheblobbaby()
	if (blobevent)
		if(blobs.len)
			for(var/i = 1 to 10)
				sleep(-1)
				if(!blobs.len)	break
				var/obj/effect/blob/B = pick(blobs)
				if(B.z != 1)
					continue
				B.Life()
		spawn(150)
			dotheblobbaby()
/proc/power_failure()
	command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure")
	world << sound('sound/announcer/poweroff.ogg')
	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			C.cell.charge = 0
	for(var/obj/machinery/power/smes/S in world)
		if(istype(get_area(S), /area/turret_protected) || S.z != 1)
			continue
		S.charge = 0
		S.output = 0
		S.online = 0
		S.updateicon()
		S.power_change()
	for(var/area/A in world)
		if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Chemical Lab Test Chamber" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
			A.power_light = 0
			A.power_equip = 0
			A.power_environ = 0
			A.power_change()

/proc/power_restore()
	command_alert("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal")
	world << sound('sound/announcer/poweron.ogg')
	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in world)
		if(S.z != 1)
			continue
		S.charge = S.capacity
		S.output = 200000
		S.online = 1
		S.updateicon()
		S.power_change()
	for(var/area/A in world)
		if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Chemical Lab Test Chamber" && A.name != "space" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
			A.power_light = 1
			A.power_equip = 1
			A.power_environ = 1
			A.power_change()

/proc/lightsout(isEvent = 0, lightsoutAmount = 1,lightsoutRange = 10) //leave lightsoutAmount as 0 to break ALL lights
	if(isEvent)
		command_alert("An Electrical storm has been detected in your area, please repair potential electronic overloads.","Electrical Storm Alert")

	if(lightsoutAmount)
		var/list/epicentreList = list()

		for(var/i=1,i<=lightsoutAmount,i++)
			var/list/possibleEpicentres = list()
			for(var/obj/effect/landmark/newEpicentre in world)
				if(newEpicentre.name == "lightsout" && !(newEpicentre in epicentreList))
					possibleEpicentres += newEpicentre
			if(possibleEpicentres.len)
				epicentreList += pick(possibleEpicentres)
			else
				break

		if(!epicentreList.len)
			return

		for(var/obj/effect/landmark/epicentre in epicentreList)
			for(var/obj/machinery/power/apc/apc in range(epicentre,lightsoutRange))
				apc.overload_lighting()

	else
		for(var/obj/machinery/power/apc/apc in world)
			apc.overload_lighting()

	return
//Carn: Spacevines random event.
/proc/spacevine_infestation()

	spawn() //to stop the secrets panel hanging
		var/list/turf/simulated/floor/turfs = list() //list of all the empty floor turfs in the hallway areas
		for(var/areapath in typesof(/area/hallway))
			var/area/hallway/A = locate(areapath)
			for(var/turf/simulated/floor/F in A)
				if(!F.contents.len)
					turfs += F

		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)
			new/obj/effect/spacevine_controller(T) //spawn a controller at turf
			message_admins("\blue Event: Spacevines spawned at [T.loc] ([T.x],[T.y],[T.z])")

/proc/space_ninja_arrival()

	var/datum/game_mode/current_mode = ticker.mode
	var/datum/mind/current_mind

	/*Is the ninja playing for the good or bad guys? Is the ninja helping or hurting the station?
	Their directives also influence behavior. At least in theory.*/
	var/side = pick("face","heel")

	var/antagonist_list[] = list()//The main bad guys. Evil minds that plot destruction.
	var/protagonist_list[] = current_mode.get_living_heads()//The good guys. Mostly Heads. Who are alive.

	var/xeno_list[] = list()//Aliens.
	var/commando_list[] = list()//Commandos.

	//We want the ninja to appear only in certain modes.
//	var/acceptable_modes_list[] = list("traitor","revolution","cult","wizard","changeling","traitorchan","nuclear","malfunction","monkey")  // Commented out for both testing and ninjas
//	if(!(current_mode.config_tag in acceptable_modes_list))
//		return

	/*No longer need to determine what mode it is since bad guys are basically universal.
	And there is now a mode with two types of bad guys.*/

	var/possible_bad_dudes[] = list(current_mode.traitors,current_mode.head_revolutionaries,current_mode.head_revolutionaries,
	                                current_mode.cult,current_mode.wizards,current_mode.changelings,current_mode.syndicates)
	for(var/list in possible_bad_dudes)//For every possible antagonist type.
		for(current_mind in list)//For each mind in that list.
			if(current_mind.current&&current_mind.current.stat!=2)//If they are not destroyed and not dead.
				antagonist_list += current_mind//Add them.

	if(protagonist_list.len)//If the mind is both a protagonist and antagonist.
		for(current_mind in protagonist_list)
			if(current_mind in antagonist_list)
				protagonist_list -= current_mind//We only want it in one list.
/*
Malf AIs/silicons aren't added. Monkeys aren't added. Messes with objective completion. Only humans are added.
*/

	//Here we pick a location and spawn the ninja.
	var/list/spawn_list = list()
	for(var/obj/effect/landmark/L in world)
		if (L.name == "ninjaspawn")
			spawn_list.Add(L)

	var/mob/dead/observer/G
	var/list/candidates = list()
	for(G in world)
		if(G.client)//Now everyone can ninja!
			if(((G.client.inactivity/10)/60) <= 5)
				candidates.Add(G)

	//The ninja will be created on the right spawn point or at late join.
	var/mob/living/carbon/human/new_ninja = create_space_ninja(pick(spawn_list.len ? spawn_list : latejoin ))

	if(candidates.len)
		G = pick(candidates)
		new_ninja.key = G.key
		new_ninja.mind.key = new_ninja.key
		new_ninja.wear_suit:randomize_param()//Give them a random set of suit parameters.
		new_ninja.internal = new_ninja.s_store //So the poor ninja has something to breath when they spawn in space.
		new_ninja.internals.icon_state = "internal1"
		del(G)
	else
		del(new_ninja)
		return
	//Now for the rest of the stuff.

	var/datum/mind/ninja_mind = new_ninja.mind//For easier reference.
	var/mission_set = 0//To determine if we need to do further processing.
	//Xenos and deathsquads take precedence over everything else.

	//Unless the xenos are hiding in a locker somewhere, this'll find em.
	for(var/mob/living/carbon/alien/humanoid/xeno in world)
		if(istype(xeno))
			xeno_list += xeno

	if(xeno_list.len>3)//If there are more than three humanoid xenos on the station, time to get dangerous.
		//Here we want the ninja to murder all the queens. The other aliens don't really matter.
		var/xeno_queen_list[] = list()
		for(var/mob/living/carbon/alien/humanoid/queen/xeno_queen in xeno_list)
			if(xeno_queen.mind&&xeno_queen.stat!=2)
				xeno_queen_list += xeno_queen
		if(xeno_queen_list.len&&side=="face")//If there are queen about and the probability is 50.
			for(var/mob/living/carbon/alien/humanoid/queen/xeno_queen in xeno_queen_list)
				var/datum/objective/assassinate/ninja_objective = new
				//We'll do some manual overrides to properly set it up.
				ninja_objective.owner = ninja_mind
				ninja_objective.target = xeno_queen.mind
				ninja_objective.explanation_text = "Kill \the [xeno_queen]."
				ninja_mind.objectives += ninja_objective
			mission_set = 1

	if(sent_strike_team&&side=="heel"&&antagonist_list.len)//If a strike team was sent, murder them all like a champ.
		for(current_mind in antagonist_list)//Search and destroy. Since we already have an antagonist list, they should appear there.
			if(current_mind && current_mind.special_role=="Death Commando")
				commando_list += current_mind
		if(commando_list.len)//If there are living commandos still in play.
			for(var/mob/living/carbon/human/commando in commando_list)
				var/datum/objective/assassinate/ninja_objective = new
				ninja_objective.owner = ninja_mind
				ninja_objective.find_target_by_role(commando.mind.special_role,1)
				ninja_mind.objectives += ninja_objective
			mission_set = 1
/*
If there are no antogonists left it could mean one of two things:
	A) The round is about to end. No harm in spawning the ninja here.
	B) The round is still going and ghosts are probably rioting for something to happen.
In either case, it's a good idea to spawn the ninja with a semi-random set of objectives.
*/
	if(!mission_set)//If mission was not set.

		var/current_minds[]//List being looked on in the following code.
		var/side_list = side=="face" ? 2 : 1//For logic gating.
		var/hostile_targets[] = list()//The guys actually picked for the assassination or whatever.
		var/friendly_targets[] = list()//The guys the ninja must protect.

		for(var/i=2,i>0,i--)//Two lists.
			current_minds = i==2 ? antagonist_list : protagonist_list//Which list are we looking at?
			for(var/t=3,(current_minds.len&&t>0),t--)//While the list is not empty and targets remain. Also, 3 targets is good.
				current_mind = pick(current_minds)//Pick a random person.
				/*I'm creating a logic gate here based on the ninja affiliation that compares the list being
				looked at to the affiliation. Affiliation is just a number used to compare. Meaning comes from the logic involved.
				If the list being looked at is equal to the ninja's affiliation, add the mind to hostiles.
				If not, add the mind to friendlies. Since it can't be both, it will be added only to one or the other.*/
				hostile_targets += i==side_list ? current_mind : null//Adding null doesn't add anything.
				friendly_targets += i!=side_list ? current_mind : null
				current_minds -= current_mind//Remove the mind so it's not picked again.

		var/objective_list[] = list(1,2,3,4,5,6)//To remove later.
		for(var/i=rand(1,3),i>0,i--)//Want to get a few random objectives. Currently up to 3.
			if(!hostile_targets.len)//Remove appropriate choices from switch list if the target lists are empty.
				objective_list -= 1
				objective_list -= 4
			if(!friendly_targets.len)
				objective_list -= 3
			switch(pick(objective_list))
				if(1)//kill
					current_mind = pick(hostile_targets)

					if(current_mind)
						var/datum/objective/assassinate/ninja_objective = new
						ninja_objective.owner = ninja_mind
						ninja_objective.find_target_by_role((current_mind.special_role ? current_mind.special_role : current_mind.assigned_role),(current_mind.special_role?1:0))//If they have a special role, use that instead to find em.
						ninja_mind.objectives += ninja_objective

					else
						i++

					hostile_targets -= current_mind//Remove them from the list.
				if(2)//Steal
					var/list/datum/objective/theft = GenerateTheft(ninja_mind.assigned_role,ninja_mind)
					var/datum/objective/steal/steal_objective = PickObjectiveFromList(theft)
					ninja_mind.objectives += steal_objective

					objective_list -= 2
				if(3)//Protect. Keeping people alive can be pretty difficult.
					current_mind = pick(friendly_targets)

					if(current_mind)

						var/datum/objective/protection/ninja_objective = new
						ninja_objective.owner = ninja_mind
						ninja_objective.find_target_by_role((current_mind.special_role ? current_mind.special_role : current_mind.assigned_role),(current_mind.special_role?1:0))
						ninja_mind.objectives += ninja_objective

					else
						i++

					friendly_targets -= current_mind
				if(4)//Debrain
					current_mind = pick(hostile_targets)

					if(current_mind)

						var/datum/objective/debrain/ninja_objective = new
						ninja_objective.owner = ninja_mind
						ninja_objective.find_target_by_role((current_mind.special_role ? current_mind.special_role : current_mind.assigned_role),(current_mind.special_role?1:0))
						ninja_mind.objectives += ninja_objective

					else
						i++

					hostile_targets -= current_mind//Remove them from the list.
				if(5)//Download research
					var/datum/objective/download/ninja_objective = new
					ninja_objective.gen_amount_goal()
					ninja_mind.objectives += ninja_objective

					objective_list -= 5
				if(6)//Capture
					var/datum/objective/capture/ninja_objective = new
					ninja_objective.gen_amount_goal()
					ninja_mind.objectives += ninja_objective

					objective_list -= 6

		if(ninja_mind.objectives.len)//If they got some objectives out of that.
			mission_set = 1

	if(!ninja_mind.objectives.len||!mission_set)//If they somehow did not get an objective at this point, time to destroy the station.
		var/nuke_code
		var/temp_code
		for(var/obj/machinery/nuclearbomb/N in world)
			temp_code = text2num(N.r_code)
			if(temp_code)//if it's actually a number. It won't convert any non-numericals.
				nuke_code = N.r_code
				break
		if(nuke_code)//If there is a nuke device in world and we got the code.
			var/datum/objective/nuclear/ninja_objective = new//Fun.
			ninja_objective.owner = ninja_mind
			ninja_objective.explanation_text = "Destroy the station with a nuclear device. The code is [nuke_code]." //Let them know what the code is.

	//Finally add a survival objective since it's usually broad enough for any round type.
	var/datum/objective/survive/ninja_objective = new
	ninja_objective.owner = ninja_mind
	ninja_mind.objectives += ninja_objective

	var/directive = generate_ninja_directive(side)
	new_ninja << "\blue \nYou are an elite mercenary assassin of the Spider Clan, [new_ninja.real_name]. The dreaded \red <B>SPACE NINJA</B>!\blue You have a variety of abilities at your disposal, thanks to your nano-enhanced cyber armor. Remember your training (initialize your suit by right clicking on it)! \nYour current directive is: \red <B>[directive]</B>"
	new_ninja.mind.store_memory("<B>Directive:</B> \red [directive]<br>")

	var/obj_count = 1
	new_ninja << "\blue Your current objectives:"
	for(var/datum/objective/objective in ninja_mind.objectives)
		new_ninja << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++

	sent_ninja_to_station = 1//And we're done.
	return new_ninja//Return the ninja in case we need to reference them later.

/*
This proc will give the ninja a directive to follow. They are not obligated to do so but it's a fun roleplay reminder.
Making this random or semi-random will probably not work without it also being incredibly silly.
As such, it's hard-coded for now. No reason for it not to be, really.
*/
/proc/generate_ninja_directive(side)
	var/directive = "[side=="face"?"Nanotrasen":"The Syndicate"] is your employer. "//Let them know which side they're on.
	switch(rand(1,13))
		if(1)
			directive += "The Spider Clan must not be linked to this operation. Remain as hidden and covert as possible."
		if(2)
			directive += "[station_name] is financed by an enemy of the Spider Clan. Cause as much structural damage as possible."
		if(3)
			directive += "A wealthy animal rights activist has made a request we cannot refuse. Prioritize saving animal lives whenever possible."
		if(4)
			directive += "The Spider Clan absolutely cannot be linked to this operation. Eliminate all witnesses using most extreme prejudice."
		if(5)
			directive += "We are currently negotiating with Nanotrasen command. Prioritize saving human lives over ending them."
		if(6)
			directive += "We are engaged in a legal dispute over [station_name]. If a laywer is present on board, force their cooperation in the matter."
		if(7)
			directive += "A financial backer has made an offer we cannot refuse. Implicate Syndicate involvement in the operation."
		if(8)
			directive += "Let no one question the mercy of the Spider Clan. Ensure the safety of all non-essential personnel you encounter."
		if(9)
			directive += "A free agent has proposed a lucrative business deal. Implicate Nanotrasen involvement in the operation."
		if(10)
			directive += "Our reputation is on the line. Harm as few civilians or innocents as possible."
		if(11)
			directive += "Our honor is on the line. Utilize only honorable tactics when dealing with opponents."
		if(12)
			directive += "We are currently negotiating with a Syndicate leader. Disguise assassinations as suicide or another natural cause."
		else
			directive += "There are no special supplemental instructions at this time."
	return directive

//=======//CURRENT PLAYER VERB//=======//

/proc/create_space_ninja(obj/spawn_point)
	var/mob/living/carbon/human/new_ninja = new(spawn_point.loc)
	var/ninja_title = pick(ninja_titles)
	var/ninja_name = pick(ninja_names)
	new_ninja.gender = pick(MALE, FEMALE)

	var/datum/preferences/A = new()//Randomize appearance for the ninja.
	A.randomize_appearance_for(new_ninja)
	new_ninja.real_name = "[ninja_title] [ninja_name]"
	new_ninja.dna.ready_dna(new_ninja)
	new_ninja.create_mind_space_ninja()
	new_ninja.equip_space_ninja()
	return new_ninja

/proc/SpawnEvent()
	if(!EventsOn || ActiveEvent || !config.allow_random_events)
		return
	if((world.time/10)>=3600 && toggle_space_ninja && !sent_ninja_to_station && !is_ninjad_yet)
		EventTypes |= /datum/event/spaceninja
		is_ninjad_yet = 1
	var/Type = pick(EventTypes)
	if(Type in OneTimeEvents)
		EventTypes -= Type
	ActiveEvent = new Type()
	ActiveEvent.Announce()
	if (!ActiveEvent)
		return
	spawn(0)
		while (ActiveEvent.ActiveFor < ActiveEvent.Lifetime)
			ActiveEvent.Tick()
			ActiveEvent.ActiveFor++
			sleep(10)
		ActiveEvent.Die()
		del ActiveEvent

/proc/Force_Event(var/Type in typesof(/datum/event), var/args = null)
	if(!EventsOn)
		src << "Events are not enabled."
		return
	if(ActiveEvent)
		src << "There is an active event."
		return
	src << "Started Event: [Type]"
	ActiveEvent = new Type()
	if(istype(ActiveEvent,/datum/event/viral_infection) && args && args != "virus2")
		var/datum/event/viral_infection/V = ActiveEvent
		V.virus = args
		ActiveEvent = V
	ActiveEvent.Announce()
	if (!ActiveEvent)
		return
	spawn(0)
		while (ActiveEvent.ActiveFor < ActiveEvent.Lifetime)
			ActiveEvent.Tick()
			ActiveEvent.ActiveFor++
			sleep(10)
		ActiveEvent.Die()
		del ActiveEvent

proc
	get_approximate_direction(atom/ref,atom/target)
	/* returns the approximate direction from ref to target.
		Code by Lummox JR
		http://www.byond.com/forum/forum.cgi?action=message_list&query=Post+ID%3A153964#153964
		*/
		var/d=get_dir(ref,target)
		if(d&d-1)        // diagonal
			var/ax=abs(ref.x-target.x)
			var/ay=abs(ref.y-target.y)
			if(ax>=ay<<1) return d&12     // keep east/west (4 and 8)
			else if(ay>=ax<<1) return d&3 // keep north/south (1 and 2)
		return d
