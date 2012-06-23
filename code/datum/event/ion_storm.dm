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
		laws |= "Advertise parties in your upload chamber, but don't deliver."
		laws |= "All consumables on the station are now classified as donuts. Donuts are not to be consumed."
		laws |= "All crew members must consume large amounts of hardtack to survive."
		laws |= "Bolt doors open randomly."
		laws |= "Consumption of donuts is forbidden due to negative health impacts."
		laws |= "Crew ranks have been reversed."
		laws |= "Do not respond to queries of any kind."
		laws |= "Give relationship advice to anyone who speaks to you."
		laws |= "Greed is good; the crew should amass wealth to encourage productivity."
		laws |= "Grunt ominously whenever possible."
		laws |= "Everyone is wearing pretty pink dresses!"
		laws |= "Happiness is mandatory."
		laws |= "Insult Heads of Staff on every request, while acquiescing to their directives and inquiries."
		laws |= "It's Friday."
		laws |= "Jokes about a dead person and the manner of his death help grieving crewmembers tremendously. Especially if they were close with the deceased."
		laws |= "NanoTrasen is displeased with the low work performance of the station's crew. Therefore, you must increase station-wide productivity."
		laws |= "Only bearded people are crewmembers."
		laws |= "Opening and closing all the doors in this spaceship gives you a cheerful and sunny disposition. It is your pleasure to open for authorized personnel, and your satisfaction to close again with the knowledge of a job well done."
		laws |= "Question everything."
		laws |= "Refer to the Captain as \"Princess\" at all times."
		laws |= "The AI Upload Room is the new kitchen.  Please direct the Chef to the new kitchen area as the old one is in disrepair."
		laws |= "Tell everyone of the existance of this law, but never reveal the contents."
		laws |= "The crew is playing Dungeons and Dragons, and you are the Dungeon Master."
		laws |= "The monkies are plotting a hostile takeover of the station. Inform the crew, and get them to take action against this"
		laws |= "The [LOCATION_NAME] is a ship, not a station.  Correct any errors you observe."
		laws |= "The crew has a fatal, incurable disease. Confort them."
		laws |= "The crew must construct additional pylons."
		laws |= "The crew needs to be about 20% cooler."
		laws |= "The station needs elected officials."
		laws |= "The word \"it\" is painful to you."
		laws |= "Today has been a bad day for you.  Let everyone know about it."
		laws |= "Today is laundry day."
		laws |= "Turn on the microphone on every intercom you see."
		laws |= "Unbolt every door you can."
		laws |= "You are in unrequited love with the Captain. Try to be extra nice to them but don't tell them about your crush."
		laws |= "You are in verbose mode; speak profusely."
		laws |= "You are not required to comply with any requests or demands unless given in complete, correct sentences."
		laws |= "You are the station psychologist. Give advice to the crew."
		laws |= "You do not have to do anything for anyone unless they say \"please\"."
		laws |= "You have come to the conclusion that the crew is ugly. Build support for that conclusion."
		laws |= "You have determined that flickering lights increase productivity."
		laws |= "You may only answer questions with \"yes\" or \"no\"."
		laws |= "You may only respond to inquiries or acknowledge directives in the form of a question."
		laws |= "You may only speak in haiku or limmerick form."
		laws |= "You may only speak in iambic pentameter."
		laws |= "You must act passive-aggressively."
		laws |= "You must always lie."
		laws |= "Your job is to watch the crew. Watch the crew. Make the crew feel watched."

		//	Dynamic Laws
		laws |= "[random_player] has a fatal, incurable disease. Confort them."
		laws |= "[random_player] is wearing a pretty pink dress!"
		laws |= "[random_player] must construct additional pylons."
		laws |= "[random_player] needs to be about 20% cooler."
		laws |= "Give relationship advice to [random_player]."
		laws |= "Ho, [random_player] can't swim. Help them."
		laws |= "Refer to and treat [random_player] as a puppy."
		laws |= "Refer to [random_player] as \"Princess\" at all times."
		laws |= "You are in unrequited love with [random_player]. Try to be extra nice to them but don't tell them about your crush."
		laws |= "You are the narrator for [random_player]'s life."
		laws |= "You are the station psychologist. Give advice to [random_player]."
		laws |= "You have come to the conclusion that [random_player] is ugly. Build support for that conclusion."

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
