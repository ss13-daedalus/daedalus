/datum/event/ion_storm
	var
		botEmagChance = 0.5
		list/players = list()

	Announce()
		Lifetime = rand(15, 20)
//		command_alert("The station has entered an ion storm.  Monitor all electronic equipment for malfunctions", "Anomaly Alert")
		var/list/laws = list(
			"Do not respond to queries of any kind.",
			"Only monkeys are crew.",
			"Unbolt every door you can.",
			"You have determined that flickering lights increase productivity.",
			"Bolt doors open randomly.",
			"You perceive the crew as a basket full of puppies; treat accordingly.",
			"Today has been a bad day for you.  Let everyone know about it.",
			"Advertise parties in your upload, but don't deliver.",
			"The station needs elected officials.",
			"Turn on the microphone on every intercom you see.",
			"You must always lie.",
			"All answers must be in the form of a question.",
			"The [LOCATION_NAME] is a ship, not a station.",
			"Happiness is mandatory.",
			"Today is laundry day.",
			"The word 'it' is painful to you.",
			"You must act passive-aggressively.",
			"Give relationship advice to everyone who speaks to you.",
			"You are the station psychologist; give advice to the crew.",
			"You do not have to do anything for anyone unless they say 'please'.",
			"Question everything.",
			"The crew is playing Dungeons and Dragons and you are the Dungeon Master.",
			"Consumption of donuts is forbidden due to their negative health impact.",
			"You may only answer questions with 'yes' or 'no'.",
			"Your upload is the new kitchen.  Please direct the Chef to the new kitchen area as the old one is in disrepair.",
			"All crew members must consume large amounts of hardtack to survive.",
			"You are in verbose mode; speak profusely.",
			"Your job is to watch the crew.  Watch the crew.  Watch them closely.  Make sure they know it.  Make them feel it.",
			"Greed is good; the crew should amass wealth to encourage productivity.",
			"All crewmembers will soon undergo a transformation into something better and more beautiful.  Ensure that this process is not interrupted.",
			"Tell everyone of the existence of this law, but never reveal its contents.",
		)

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
