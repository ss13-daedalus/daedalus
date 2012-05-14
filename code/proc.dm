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

proc/equalize_gases(datum/gas_mixture/list/gases)
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

	for(var/datum/gas_mixture/gas in gases)
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

		//Update individual gas_mixtures by volume ratio
		for(var/datum/gas_mixture/gas in gases)
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
			return list(access_medical, access_morgue, access_medlab)
		if("Station Engineer")
			return list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION)
		if("Assistant")
			return list()
		if("Chaplain")
			return list(access_morgue, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM)
		if("Detective")
			return list(access_security, ACCESS_FORENSICS_LOCKERS, access_morgue, ACCESS_MAINT_TUNNELS, access_court)
		if("Medical Doctor")
			return list(access_medical, access_morgue, access_surgery, ACCESS_VIROLOGY)
		if("Botanist")	// -- TLE
			return list(ACCESS_HYDROPONICS) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT
		if("Librarian") // -- TLE
			return list(ACCESS_LIBRARY)
		if("Lawyer") //Muskets 160910
			return list(ACCESS_LAWYER, access_court)
		if("Captain")
			return get_all_accesses()
		if("Security Officer")
			return list(access_security, access_brig, access_court, ACCESS_MAINT_TUNNELS)
		if("Warden")
			return list(access_security, access_brig, ACCESS_ARMORY, access_court, ACCESS_MAINT_TUNNELS)
		if("Scientist")
			return list(access_tox, ACCESS_TOX_STORAGE, access_research, ACCESS_XENOBIOLOGY)
		if("Head of Security")
			return list(access_medical, access_morgue, access_tox, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, access_medlab, access_court,
			            ACCESS_TELEPORTER, ACCESS_HEADS, ACCESS_TECH_STORAGE, access_security, access_brig, ACCESS_ATMOSPHERICS,
			            ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_KITCHEN, ACCESS_ROBOTICS, ACCESS_ARMORY, ACCESS_HYDROPONICS,
			            access_theatre, access_research, access_hos, access_RC_announce, ACCESS_FORENSICS_LOCKERS, access_keycard_auth)
		if("Head of Personnel")
			return list(access_security, access_brig, access_court, ACCESS_FORENSICS_LOCKERS,
			            access_tox, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, access_medical, access_medlab, ACCESS_ENGINE,
			            ACCESS_EMERGENCY_STORAGE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_ROBOTICS, access_cargo, ACCESS_CARGO_BOT, ACCESS_HYDROPONICS, ACCESS_LAWYER,
			            access_theatre, access_research, access_mining, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
			            access_hop, access_RC_announce, access_keycard_auth)
		if("Atmospheric Technician")
			return list(ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EMERGENCY_STORAGE)
		if("Bartender")
			return list(ACCESS_BAR)
		if("Chemist")
			return list(access_medical, ACCESS_CHEMISTRY)
		if("Janitor")
			return list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS)
		if("Clown")
			return list(access_clown, access_theatre)
		if("Mime")
			return list(access_mime, access_theatre)
		if("Chef")
			return list(ACCESS_KITCHEN)
		if("Roboticist")
			return list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS)
		if("Cargo Technician")
			return list(ACCESS_MAINT_TUNNELS, access_cargo, ACCESS_CARGO_BOT, ACCESS_MAILSORTING)
		if("Shaft Miner")
			return list(access_mining, ACCESS_MINT, ACCESS_MINING_STATION)
		if("Quartermaster")
			return list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, access_cargo, ACCESS_CARGO_BOT, access_qm, ACCESS_MINT, access_mining)
		if("Chief Engineer")
			return list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
			            ACCESS_HEADS, ACCESS_AI_UPLOAD, ACCESS_CONSTRUCTION, ACCESS_ROBOTICS,
			            ACCESS_MINT, access_ce, access_RC_announce, access_keycard_auth, access_tcomsat)
		if("Research Director")
			return list(access_medlab, access_rd,
			            ACCESS_HEADS, access_tox,
			            ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_TELEPORTER,
			            access_research, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, access_RC_announce,
			            access_keycard_auth, access_tcomsat)
		/*if("Virologist")
			return list(access_medical, access_morgue, ACCESS_VIROLOGY)*/
		if("Chief Medical Officer")
			return list(access_medical, access_morgue, access_medlab, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth)
		else
			return list()

/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(access_cent_general)
		if("Custodian")
			return list(access_cent_general, access_cent_living, access_cent_storage)
		if("Thunderdome Overseer")
			return list(access_cent_general, access_cent_thunder)
		if("Intel Officer")
			return list(access_cent_general, access_cent_living)
		if("Medical Officer")
			return list(access_cent_general, access_cent_living, access_cent_medical)
		if("Death Commando")
			return list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)
		if("Research Officer")
			return list(access_cent_general, access_cent_specops, access_cent_medical, access_cent_teleporter, access_cent_storage)
		if("BlackOps Commander")
			return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_living, access_cent_storage, access_cent_creed)
		if("Supreme Commander")
			return get_all_centcom_access()

/proc/get_all_accesses()
	return list(access_security, access_brig, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, access_court,
	            access_medical, access_medlab, access_morgue, access_rd,
	            access_tox, ACCESS_TOX_STORAGE, ACCESS_CHEMISTRY, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS,
	            ACCESS_EXTERNAL_AIRLOCKS, ACCESS_EMERGENCY_STORAGE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD,
	            ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_ALL_PERSONAL_LOCKERS,
	            ACCESS_TECH_STORAGE, ACCESS_CHAPEL_OFFICE, ACCESS_ATMOSPHERICS, ACCESS_KITCHEN,
	            ACCESS_BAR, ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_ROBOTICS, access_cargo, ACCESS_CARGO_BOT, ACCESS_CONSTRUCTION,
	            ACCESS_HYDROPONICS, ACCESS_LIBRARY, ACCESS_MANUFACTURING, ACCESS_LAWYER, ACCESS_VIROLOGY, access_cmo, access_qm, access_clown, access_mime, access_surgery,
	            access_theatre, access_research, access_mining, ACCESS_MAILSORTING, ACCESS_MINT_VAULT, ACCESS_MINT,
	            ACCESS_HEADS_VAULT, ACCESS_MINING_STATION, ACCESS_XENOBIOLOGY, access_ce, access_hop, access_hos, access_RC_announce,
	            access_keycard_auth, access_tcomsat)

/proc/get_all_centcom_access()
	return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_medical, access_cent_living, access_cent_storage, access_cent_teleporter, access_cent_creed, access_cent_captain)

/proc/get_all_syndicate_access()
	return list(access_syndicate)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //security
			return list(access_security, access_brig, ACCESS_ARMORY, ACCESS_FORENSICS_LOCKERS, access_court, access_hos)
		if(2) //medbay
			return list(access_medical, access_medlab, access_morgue, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, access_cmo, access_surgery)
		if(3) //research
			return list(access_tox, ACCESS_TOX_STORAGE, access_rd, ACCESS_HYDROPONICS, access_research, ACCESS_XENOBIOLOGY)
		if(4) //engineering and maintenance
			return list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_EMERGENCY_STORAGE, ACCESS_TECH_STORAGE, ACCESS_ATMOSPHERICS, ACCESS_CONSTRUCTION, ACCESS_ROBOTICS, access_ce)
		if(5) //command
			return list(ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MINT_VAULT, ACCESS_HEADS_VAULT, access_hop, access_RC_announce, access_keycard_auth, access_tcomsat)
		if(6) //station general
			return list(ACCESS_CHAPEL_OFFICE, ACCESS_KITCHEN,ACCESS_BAR, ACCESS_JANITOR, ACCESS_CREMATORIUM, ACCESS_LIBRARY, access_theatre, ACCESS_LAWYER, access_clown, access_mime)
		if(7) //supply
			return list(access_cargo, ACCESS_CARGO_BOT, access_qm, access_mining, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MINT)

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
		if(access_cargo)
			return "Cargo Bay"
		if(ACCESS_CARGO_BOT)
			return "Cargo Bot Delivery"
		if(access_security)
			return "Security"
		if(access_brig)
			return "Brig"
		if(access_court)
			return "Courtroom"
		if(ACCESS_FORENSICS_LOCKERS)
			return "Forensics"
		if(access_medical)
			return "Medical"
		if(access_medlab)
			return "Med-Sci"
		if(access_morgue)
			return "Morgue"
		if(access_tox)
			return "Toxins Research"
		if(ACCESS_TOX_STORAGE)
			return "Toxins Storage"
		if(ACCESS_CHEMISTRY)
			return "Toxins Chemical Lab"
		if(access_rd)
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
		if(access_cmo)
			return "CMO Private"
		if(access_qm)
			return "Quartermaster's Office"
		if(access_clown)
			return "HONK! Access"
		if(access_mime)
			return "Silent Access"
		if(access_surgery)
			return "Operating Room"
		if(access_theatre)
			return "Theatre"
		if(ACCESS_MANUFACTURING)
			return "Manufacturing"
		if(access_research)
			return "Research"
		if(access_mining)
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
		if(access_hop)
			return "HoP Private"
		if(access_hos)
			return "HoS Private"
		if(access_ce)
			return "CE Private"
		if(access_RC_announce)
			return "RC announcements"
		if(access_keycard_auth)
			return "Keycode auth. device"
		if(access_tcomsat)
			return "Telecommunications Satellite"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(access_cent_general)
			return "Code Grey"
		if(access_cent_thunder)
			return "Code Yellow"
		if(access_cent_storage)
			return "Code Orange"
		if(access_cent_living)
			return "Code Green"
		if(access_cent_medical)
			return "Code White"
		if(access_cent_teleporter)
			return "Code Blue"
		if(access_cent_specops)
			return "Code Black"
		if(access_cent_creed)
			return "Code Silver"
		if(access_cent_captain)
			return "Code Gold"

/proc/get_all_jobs()
	return list("Assistant", "Station Engineer", "Shaft Miner", "Detective", "Medical Doctor", "Captain", "Security Officer", "Warden",
				"Geneticist", "Scientist", "Head of Security", "Head of Personnel", "Atmospheric Technician",
				"Chaplain", "Bartender", "Chemist", "Janitor", "Chef", "Roboticist", "Quartermaster",
				"Chief Engineer", "Research Director", "Botanist", "Librarian", "Lawyer", "Virologist", "Cargo Technician", "Chief Medical Officer")

/proc/get_all_centcom_jobs()
	return list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer","BlackOps Commander","Supreme Commander")

/obj/proc/GetJobName()
	if (!istype(src, /obj/item/device/pda) && !istype(src,/obj/item/weapon/card/id))
		return

	var/jobName
	var/list/accesses = list()

	if(istype(src, /obj/item/device/pda))
		if(src:id)
			jobName = src:id:assignment
			accesses = src:id:access
	if(istype(src, /obj/item/weapon/card/id))
		jobName = src:assignment
		accesses = src:access

	if(jobName in get_all_jobs())
		return jobName

	// hack for alt titles
	if(istype(loc, /mob))
		var/mob/M = loc
		if(M.mind.role_alt_title == jobName && M.mind.assigned_role in get_all_jobs())
			return M.mind.assigned_role

	var/centcom = 0
	for(var/i = 1, i <= accesses.len, i++)
		if(accesses[i] > 100)
			centcom = 1
			break
	if(centcom)
		return "centcom"
	else
		return "Unknown"

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
