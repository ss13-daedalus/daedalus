// Are we doing stupid preprocessor macro tricks in BYOND?  Yes.  Yes we are.
#ifndef __DEFINE_DM
#define __DEFINE_DM

// Would it surprise you that no one ever got around to defining TRUE and
// FALSE as permanent defines?  No, no it shouldn't.
#define TRUE 1
#define FALSE 0

#define PI 3.1415

#define R_IDEAL_GAS_EQUATION	8.31 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa

#define CELL_VOLUME 2500	//liters in a cell
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC

#define O2STANDARD 0.21
#define N2STANDARD 0.79

#define MOLES_O2STANDARD MOLES_CELLSTANDARD*O2STANDARD	// O2 standard value (21%)
#define MOLES_N2STANDARD MOLES_CELLSTANDARD*N2STANDARD	// N2 standard value (79%)

#define MOLES_PHORON_VISIBLE	0.5 //Moles in a standard cell after which phoron is visible

#define BREATH_VOLUME 0.5	//liters in a normal breath
#define BREATH_PERCENTAGE BREATH_VOLUME/CELL_VOLUME
	//Amount of air to take a from a tile
#define HUMAN_NEEDED_OXYGEN	MOLES_CELLSTANDARD*BREATH_PERCENTAGE*0.16
	//Amount of air needed before pass out/suffocation commences

// Pressure limits.
#define HAZARD_HIGH_PRESSURE 750
#define HIGH_STEP_PRESSURE HAZARD_HIGH_PRESSURE/2
#define WARNING_HIGH_PRESSURE HAZARD_HIGH_PRESSURE*0.7
#define HAZARD_LOW_PRESSURE 20
#define WARNING_LOW_PRESSURE HAZARD_LOW_PRESSURE*2.5
#define MAX_PRESSURE_DAMAGE 20

// Doors!
#define DOOR_CRUSH_DAMAGE 10

// Factor of how fast mob nutrition decreases
#define	HUNGER_FACTOR 0.1
#define	REAGENTS_METABOLISM 0.05
#define REAGENTS_OVERDOSE 30

#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.05
	//Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_TO_SUSPEND MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND
	//Minimum amount of air that has to move before a group processing can be suspended

#define MINIMUM_MOLES_DELTA_TO_MOVE MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND //Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE	T20C+100 		  //or this (or both, obviously)

#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND 0.012
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 4
	//Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 0.5
	//Minimum temperature difference before the gas temperatures are just set to be equal

#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION		T20C+10
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION	T20C+200

#define FLOOR_HEAT_TRANSFER_COEFFICIENT 0.08
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.03
#define SPACE_HEAT_TRANSFER_COEFFICIENT 0.20 //a hack to partly simulate radiative heat
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.40
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.10 //a hack for now
	//Must be between 0 and 1. Values closer to 1 equalize temperature faster
	//Should not exceed 0.4 else strange heat flow occur

#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD	150+T0C
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST	100+T0C
#define FIRE_SPREAD_RADIOSITY_SCALE		0.85
#define FIRE_CARBON_ENERGY_RELEASED	  500000 //Amount of heat released per mole of burnt carbon into the tile
#define FIRE_PHORON_ENERGY_RELEASED	 3000000 //Amount of heat released per mole of burnt phoron into the tile
#define FIRE_GROWTH_RATE			25000 //For small fires

//Phoron fire properties
#define PHORON_MINIMUM_BURN_TEMPERATURE		100+T0C
#define PHORON_UPPER_TEMPERATURE			1370+T0C
#define PHORON_MINIMUM_OXYGEN_NEEDED		2
#define PHORON_MINIMUM_OXYGEN_PHORON_RATIO	30
#define PHORON_OXYGEN_FULLBURN				10

#define T0C 273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.7					// -270.3degC

#define TANK_LEAK_PRESSURE		(30.*ONE_ATMOSPHERE)	// Tank starts leaking
#define TANK_RUPTURE_PRESSURE	(40.*ONE_ATMOSPHERE) // Tank spills all contents into atmosphere

#define TANK_FRAGMENT_PRESSURE	(50.*ONE_ATMOSPHERE) // Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    (10.*ONE_ATMOSPHERE) // +1 for each SCALE kPa aboe threshold
								// was 2 atm

#define NORMPIPERATE 30					//pipe-insulation rate divisor
#define HEATPIPERATE 8					//heat-exch pipe insulation

#define FLOWFRAC 0.99				// fraction of gas transfered per process

#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up


//FLAGS BITMASK
#define ONBACK 1			// can be put in back slot
#define TABLEPASS 2			// can pass by a table or rack

/********************************************************************************
*	WOO WOO WOO	THIS IS UNUSED	WOO WOO WOO										*
*	#define HALFMASK 4	// mask only gets 1/2 of air supply from internals		*
*	WOO WOO WOO	THIS IS UNUSED	WOO WOO WOO										*
********************************************************************************/

#define HEADSPACE 4			// head wear protects against space

#define MASKINTERNALS 8		// mask allows internals
#define SUITSPACE 8			// suit protects against space

#define USEDELAY 16			// 1 second extra delay on use (Can be used once every 2s)
#define NODELAY 32768		// 1 second attackby delay skipped (Can be used once every 0.2s). Most objects have a 1s attackby delay, which doesn't require a flag.
#define NOSHIELD 32			// weapon not affected by shield
#define CONDUCT 64			// conducts electricity (metal etc.)
#define ONBELT 128			// can be put in belt slot
#define FPRINT 256			// takes a fingerprint
#define ON_BORDER 512		// item has priority to check when entering or leaving

#define GLASSESCOVERSEYES 1024
#define MASKCOVERSEYES 1024		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES 1024		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH 2048		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH 2048

#define NOSLIP 1024 //prevents from slipping on wet floors, in space etc

#define OPENCONTAINER	4096	// is an open container for chemistry purposes

#define PLASMAGUARD 8192		//Does not get contaminated by plasma.

#define	NOREACT	16384 //Reagents dont' react inside this container.

#define BLOCKHAIR 32768			// temporarily removes the user's hair icon

//flags for pass_flags
#define PASSTABLE 1
#define PASSGLASS 2
#define PASSGRILLE 4
#define PASSBLOB 8

//turf-only flags
#define NOJAUNT 1


//Bit flags for the flags_inv variable, which determine when a piece of clothing hides another. IE a helmet hiding glasses.
#define HIDEGLOVES 1		//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESUITSTORAGE 2	//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEJUMPSUIT 4		//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDESHOES 8			//APPLIES ONLY TO THE EXTERIOR SUIT!!
#define HIDEMASK 1			//APPLIES ONLY TO HELMETS!!
#define HIDEEARS 2			//APPLIES ONLY TO HELMETS!!
#define HIDEEYES 4			//APPLIES ONLY TO HELMETS!!


//Cant seem to find a mob bitflags area other than the powers one

// bitflags for clothing parts
#define HEAD			1
#define UPPER_TORSO		2
#define LOWER_TORSO		4
#define LEG_LEFT		8
#define LEG_RIGHT		16
#define LEGS			24
#define FOOT_LEFT		32
#define FOOT_RIGHT		64
#define FEET			96
#define ARM_LEFT		128
#define ARM_RIGHT		256
#define ARMS			384
#define HAND_LEFT		512
#define HAND_RIGHT		1024
#define HANDS			1536

#define FULL_BODY		2047

//bitflags for mutations
var/const
	TK				=(1<<0)
	COLD_RESISTANCE	=(1<<1)
	XRAY			=(1<<2)
	HULK			=(1<<3)
	CLUMSY			=(1<<4)
	FAT				=(1<<5)
	HUSK			=(1<<6)
	LASER			=(1<<7)
	HEAL			=(1<<8)
	mNobreath		=(1<<9)
	mRemote			=(1<<10)
	mRegen			=(1<<11)
	mRun			=(1<<12)
	mRemotetalk		=(1<<13)
	mMorph			=(1<<14)
	mBlend			=(1<<15)
//the "&" operator cannot go higher than (2^16)-1
	mHallucination	=(1<<0)
	mFingerprints	=(1<<1)
	mShock			=(1<<2)
	mSmallsize		=(1<<3)
	NOCLONE			=(1<<4)

//mob/var/stat things
var/const
	CONSCIOUS = 0
	UNCONSCIOUS = 1
	DEAD = 2

// channel numbers for power
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
#define TOTAL 4	//for total power used only

// bitflags for machine stat variable
#define BROKEN 1
#define NOPOWER 2
#define POWEROFF 4		// tbd
#define MAINT 8			// under maintaince
#define EMPED 16		// temporary broken by EMP pulse

//bitflags for door switches.
#define OPEN 1
#define IDSCAN 2
#define BOLTS 4
#define SHOCK 8
#define SAFE 16

#define ENGINE_EJECT_Z 3

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL 50
#define MAX_STACK_AMOUNT_GLASS 50
#define MAX_STACK_AMOUNT_RODS 60

var/list/accessable_z_levels = list("3" = 15, "4" = 35, "6" = 50)
//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//(Exceptions: extended, sandbox and nuke) -Errorage
//Was list("1" = 10, "3" = 15, "4" = 60, "5" = 15); changed it to list("3" = 30, "4" = 70).
//Spacing should be a reliable method of getting rid of a body -- Urist.

#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))


var/list/global_mutations = list() // list of hidden mutation things

//Bluh shields


//Damage things
#define BRUTE "brute"
#define BURN "fire"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"
#define HALLOSS "halloss"

#define STUN "stun"
#define WEAKEN "weaken"
#define PARALYZE "paralize"
#define IRRADIATE "irradiate"
#define STUTTER "stutter"
#define SLUR "slur"
#define EYE_BLUR "eye_blur"
#define DROWSY "drowsy"

var/static/list/scarySounds = list('sound/weapons/thudswoosh.ogg','sound/weapons/Taser.ogg','sound/weapons/armbomb.ogg','sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg','sound/voice/hiss5.ogg','sound/voice/hiss6.ogg','sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg','sound/items/Welder.ogg','sound/items/Welder2.ogg','sound/machines/airlock.ogg','sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')

//Security levels
#define SEC_LEVEL_GREEN 0
#define SEC_LEVEL_BLUE 1
#define SEC_LEVEL_RED 2
#define SEC_LEVEL_DELTA 3

#define TRANSITIONEDGE 7 //Distance from edge to move to another z-level

// Maximum and minimum character ages.
var/const/minimum_age = 20
var/const/maximum_age = 65

// Various states used by the game_ticker.
#define GAME_STATE_PREGAME 1
#define GAME_STATE_SETTING_UP 2
#define GAME_STATE_PLAYING 3
#define GAME_STATE_FINISHED 4

// States of matter.  Don't ask where plasma is.
#define SOLID 1
#define LIQUID 2
#define GAS 3

#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16
#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
#define INFINITY 1e31 //closer then enough

//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216

// Antigens for the disease code.
#define ANTIGEN_A  1
#define ANTIGEN_B  2
#define ANTIGEN_RH 4
#define ANTIGEN_Q  8
#define ANTIGEN_U  16
#define ANTIGEN_V  32
#define ANTIGEN_X  64
#define ANTIGEN_Y  128
#define ANTIGEN_Z  256
#define ANTIGEN_M  512
#define ANTIGEN_N  1024
#define ANTIGEN_P  2048
#define ANTIGEN_O  4096

// Afflictions from the disease code.
#define DISEASE_HOARSE  2
#define DISEASE_WHISPER 4

// Defines from the older disease code.
#define NON_CONTAGIOUS -1
#define SPECIAL 0
#define CONTACT_GENERAL 1
#define CONTACT_HANDS 2
#define CONTACT_FEET 3
#define AIRBORNE 4
#define BLOOD 5

#define SCANNER 1
#define PANDEMIC 2

// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
#define SHUTTLEARRIVETIME 600    // 10 minutes = 600 seconds
#define SHUTTLELEAVETIME 180     // 3 minutes = 180 seconds
#define SHUTTLETRANSITTIME 120      // 2 minutes = 120 seconds

#define FORWARD -1
#define BACKWARD 1

#define PLAYER_WEIGHT 5
#define HUMAN_DEATH -5000
#define OTHER_DEATH -5000
#define EXPLO_SCORE -10000 //boum

#define COOLDOWN_TIME 12000 // Twenty minutes
#define MIN_ROUND_TIME 18000

#define FLAT_PERCENT 0

// What's the name of this place?  Put here so that it can potentially
// be changed in a single location in a fork rather than scattered
// throughout the code.
#define LOCATION_NAME "NSS Icarus"

//	Security access levels
#define ACCESS_SECURITY 1
#define ACCESS_BRIG 2
#define ACCESS_ARMORY 3
#define ACCESS_FORENSICS_LOCKERS 4
#define ACCESS_MEDICAL 5
#define ACCESS_MORGUE 6
#define ACCESS_TOX 7
#define ACCESS_TOX_STORAGE 8
#define ACCESS_MEDLAB 9
#define ACCESS_ENGINE 10
#define ACCESS_ENGINE_EQUIP 11
#define ACCESS_MAINT_TUNNELS 12
#define ACCESS_EXTERNAL_AIRLOCKS 13
#define ACCESS_EMERGENCY_STORAGE 14
#define ACCESS_CHANGE_IDS 15
#define ACCESS_AI_UPLOAD 16
#define ACCESS_TELEPORTER 17
#define ACCESS_EVA 18
#define ACCESS_HEADS 19
#define ACCESS_CAPTAIN 20
#define ACCESS_ALL_PERSONAL_LOCKERS 21
#define ACCESS_CHAPEL_OFFICE 22
#define ACCESS_TECH_STORAGE 23
#define ACCESS_ATMOSPHERICS 24
#define ACCESS_BAR 25
#define ACCESS_JANITOR 26
#define ACCESS_CREMATORIUM 27
#define ACCESS_KITCHEN 28
#define ACCESS_ROBOTICS 29
#define ACCESS_RD 30
#define ACCESS_CARGO 31
#define ACCESS_CONSTRUCTION 32
#define ACCESS_CHEMISTRY 33
#define ACCESS_CARGO_BOT 34
#define ACCESS_HYDROPONICS 35
#define ACCESS_MANUFACTURING 36
#define ACCESS_LIBRARY 37
#define ACCESS_LAWYER 38
#define ACCESS_VIROLOGY 39
#define ACCESS_CMO 40
#define ACCESS_QM 41
#define ACCESS_COURT 42
#define ACCESS_CLOWN 43
#define ACCESS_MIME 44
#define ACCESS_SURGERY 45
#define ACCESS_THEATRE 46
#define ACCESS_RESEARCH 47
#define ACCESS_MINING 48
#define ACCESS_MINING_OFFICE 49 //not in use
#define ACCESS_MAILSORTING 50
#define ACCESS_MINT 51
#define ACCESS_MINT_VAULT 52
#define ACCESS_HEADS_VAULT 53
#define ACCESS_MINING_STATION 54
#define ACCESS_XENOBIOLOGY 55
#define ACCESS_CE 56
#define ACCESS_HOP 57
#define ACCESS_HOS 58
#define ACCESS_RC_ANNOUNCE 59 //Request console announcements
#define ACCESS_KEYCARD_AUTH 60 //Used for events which require at least two people to confirm them
#define ACCESS_TCOMSAT 61 // has access to the entire telecomms satellite / machinery

	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
	Mostly for admin fun times.*/
#define ACCESS_CENT_GENERAL 101//General facilities.
#define ACCESS_CENT_THUNDER 102//Thunderdome.
#define ACCESS_CENT_SPECOPS 103//Special Ops.
#define ACCESS_CENT_MEDICAL 104//Medical/Research
#define ACCESS_CENT_LIVING 105//Living quarters.
#define ACCESS_CENT_STORAGE 106//Generic storage areas.
#define ACCESS_CENT_TELEPORTED 107//Teleporter.
#define ACCESS_CENT_CREED 108//Creed's office.
#define ACCESS_CENT_CAPTAIN 109//Captain's office/ID comp/AI.

	//The Syndicate
#define ACCESS_SYNDICATE 150//General Syndicate Access

	//MONEY
#define ACCESS_CRATE_CASH 200


//	Airlock wires
#define AIRLOCK_WIRE_IDSCAN 1
#define AIRLOCK_WIRE_MAIN_POWER1 2
#define AIRLOCK_WIRE_MAIN_POWER2 3
#define AIRLOCK_WIRE_DOOR_BOLTS 4
#define AIRLOCK_WIRE_BACKUP_POWER1 5
#define AIRLOCK_WIRE_BACKUP_POWER2 6
#define AIRLOCK_WIRE_OPEN_DOOR 7
#define AIRLOCK_WIRE_AI_CONTROL 8
#define AIRLOCK_WIRE_ELECTRIFY 9
#define AIRLOCK_WIRE_CRUSH 10
#define AIRLOCK_WIRE_LIGHT 11
#define AIRLOCK_WIRE_HOLDOPEN 12
#define AIRLOCK_WIRE_FAKEBOLT1 13
#define AIRLOCK_WIRE_FAKEBOLT2 14
#define AIRLOCK_WIRE_ALERTAI 15
#define AIRLOCK_WIRE_DOOR_BOLTS_2 16
//#define AIRLOCK_WIRE_FINGERPRINT 17

#define REGULATE_RATE 5

#define TRANSMISSION_WIRE 0
#define TRANSMISSION_RADIO 1

/////////////////////////// DNA DATUM

#define STRUCDNASIZE 27

#define COMM_FREQ 1353 //command, colored gold in chat window
#define SYND_FREQ 1213

/* filters */
#define RADIO_TO_AIRALARM "1"
#define RADIO_FROM_AIRALARM "2"
#define RADIO_CHAT "3"
#define RADIO_ATMOSIA "4"
#define RADIO_NAVBEACONS "5"
#define RADIO_AIRLOCK "6"
#define RADIO_SECBOT "7"
#define RADIO_MULEBOT "8"
#define RADIO_MAGNETS "9"

#define AALARM_MODE_SCRUBBING    1
#define AALARM_MODE_VENTING      2 //makes draught
#define AALARM_MODE_PANIC        3 //constantly sucks all air
#define AALARM_MODE_REPLACEMENT  4 //sucks off all air, then refill and swithes to scrubbing
#define AALARM_MODE_OFF          5

#define AALARM_SCREEN_MAIN    1
#define AALARM_SCREEN_VENT    2
#define AALARM_SCREEN_SCRUB   3
#define AALARM_SCREEN_MODE    4
#define AALARM_SCREEN_SENSORS 5

#define SPECIFIC_HEAT_TOXIN      200
#define SPECIFIC_HEAT_AIR     20
#define SPECIFIC_HEAT_CDO     30
#define HEAT_CAPACITY_CALCULATION(oxygen,carbon_dioxide,nitrogen,toxins) \
	(carbon_dioxide*SPECIFIC_HEAT_CDO + (oxygen+nitrogen)*SPECIFIC_HEAT_AIR + toxins*SPECIFIC_HEAT_TOXIN)

#define MINIMUM_HEAT_CAPACITY 0.0003
#define QUANTIZE(variable)    (round(variable,0.0001))

#define SOLAR_GEN_RATE 1500

#define APC_WIRE_IDSCAN 1
#define APC_WIRE_MAIN_POWER1 2
#define APC_WIRE_MAIN_POWER2 3
#define APC_WIRE_AI_CONTROL 4

#define SMES_MAX_CHARGE_LEVEL 200000
#define SMES_MAX_OUTPUT 200000
#define SMES_RATE 0.05         // rate of internal charge to external power

// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3
#define LIGHTING_POWER_FACTOR 20    //20W per unit luminosity

// End the stupid preprocessor macro tricks.
#endif
