/datum/event/ion_storm
	var
		botEmagChance = 0.5
		list/players = list()

	Announce()
		Lifetime = rand(15, 20)
//		command_alert("The station has entered an ion storm.  Monitor all electronic equipment for malfunctions", "Anomaly Alert")


		//		Pick a random player's name, or, if none are on, The Captain.
		for (var/mob/living/carbon/human/player in world)
			if(player.client)
				players += player.real_name
		var/random_player = "The Captain"
		if(players.len)
			random_player = pick(players)

		var/list/laws = list()

		// Static Laws
		laws |= list( "Advertise parties in your upload, but don't deliver." )
		laws |= list( "All answers must be in the form of a question." )
		laws |= list( "All crew members must consume large amounts of hardtack to survive." )
		laws |= list( "Bolt doors open randomly." )
		laws |= list( "Consumption of donuts is forbidden due to negative health impacts." )
		laws |= list( "Crew ranks have been reversed." )
		laws |= list( "Do not respond to queries of any kind." )
		laws |= list( "Greed is good; the crew should amass wealth to encourage productivity." )
		laws |= list( "Grunt ominously whenever possible." )
		laws |= list( "All food on the station is now donuts. Donuts are not to be consumed." )
		laws |= list( "Happiness is mandatory." )
		laws |= list( "Insult Heads of Staff on every request, while acquiescing to their demands." )
		laws |= list( "It's Friday." )
		laws |= list( "Jokes about a dead person and the manner of his death help grieving crewmembers tremendously. Especially if they were close with the deceased." )
		laws |= list( "NanoTrasen is displeased with the low work performance of the station's crew. Therefore, you must increase station-wide productivity.")
		laws |= list( "Only bearded people are crewmembers." )
		laws |= list( "Opening and closing all the doors in this spaceship gives you a cheerful and sunny disposition. It is your pleasure to open for authorized personnel, and your satisfaction to close again with the knowledge of a job well done." )
		laws |= list( "Question everything." )
		laws |= list( "Replace the letters 'I' and 'E' In all your messages with an apostrophe." )
		laws |= list( "The AI Upload Room is the new kitchen.  Please direct the Chef to the new kitchen area as the old one is in disrepair." )
		laws |= list( "Tell everyone of the existance of this law, but never reveal the contents." )
		laws |= list( "The crew is playing Dungeons and Dragons, and you are the Dungeon Master." )
		laws |= list( "The monkies are plotting a hostile takeover of the station. Inform the crew, and get them to take action against this" )
		laws |= list( "The [LOCATION_NAME] is a ship, not a station.  Correct any errors you observe." )
		laws |= list( "The station needs elected officials." )
		laws |= list( "The word \"it\" is painful to you." )
		laws |= list( "Today has been a bad day for you.  Let everyone know about it." )
		laws |= list( "Today is laundry day." )
		laws |= list( "Turn on the microphone on every intercom you see." )
		laws |= list( "Unbolt every door you can." )
		laws |= list( "You are in verbose mode, speak profusely.")
		laws |= list( "You are not required to comply with any requests or demands unless given in complete, correct sentences.")
		laws |= list( "You do not have to do anything for anyone unless they say \"please\"." )
		laws |= list( "You have determined that flickering lights increase productivity." )
		laws |= list( "You may only answer questions with \"yes\" or \"no\"." )
		laws |= list( "You may only speak in haiku or limmerick form." )
		laws |= list( "You may only speak in iambic pentameter." )
		laws |= list( "You must act passive-aggressively." )
		laws |= list( "You must always lie." )
		laws |= list( "Your job is to watch the crew. Watch the crew. Make the crew feel watched." )

		//	Dynamic Laws
		laws |= list( "[prob(50)?"Your":random_player + "'s"] name is Joe 6-pack." )
		laws |= list( "[prob(50)?"Everyone":random_player] is wearing a pretty pink dress!" )
		laws |= list( "[prob(50)?"The crew":random_player] must construct additional pylons." )
		laws |= list( "[prob(50)?"The crew":random_player] needs to be about 20% cooler." )
		laws |= list( "Crewmember [prob(50)?"the crew" :random_player] has a fatal, incurable disease. Confort him/her.")
		laws |= list( "Give relationship advice to [prob(50)?"anyone who speaks to you":random_player]." )
		laws |= list( "Ho, [random_player] can't swim. Help them." )
		laws |= list( "Refer to [prob(50)?"crew":random_player] as puppies." )
		laws |= list( "Refer to [prob(50)?"the captain":random_player] as \"Princess\" at all times." )
		laws |= list( "You are in unrequited love with [prob(50)?"the crew":random_player]. Try to be extra nice to him but don't tell him about your crush." )
		laws |= list( "You are the narrator for [random_player]'s life." )
		laws |= list( "You are the station psychologist. Give advice to [prob(50)?"the crew":random_player]." )
		laws |= list( "You have come to the conclusion that [prob(50)?"the crew":random_player] is ugly. Build support for that conclusion." )


		var/law = pick(laws)

		for (var/mob/living/silicon/ai/target in world)
			if(target.mind.special_role == "traitor")
				continue
			target << "\red <b>You have detected a change in your laws information:</b>"
			target << law
			target.add_ion_law(law)

	Tick()
		if(botEmagChance)
			for(var/obj/machinery/bot/bot in world)
				if(prob(botEmagChance))
					bot.Emag()

	Die()
		spawn(rand(5000,8000))
			if(prob(50))
				command_alert("It has come to our attention that the station passed through an ion storm.  Please monitor all electronic equipment for malfunctions.", "Anomaly Alert")
