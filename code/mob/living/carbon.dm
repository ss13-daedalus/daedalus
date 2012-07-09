/mob/living/carbon/
	gender = MALE
	var/list/stomach_contents = list()

	var/brain_op_stage = 0.0
	var/eye_op_stage = 0.0
	var/appendix_op_stage = 0.0
	var/embryo_op_stage = 0.0
	var/face_op_stage = 0.0

	var/datum/disease2/disease/virus2 = null
	var/list/datum/disease2/disease/resistances2 = list()
	var/antibodies = 0

	var/dreaming = 0

mob
	var/list/disease_symptoms = 0 // a list of disease-incurred symptoms

/mob/living/carbon/proc/get_infection_chance()
	var/score = 0
	var/mob/living/carbon/M = src
	if(istype(M, /mob/living/carbon/human))
		if(M:gloves)
			score += 5
		if(istype(M:wear_suit, /obj/item/clothing/suit/space)) score += 10
		if(istype(M:wear_suit, /obj/item/clothing/suit/bio_suit)) score += 10
		if(istype(M:head, /obj/item/clothing/head/helmet/space)) score += 5
		if(istype(M:head, /obj/item/clothing/head/bio_hood)) score += 5
	if(M.wear_mask)
		score += 5
		if(istype(M:wear_mask, /obj/item/clothing/mask/surgical) && !M.internal)
			score += 10
		if(M.internal)
			score += 10

	if(score >= 30)
		return 0
	else if(score == 25 && prob(99))
		return 0
	else if(score == 20 && prob(95))
		return 0
	else if(score == 15 && prob(75))
		return 0
	else if(score == 10 && prob(55))
		return 0
	else if(score == 5 && prob(35))
		return 0

	return 1

mob/living/carbon/proc/handle_dreams()
	if(prob(5) && !dreaming) dream()

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

