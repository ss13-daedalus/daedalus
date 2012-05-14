world
	mob = /mob/new_player
	turf = /turf/space
	area = /area
	view = "15x15"

	// The following defines make Daedalus show up as a Space Station 13
	// server on the BYOND hub.
	hub = "Exadv1.spacestation13"
	hub_password = "kMZy3U5jJHSiBQjr"
	name = "Daedalus"

	Topic(href, href_list[])
		world << "Received a Topic() call!"
		world << "[href]"
		for(var/a in href_list)
			world << "[a]"
		if(href_list["hello"])
			world << "Hello world!"
			return "Hello world!"
		world << "End of Topic() call."
		..()

/world/New()
	src.load_configuration()

	if (config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	src.load_mode()
	src.load_motd()
	src.load_rules()
	src.load_admins()
	if (config.usewhitelist)
		load_whitelist()
	LoadBansjob()
	src.update_status()

	makepowernets()

	sun = new /datum/sun()

	vote = new /datum/vote()

//	coffinhandler = new /datum/coffinhandler()

	radio_controller = new /datum/controller/radio()
	//main_hud1 = new /obj/hud()
	data_core = new /obj/datacore()

	paiController = new /datum/paiController()

	..()

	diary = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")].log")
	diary << {"

Starting up. [time2text(world.timeofday, "hh:mm.ss")]
---------------------

"}

	diaryofmeanpeople = file("data/logs/[time2text(world.realtime, "YYYY/MM-Month/DD-Day")] Attack.log")

	diaryofmeanpeople << {"

Starting up. [time2text(world.timeofday, "hh:mm.ss")]
---------------------
Dear Diary....
Today, these people were mean:

"}

	jobban_loadbanfile()
	jobban_updatelegacybans()
	LoadBans()
	process_teleport_locs() //Sets up the wizard teleport locations
	process_ghost_teleport_locs() //Sets up ghost teleport locations.

	if (config.kick_inactive)
		spawn(30)
			KickInactiveClients()

	plmaster = new /obj/effect/overlay(  )
	plmaster.icon = 'icons/effects/tile_effects.dmi'
	plmaster.icon_state = "plasma"
	plmaster.layer = FLY_LAYER
	plmaster.mouse_opacity = 0

	slmaster = new /obj/effect/overlay(  )
	slmaster.icon = 'icons/effects/tile_effects.dmi'
	slmaster.icon_state = "sleeping_agent"
	slmaster.layer = FLY_LAYER
	slmaster.mouse_opacity = 0

	src.update_status()

	master_controller = new /datum/controller/game_controller()
	spawn(-1) master_controller.setup()

	news_topic_handler = new

//Crispy fullban
/world/Reboot(var/reason)
	spawn(0)
		//world << sound(pick('newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg')) // random end sounds!! - LastyBatsy No, no random end sounds. - Miniature
		//if(prob(40))
		//	for(var/mob/M in world)
		//		if(M.client)
		//			M << sound('newroundsexy.ogg')
		//else
		//	for(var/mob/M in world)
		//		if(M.client)
		//			M << sound('sound/misc/apcdestroyed.ogg')
	//send2irc(world.url,"Server Rebooting!")
	for(var/client/C)
		if (config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")
		else
			C << link("byond://[world.address]:[world.port]")

//	sleep(10) // wait for sound to play
	..(reason)

/world/proc/load_mode()
	var/text = file2text("data/mode.txt")
	if (length(text) > 0)
		var/list/lines = dd_text2list(text, "\n")
		if (lines[1])
			master_mode = lines[1]
			diary << "Saved mode is '[master_mode]'"
	else
		master_mode = "traitor" // Default mode, in case of errors

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	if (length(the_mode) > 0 && the_mode != "none") // "None" is the vote set to dead people
													// , who can't pick an option in a gamemode vote.
		F << the_mode
	else
		F << "traitor" // Default mode, in case of errors

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")
	auth_motd = file2text("config/motd-auth.txt")
	no_auth_motd = file2text("config/motd-noauth.txt")

/world/proc/load_rules()
	rules = file2text("config/rules.html")
	if (!rules)
		rules = "<html><head><title>Rules</title><body>There are no rules! Go nuts!</body></html>"

/world/proc/load_admins()
	var/text = file2text("config/admins.txt")
	if (!text)
		diary << "Failed to load config/admins.txt\n"
	else
		var/list/lines = dd_text2list(text, "\n")
		for(var/line in lines)
			if (!line)
				continue

			if (copytext(line, 1, 2) == ";")
				continue

			var/pos = findtext(line, " - ", 1, null)
			if (pos)
				var/m_key = copytext(line, 1, pos)
				var/a_lev = copytext(line, pos + 3, length(line) + 1)
				admins[m_key] = a_lev
				diary << ("ADMIN: [m_key] = [a_lev]")

/world/proc/load_testers()
	var/text = file2text("config/testers.txt")
	if (!text)
		diary << "Failed to load config/testers.txt\n"
	else
		var/list/lines = dd_text2list(text, "\n")
		for(var/line in lines)
			if (!line)
				continue

			if (copytext(line, 1, 2) == ";")
				continue

			var/pos = findtext(line, " - ", 1, null)
			if (pos)
				var/m_key = copytext(line, 1, pos)
				var/a_lev = copytext(line, pos + 3, length(line) + 1)
				admins[m_key] = a_lev


/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	//config.loadforumsql("config/forumdbconfig.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn

/world/proc/KickInactiveClients()
	for(var/client/C)
		if(!C.holder && ((C.inactivity/10)/60) >= 10)
			if(C.mob)
				if(!istype(C.mob, /mob/dead/))
					log_access("AFK: [key_name(C)]")
					C << "\red You have been inactive for more than 10 minutes and have been disconnected."
					C.mob.logged_in = 0
			del(C)
	spawn(3000) KickInactiveClients()//more or less five minutes
