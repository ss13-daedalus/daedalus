/* Constant variables.  Apparently BYOND does really stupid things
   with its preprocessor, so most things you'd want to make #defines
   need to be constant variables instead.  This file will therefore
   likely grow considerably over time. */

var/const

	// States of matter.  Don't ask where plasma is.
	SOLID = 1
	LIQUID = 2
	GAS = 3

	SPEED_OF_LIGHT = 3e8 //not exact but hey!
	SPEED_OF_LIGHT_SQ = 9e+16
	FIRE_DAMAGE_MODIFIER = 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
	AIR_DAMAGE_MODIFIER = 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
	INFINITY = 1e31 //closer then enough

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
	MAX_MESSAGE_LEN = 1024
	MAX_PAPER_MESSAGE_LEN = 3072
	MAX_BOOK_MESSAGE_LEN = 9216

	shuttle_time_in_station = 1800 // 3 minutes in the station
	shuttle_time_to_arrive = 6000 // 10 minutes to arrive

	// Antigens for the disease code.
	ANTIGEN_A  = 1
	ANTIGEN_B  = 2
	ANTIGEN_RH = 4
	ANTIGEN_Q  = 8
	ANTIGEN_U  = 16
	ANTIGEN_V  = 32
	ANTIGEN_X  = 64
	ANTIGEN_Y  = 128
	ANTIGEN_Z  = 256
	ANTIGEN_M  = 512
	ANTIGEN_N  = 1024
	ANTIGEN_P  = 2048
	ANTIGEN_O  = 4096

	// Afflictions from the disease code.
	DISEASE_HOARSE  = 2
	DISEASE_WHISPER = 4
