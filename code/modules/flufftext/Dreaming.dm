mob/living/carbon/proc/dream()
	dreaming = 1
	var/list/dreams = list(
		"an abandoned laboratory",
		"air",
		"an ally",
		"blinking lights",
		"blood",
		"a blue light",
		"a bottle",
		"the bridge",
		"the captain",
		"a catastrophe",
		"a crash",
		"a crewmember",
		"darkness",
		"deep space",
		"a doctor",
		"the engine",
		"a fall",
		"flames",
		"flying",
		"a familiar face",
		"freezing",
		"a gun",
		"happiness",
		"a hat",
		"healing",
		"ice",
		"an ID card",
		"light",
		"a loved one",
		"the medical bay",
		"melons",
		"a monkey",
		"Nanotrasen",
		"phoron",
		"a planet",
		"power",
		"pride",
		"respect",
		"riches",
		"a ruined station",
		"a scientist",
		"a security officer",
		"space",
		"a space ship",
		"a space station",
		"the sun",
		"The Syndicate",
		"a toolbox",
		"a traitor",
		"voices from all around",
		"warmth",
		"water"
		)
	spawn(0)
		for(var/i = rand(1,4),i > 0, i--)
			var/dream_image = pick(dreams)
			dreams -= dream_image
			src << "\blue <i>... [dream_image] ...</i>"
			sleep(rand(40,70))
			if(paralysis <= 0)
				dreaming = 0
				return 0
		dreaming = 0
		return 1

mob/living/carbon/proc/handle_dreams()
	if(prob(5) && !dreaming) dream()

mob/living/carbon/var/dreaming = 0
