var/global
	obj/datacore/data_core = null
	obj/effect/overlay/plmaster = null
	obj/effect/overlay/slmaster = null

	//obj/hud/main_hud1 = null

	list/machines = list()
	list/processing_objects = list()
	list/active_diseases = list()
		//items that ask to be called every cycle

	defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event

	//list/global_map = null //Borked, do not touch. DMTG
	//list/global_map = list(list(1,5),list(4,3))//an array of map Z levels.
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space

	BLINDBLOCK = 0
	DEAFBLOCK = 0
	HULKBLOCK = 0
	TELEBLOCK = 0
	FIREBLOCK = 0
	XRAYBLOCK = 0
	CLUMSYBLOCK = 0
	FAKEBLOCK = 0
	BLOCKADD = 0
	DIFFMUT = 0
	HEADACHEBLOCK = 0
	COUGHBLOCK = 0
	TWITCHBLOCK = 0
	NERVOUSBLOCK = 0
	NOBREATHBLOCK = 0
	REMOTEVIEWBLOCK = 0
	REGENERATEBLOCK = 0
	INCREASERUNBLOCK = 0
	REMOTETALKBLOCK = 0
	MORPHBLOCK = 0
	BLENDBLOCK = 0
	HALLUCINATIONBLOCK = 0
	NOPRINTSBLOCK = 0
	SHOCKIMMUNITYBLOCK = 0
	SMALLSIZEBLOCK = 0
	GLASSESBLOCK = 0
	MONKEYBLOCK = 27

	skipupdate = 0
	///////////////
	eventchance = 1 //% per 2 mins
	EventsOn = 1
	hadevent = 0
	blobevent = 0
	///////////////

	diary = null
	diaryofmeanpeople = null
	station_name = null
	game_version = "Daedalus"

	datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
	going = 1.0
	master_mode = "traitor"//"extended"
	secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

	datum/engine_eject/engine_eject_control = null
	host = null
	aliens_allowed = 1
	ooc_allowed = 1
	dooc_allowed = 1
	traitor_scaling = 1
	dna_ident = 1
	abandon_allowed = 1
	enter_allowed = 1
//	guests_allowed = 1
	shuttle_frozen = 0
	shuttle_left = 0
	tinted_weldhelh = 1

	list/jobMax = list()
	list/bombers = list(  )
	list/admin_log = list (  )
	list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
	list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
	list/admins = list(  )
	list/shuttles = list(  )
	list/reg_dna = list(  )
//	list/traitobj = list(  )


	CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
	CHARGELEVEL = 0.001 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

	shuttle_z = 2	//default
	airtunnel_start = 68 // default
	airtunnel_stop = 68 // default
	airtunnel_bottom = 72 // default
	list/monkeystart = list()
	list/wizardstart = list()
	list/newplayer_start = list()
	list/latejoin = list()
	list/prisonwarp = list()	//prisoners go to these
	list/holdingfacility = list()	//captured people go here
	list/xeno_spawn = list()//Aliens spawn at these.
//	list/mazewarp = list()
	list/tdome1 = list()
	list/tdome2 = list()
	list/tdomeobserve = list()
	list/tdomeadmin = list()
	list/prisonsecuritywarp = list()	//prison security goes to these
	list/prisonwarped = list()	//list of players already warped
	list/blobstart = list()
//	list/traitors = list()	//traitor list
	list/cardinal = list( NORTH, SOUTH, EAST, WEST )
	list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	list/emclosets = list()	//random emergency closets woo

	datum/station_state/start_state = null
	datum/configuration/config = null
	datum/vote/vote = null
	datum/sun/sun = null

	list/combatlog = list()
	list/IClog = list()
	list/OOClog = list()
	list/adminlog = list()


	list/powernets = null

	Debug = 0	// global debug switch
	Debug2 = 0

	datum/debug/debugobj

	datum/module_types/mods = new()

	wavesecret = 0

	shuttlecoming = 0

	join_motd = null
	rules = null
	forceblob = 0

	custom_event_msg = null

	//airlockWireColorToIndex takes a number representing the wire color, e.g. the orange wire is always 1, the dark red wire is always 2, etc. It returns the index for whatever that wire does.
	//airlockIndexToWireColor does the opposite thing - it takes the index for what the wire does, for example AIRLOCK_WIRE_IDSCAN is 1, AIRLOCK_WIRE_POWER1 is 2, etc. It returns the wire color number.
	//airlockWireColorToFlag takes the wire color number and returns the flag for it (1, 2, 4, 8, 16, etc)
	list/airlockWireColorToFlag = RandomAirlockWires()
	list/airlockIndexToFlag
	list/airlockIndexToWireColor
	list/airlockWireColorToIndex
	list/APCWireColorToFlag = randomize_apc_wires()
	list/APCIndexToFlag
	list/APCIndexToWireColor
	list/APCWireColorToIndex
	list/BorgWireColorToFlag = RandomBorgWires()
	list/BorgIndexToFlag
	list/BorgIndexToWireColor
	list/BorgWireColorToIndex
	list/ScrambledFrequencies = list( ) //These are used for electrical storms, and anything else that jams radios.
	list/UnscrambledFrequencies = list( )
	list/AAlarmWireColorToFlag = RandomAAlarmWires() // Air Alarm hacking wires.
	list/AAlarmIndexToFlag
	list/AAlarmIndexToWireColor
	list/AAlarmWireColorToIndex

	list/paper_blacklist = list("script","frame","iframe","input","button","a","embed","object")

	// SQLite configuration. You can also use the config/dbconfig.txt file.
	sqldb = "data/daedalus.db"

	// Feedback gathering sql connection
	sqlfdbkdb = "data/daedalus.db"

	sqllogging = 0 // Should we log deaths, population stats, etc?


	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
	fileaccess_timer = 600 //Cannot access files by ftp until the game is finished setting up and stuff.

	list/ANTIGENS = list("[ANTIGEN_A]" = "A", "[ANTIGEN_B]" = "B", "[ANTIGEN_RH]" = "RH", "[ANTIGEN_Q]" = "Q",
				"[ANTIGEN_U]" = "U", "[ANTIGEN_V]" = "V", "[ANTIGEN_Z]" = "Z", "[ANTIGEN_M]" = "M",
				"[ANTIGEN_N]" = "N", "[ANTIGEN_P]" = "P", "[ANTIGEN_O]" = "O")

	datum/news_topic_handler/news_topic_handler

	datum/controller/game_ticker/ticker

	religion_name = null
	max_explosion_range = 14
	list/datum/pipe_network/pipe_networks = list()


	security_level = 0
	//0 = code green
	//1 = code blue
	//2 = code red
	//3 = code delta

	list/modules = list(			// global associative list
"/obj/machinery/power/apc" = "card_reader,power_control,id_auth,cell_power,cell_charge")

	datum/shuttle_controller/emergency_shuttle/emergency_shuttle

	list/spells = typesof(/obj/effect/proc_holder/spell) //needed for the badmin verb for now

	datum/tension/tension_master

	list/teleport_locs = list()
	list/ghost_teleport_locs = list()

	list/centcom_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
		/area/shuttle/escape_pod1/centcom,
		/area/shuttle/escape_pod2/centcom,
		/area/shuttle/escape_pod3/centcom,
		/area/shuttle/escape_pod5/centcom,
		/area/shuttle/transport1/centcom,
		/area/shuttle/transport2/centcom,
		/area/shuttle/administration/centcom,
		/area/shuttle/specops/centcom,
	)

	list/the_station_areas = list (
		/area/shuttle/arrival,
		/area/shuttle/escape/station,
		/area/shuttle/escape_pod1/station,
		/area/shuttle/escape_pod2/station,
		/area/shuttle/escape_pod3/station,
		/area/shuttle/escape_pod5/station,
		/area/shuttle/mining/station,
		/area/shuttle/transport1/station,
		/area/shuttle/prison/station,
		/area/shuttle/administration/station,
		/area/shuttle/specops/station,
		/area/atmos,
		/area/maintenance,
		/area/hallway,
		/area/bridge,
		/area/crew_quarters,
		/area/holodeck,
		/area/mint,
		/area/library,
		/area/chapel,
		/area/lawoffice,
		/area/engine,
		/area/solar,
		/area/assembly,
		/area/teleporter,
		/area/medical,
		/area/security,
		/area/quartermaster,
		/area/janitor,
		/area/hydroponics,
		/area/toxins,
		/area/storage,
		/area/construction,
		/area/ai_monitored/storage/eva, //do not try to simplify to "/area/ai_monitored" --rastaf0
		/area/ai_monitored/storage/secure,
		/area/ai_monitored/storage/emergency,
		/area/turret_protected/ai_upload, //do not try to simplify to "/area/turret_protected" --rastaf0
		/area/turret_protected/ai_upload_foyer,
		/area/turret_protected/ai,
	)

	company_name = "Nanotrasen"

// It turns out that /var/const can't handle lists, because lists use
// an initializer.  Sigh.  That's no reason that we shouldn't make
// actual "constant" lists explicit via naming convention and a
// separate location, though, so: below are all lists that should not
// ever be changed in code.

/var/global
	AI_VERB_LIST = list(
		/mob/living/silicon/ai/proc/ai_call_shuttle,
		/mob/living/silicon/ai/proc/show_laws_verb,
		/mob/living/silicon/ai/proc/ai_camera_track,
		/mob/living/silicon/ai/proc/ai_alerts,
		/mob/living/silicon/ai/proc/ai_camera_list,
		/mob/living/silicon/ai/proc/ai_network_change,
		/mob/living/silicon/ai/proc/ai_statuschange,
		/mob/living/silicon/ai/proc/ai_hologram_change,
		/mob/living/silicon/ai/proc/ai_roster,
	)
	
//Few global vars to track the blob
var
	list/blobs = list()
	list/blob_cores = list()
	list/blob_nodes = list()



	list/powers = typesof(/obj/effect/proc_holder/power) //needed for the badmin verb for now
	list/obj/effect/proc_holder/power/powerinstances = list()

	
	hsboxspawn = 1
	list
		hrefs = list(
					"hsbsuit" = "Suit Up (Space Travel Gear)",
					"hsbmetal" = "Spawn 50 Metal",
					"hsbglass" = "Spawn 50 Glass",
					"hsbairlock" = "Spawn Airlock",
					"hsbregulator" = "Spawn Air Regulator",
					"hsbfilter" = "Spawn Air Filter",
					"hsbcanister" = "Spawn Canister",
					"hsbfueltank" = "Spawn Welding Fuel Tank",
					"hsbwater	tank" = "Spawn Water Tank",
					"hsbtoolbox" = "Spawn Toolbox",
					"hsbmedkit" = "Spawn Medical Kit")

	list/space_surprises = list(
		/obj/item/clothing/mask/facehugger/angry			=4,
		//	/obj/creature										=0,
		//	/obj/item/weapon/rcd								=0,
		//	/obj/item/weapon/rcd_ammo							=0,
		//	/obj/item/weapon/spacecash							=0,
		//	/obj/item/weapon/cloaking_device					=1,
		//	/obj/item/weapon/gun/energy/teleport_gun			=0,
		//	/obj/item/weapon/rubber_chicken						=0,
			/obj/item/weapon/melee/energy/sword/pirate			=3,
			/obj/structure/closet/syndicate/resources			=2,
		//	/obj/machinery/wish_granter							=1,  // Okayyyy... Mayyyybe Kor is kinda sorta right.  A little.  Tiny bit.  >.>
		//	/obj/item/clothing/glasses/thermal					=2,	// Could maybe be cool as its own rapid mode, sorta like wizard.  Maybe.
		//	/obj/item/weapon/storage/box/stealth/				=2

		//														=11
	)

	list/spawned_surprises = list()

// Copied over from asteroid.dm
	max_secret_rooms = 3

	using_new_click_proc = 0 //TODO ERRORAGE (This is temporary, while the DblClickNew() proc is being tested)

	list/radiochannels = list(
	"Common" = 1459,
	"Science" = 1351,
	"Command" = 1353,
	"Medical" = 1355,
	"Engineering" = 1357,
	"Security" = 1359,
	"Response Team" = 1439,
	"Syndicate" = 1213,
	"Mining" = 1349,
	"Cargo" = 1347,
)
//depenging helpers
	list/DEPT_FREQS = list(1351,1355,1357,1359,1213,1439,1349,1347)
	NUKE_FREQ = 1200 //Randomised on nuke rounds.


	datum/controller/radio/radio_controller

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+++++++++++++++++++++++++++++++++++++//                //++++++++++++++++++++++++++++++++++
======================================SPACE NINJA SETUP====================================
___________________________________________________________________________________________
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
	README:

	Data:

	>> space_ninja.dm << is this file. It contains a variety of procs related to either spawning space ninjas,
	modifying their verbs, various help procs, testing debug-related content, or storing unused procs for later.
	Similar functions should go into this file, along with anything else that may not have an explicit category.
	IMPORTANT: actual ninja suit, gloves, etc, are stored under the appropriate clothing files. If you need to change
	variables or look them up, look there. Easiest way is through the map file browser.

	>> ninja_abilities.dm << contains all the ninja-related powers. Spawning energy swords, teleporting, and the like.
	If more powers are added, or perhaps something related to powers, it should go there. Make sure to describe
	what an ability/power does so it's easier to reference later without looking at the code.
	IMPORTANT: verbs are still somewhat funky to work with. If an argument is specified but is not referenced in a way
	BYOND likes, in the code content, the verb will fail to trigger. Nothing will happen, literally, when clicked.
	This can be bypassed by either referencing the argument properly, or linking to another proc with the argument
	attached. The latter is what I like to do for certain cases--sometimes it's necessary to do that regardless.

	>> ninja_equipment.dm << deals with all the equipment-related procs for a ninja. Primarily it has the suit, gloves,
	and mask. The suit is by far the largest section of code out of the three and includes a lot of code that ties in
	to other functions. This file has gotten kind of large so breaking it up may be in order. I use section hearders.
	IMPORTANT: not much to say here. Follow along with the comments and adding new functions should be a breeze. Also
	know that certain equipment pieces are linked in other files. The energy blade, for example, has special
	functions defined in the appropriate files (airlock, securestorage, etc).

	General Notes:

	I created space ninjas with the expressed purpose of spicing up boring rounds. That is, ninjas are to xenos as marauders are to
	death squads. Ninjas are stealthy, tech-savvy, and powerful. Not to say marauders are all of those things, but a clever ninja
	should have little problem murderampaging their way through just about anything. Short of admin wizards maybe.
	HOWEVER!
	Ninjas also have a fairly great weakness as they require energy to use abilities. If, theoretically, there is a game
	mode based around space ninjas, make sure to account for their energy needs.

	Admin Notes:

	Ninjas are not admin PCs--please do not use them for that purpose. They are another way to participate in the game post-death,
	like pais, xenos, death squads, and cyborgs.
	I'm currently looking for feedback from regular players since beta testing is largely done. I would appreciate if
	you spawned regular players as ninjas when rounds are boring. Or exciting, it's all good as long as there is feedback.
	You can also spawn ninja gear manually if you want to.

	How to do that:
	Make sure your character has a mind.
	Change their assigned_role to "MODE", no quotes. Otherwise, the suit won't initialize.
	Change their special_role to "Space Ninja", no quotes. Otherwise, the character will be gibbed.
	Spawn ninja gear, put it on, hit initialize. Let the suit do the rest. You are now a space ninja.
	I don't recommend messing with suit variables unless you really know what you're doing.

	Miscellaneous Notes:

	Potential Upgrade Tree:
		Energy Shield:
			Extra Ability
			Syndicate Shield device?
				Works like the force wall spell, except can be kept indefinitely as long as energy remains. Toggled on or off.
				Would block bullets and the like.
		Phase Shift
			Extra Ability
			Advanced Sensors?
				Instead of being unlocked at the start, Phase Shieft would become available once requirements are met.
		Uranium-based Recharger:
			Suit Upgrade
			Unsure
				Instead of losing energy each second, the suit would regain the same amount of energy.
				This would not count in activating stealth and similar.
		Extended Battery Life:
			Suit Upgrade
			Battery of higher capacity
				Already implemented. Replace current battery with one of higher capacity.
		Advanced Cloak-Tech device.
			Suit Upgrade
			Syndicate Cloaking Device?
				Remove cloak failure rate.
*/

//=======//RANDOM EVENT//=======//
/*
Also a dynamic ninja mission generator.
I decided to scrap round-specific objectives since keeping track of them would require some form of tracking.
When I already created about 4 new objectives, this doesn't seem terribly important or needed.
*/

	toggle_space_ninja = 0//If ninjas can spawn or not.
	sent_ninja_to_station = 0//If a ninja is already on the station.

/*

	New events system, by Sukasa
	 * Much easier to add to
	 * Very, very simple code, easy to maintain

*/

	list/DisallowedEvents = list(/datum/event/spaceninja, /datum/event/prisonbreak, /datum/event/alieninfestation)
	list/EventTypes = typesof(/datum/event) - /datum/event - DisallowedEvents
	list/OneTimeEvents = list()
	datum/event/ActiveEvent = null
	datum/event/LongTermEvent = null
	is_ninjad_yet = 0

	kill_air = 0

	datum/controller/air_system/air_master
