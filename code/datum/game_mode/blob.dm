/datum/game_mode/blob
	name = "blob"
	config_tag = "blob"

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10


	var/const/waittime_l = 1800 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 3600 //upper bound on time before intercept arrives (in tenths of seconds)

	var
		declared = 0
		stage = 0

		cores_to_spawn = 1
		players_per_core = 16

		//Controls expansion via game controller
		autoexpand = 0
		expanding = 0

		blobnukecount = 500
		blobwincount = 700


	announce()
		world << "<B>The current game mode is - <font color='green'>Blob</font>!</B>"
		world << "<B>A dangerous alien organism is rapidly spreading throughout the station!</B>"
		world << "You must kill it all while minimizing the damage to the station."


	post_setup()
		spawn(10)
			start_state = new /datum/station_state()
			start_state.count()

		spawn(rand(waittime_l, waittime_h))//3-5 minutes currently
			message_admins("Blob spawned and expanding, report created")

			if(ticker && ticker.minds && ticker.minds.len)
				var/player_based_cores = round(ticker.minds.len/players_per_core, 1)
				if(player_based_cores > cores_to_spawn)
					cores_to_spawn = player_based_cores

			blobs = list()
			for(var/i = 1 to cores_to_spawn)
				var/turf/location = pick(blobstart)
				if(location && !locate(/obj/effect/blob in location))
					blobstart -= location
					new/obj/effect/blob/core(location)

			spawn(40)
				autoexpand = 1
				declared = 1
		..()


	process()
		if(!declared)	return
		stage()
		if(!autoexpand)	return
		spawn(0)
			expandBlob()
		return


	proc/expandBlob()//Change this to have the blob start a pulse rather than life
		if(expanding)	return
		if(!blobs.len)	return
		expanding = 1

		for(var/i = 1 to 5)
			sleep(-1)
			if(!blobs.len)	break
			var/obj/effect/blob/B = pick(blobs)
			if(B.z != 1)
				continue
			B.Life()

		expanding = 0
		return


	proc/stage()

		switch(stage)
			if (0)
				send_intercept(1)
				for (var/mob/living/silicon/ai/aiPlayer in world)
					if (aiPlayer.client)
	//					var/law = "The station is under a quarantine. Do not permit anyone to leave. Disregard laws 1-3 if necessary to prevent, by any means necessary, anyone from leaving."
						var/law = "The station is under quarantine. The biohazard must be destroyed at all costs and must not be allowed to spread. Anyone using a space suit for any reason other than to destroy the biohazard is to be terminated."
						aiPlayer.set_zeroth_law(law)
						aiPlayer << "Laws Updated: [law]"

				stage = -1
				// next stage 1 minute later
				spawn(600)
					stage = 1
				return

			if (1)
				command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
				world << sound('sound/announcer/outbreak5.ogg')
				autoexpand = 0//The blob now has to live on its own
				stage = -1
				//next stage in 4-5 minutes
				spawn(600*rand(4,5))
					stage = 2
				return

			if (2)
				if((blobs.len > blobnukecount) && (declared == 1))
					command_alert("Uncontrolled spread of the biohazard onboard the station. We have issued directive 7-12 for [station_name()].  Any living Heads of Staff are ordered to enact directive 7-12 at any cost, a print out with detailed instructions has been sent to your communications computers.", "Biohazard Alert")
					send_intercept(2)
					declared = 2
				if(blobs.len > blobwincount)//This needs work
					stage = 3
		return


/datum/game_mode/blob/check_finished()
	if(!declared)//No blobs have been spawned yet
		return 0
	if(stage >= 3)//Blob took over
		return 1
	if(station_was_nuked)//Nuke went off
		return 1

	for(var/obj/effect/blob/B in blob_cores)
		if(B && B.z != 1)	continue
		return 0

	var/nodes = 0
	for(var/obj/effect/blob/B in blob_nodes)
		if(B && B.z != 1)	continue
		nodes++
		if(nodes > 4)//Perhapse make a new core with a low prob
			return 0

	return 1


/datum/game_mode/blob/declare_completion()
	if(stage >= 3)
		feedback_set_details("round_end_result","loss - blob took over")
		world << "<FONT size = 3><B>The blob has taken over the station!</B></FONT>"
		world << "<B>The entire station was eaten by the Blob</B>"
		check_quarantine()

	else if(station_was_nuked)
		feedback_set_details("round_end_result","halfwin - nuke")
		world << "<FONT size = 3><B>Partial Win: The station has been destroyed!</B></FONT>"
		world << "<B>Directive 7-12 has been successfully carried out preventing the Blob from spreading.</B>"

	else
		feedback_set_details("round_end_result","win - blob eliminated")
		world << "<FONT size = 3><B>The staff has won!</B></FONT>"
		world << "<B>The alien organism has been eradicated from the station</B>"

		var/datum/station_state/end_state = new /datum/station_state()
		end_state.count()
		var/percent = round( 100.0 *  start_state.score(end_state), 0.1)
		world << "<B>The station is [percent]% intact.</B>"
		log_game("Blob mode was won with station [percent]% intact.")
		world << "\blue Rebooting in 30s"
	..()
	return 1


/datum/game_mode/blob/proc/check_quarantine()
	var/numDead = 0
	var/numAlive = 0
	var/numSpace = 0
	var/numOffStation = 0
	for (var/mob/living/silicon/ai/aiPlayer in world)
		for(var/mob/M in world)
			if ((M != aiPlayer && M.client))
				if (M.stat == 2)
					numDead += 1
				else
					var/T = M.loc
					if (istype(T, /turf/space))
						numSpace += 1
					else if(istype(T, /turf))
						if (M.z!=1)
							numOffStation += 1
						else
							numAlive += 1
		if (numSpace==0 && numOffStation==0)
			world << "<FONT size = 3><B>The AI has won!</B></FONT>"
			world << "<B>The AI successfully maintained the quarantine - no players were in space or were off-station (as far as we can tell).</B>"
			log_game("AI won at Blob mode despite overall loss.")
		else
			world << "<FONT size = 3><B>The AI has lost!</B></FONT>"
			world << text("<B>The AI failed to maintain the quarantine - [] were in space and [] were off-station (as far as we can tell).</B>", numSpace, numOffStation)
			log_game("AI lost at Blob mode.")
	log_game("Blob mode was lost.")
	return 1

/datum/game_mode/blob/send_intercept(var/report = 1)
	var/intercepttext = ""
	var/interceptname = "Error"
	switch(report)
		if(1)
			interceptname = "Biohazard Alert"
			intercepttext += "<FONT size = 3><B>NanoTrasen Update</B>: Biohazard Alert.</FONT><HR>"
			intercepttext += "Reports indicate the probable transfer of a biohazardous agent onto [station_name()] during the last crew deployment cycle.<BR>"
			intercepttext += "Preliminary analysis of the organism classifies it as a level 5 biohazard. Its origin is unknown.<BR>"
			intercepttext += "NanoTrasen has issued a directive 7-10 for [station_name()]. The station is to be considered quarantined.<BR>"
			intercepttext += "Orders for all [station_name()] personnel follows:<BR>"
			intercepttext += " 1. Do not leave the quarantine area.<BR>"
			intercepttext += " 2. Locate any outbreaks of the organism on the station.<BR>"
			intercepttext += " 3. If found, use any neccesary means to contain the organism.<BR>"
			intercepttext += " 4. Avoid damage to the capital infrastructure of the station.<BR>"
			intercepttext += "<BR>Note in the event of a quarantine breach or uncontrolled spread of the biohazard, the directive 7-10 may be upgraded to a directive 7-12.<BR>"
			intercepttext += "Message ends."
		if(2)
			var/nukecode = "ERROR"
			for(var/obj/machinery/nuclearbomb/bomb in world)
				if(bomb && bomb.r_code)
					if(bomb.z == 1)
						nukecode = bomb.r_code
			interceptname = "Directive 7-12"
			intercepttext += "<FONT size = 3><B>NanoTrasen Update</B>: Biohazard Alert.</FONT><HR>"
			intercepttext += "Directive 7-12 has been issued for [station_name()].<BR>"
			intercepttext += "The biohazard has grown out of control and will soon reach critical mass.<BR>"
			intercepttext += "Your orders are as follows:<BR>"
			intercepttext += "1. Secure the Nuclear Authentication Disk.<BR>"
			intercepttext += "2. Detonate the Nuke located in the Station's Vault.<BR>"
			intercepttext += "Nuclear Authentication Code: [nukecode] <BR>"
			intercepttext += "Message ends."

	for(var/obj/machinery/computer/communications/comm in world)
		comm.messagetitle.Add(interceptname)
		comm.messagetext.Add(intercepttext)
		if(!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- [interceptname]"
			intercept.info = intercepttext
	return



