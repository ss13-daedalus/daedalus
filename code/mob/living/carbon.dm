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

mob/living/carbon/var
	image/halimage
	image/halbody
	obj/halitem
	hal_screwyhud = 0 //1 - critical, 2 - dead, 3 - oxygen indicator, 4 - toxin indicator
	handling_hal = 0
	hal_crit = 0

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

mob/living/carbon/proc/handle_hallucinations()
	if(handling_hal) return
	handling_hal = 1
	while(hallucination > 20)
		sleep(rand(200,500)/(hallucination/25))
		var/halpick = rand(1,100)
		switch(halpick)
			if(0 to 15)
				//Screwy HUD
				//src << "Screwy HUD"
				hal_screwyhud = pick(1,2,3,3,4,4)
				spawn(rand(100,250))
					hal_screwyhud = 0
			if(16 to 25)
				//Strange items
				//src << "Traitor Items"
				if(!halitem)
					halitem = new
					var/list/slots_free = list("1,1","3,1")
					if(l_hand) slots_free -= "1,1"
					if(r_hand) slots_free -= "3,1"
					if(istype(src,/mob/living/carbon/human))
						var/mob/living/carbon/human/H = src
						if(!H.belt) slots_free += "3,0"
						if(!H.l_store) slots_free += "4,0"
						if(!H.r_store) slots_free += "5,0"
					if(slots_free.len)
						halitem.screen_loc = pick(slots_free)
						halitem.layer = 50
						switch(rand(1,6))
							if(1) //revolver
								halitem.icon = 'icons/obj/gun.dmi'
								halitem.icon_state = "revolver"
								halitem.name = "Revolver"
							if(2) //c4
								halitem.icon = 'icons/obj/syndieweapons.dmi'
								halitem.icon_state = "c4small_0"
								halitem.name = "Mysterious Package"
								if(prob(25))
									halitem.icon_state = "c4small_1"
							if(3) //sword
								halitem.icon = 'icons/obj/weapons.dmi'
								halitem.icon_state = "sword1"
								halitem.name = "Sword"
							if(4) //stun baton
								halitem.icon = 'icons/obj/weapons.dmi'
								halitem.icon_state = "stunbaton"
								halitem.name = "Stun Baton"
							if(5) //emag
								halitem.icon = 'icons/obj/card.dmi'
								halitem.icon_state = "emag"
								halitem.name = "Cryptographic Sequencer"
							if(6) //flashbang
								halitem.icon = 'icons/obj/grenade.dmi'
								halitem.icon_state = "flashbang1"
								halitem.name = "Flashbang"
						if(client) client.screen += halitem
						spawn(rand(100,250))
							del halitem
			if(26 to 40)
				//Flashes of danger
				//src << "Danger Flash"
				if(!halimage)
					var/list/possible_points = list()
					for(var/turf/simulated/floor/F in view(src,world.view))
						possible_points += F
					if(possible_points.len)
						var/turf/simulated/floor/target = pick(possible_points)
						switch(rand(1,3))
							if(1)
								//src << "Space"
								halimage = image('icons/turf/space.dmi',target,"[rand(1,25)]",TURF_LAYER)
							if(2)
								//src << "Fire"
								halimage = image('icons/effects/fire.dmi',target,"1",TURF_LAYER)
							if(3)
								//src << "C4"
								halimage = image('icons/obj/syndieweapons.dmi',target,"c4small_1",OBJ_LAYER+0.01)
						if(client) client.images += halimage
						spawn(rand(10,50)) //Only seen for a brief moment.
							if(client) client.images -= halimage
							halimage = null
			if(41 to 65)
				//Strange audio
				//src << "Strange Audio"
				switch(rand(1,12))
					if(1) src << 'sound/machines/airlock.ogg'
					if(2)
						if(prob(50))src << 'sound/effects/Explosion1.ogg'
						else src << 'sound/effects/Explosion2.ogg'
					if(3) src << 'sound/effects/explosionfar.ogg'
					if(4) src << 'sound/effects/Glassbr1.ogg'
					if(5) src << 'sound/effects/Glassbr2.ogg'
					if(6) src << 'sound/effects/Glassbr3.ogg'
					if(7) src << 'sound/machines/twobeep.ogg'
					if(8) src << 'sound/machines/windowdoor.ogg'
					if(9)
						//To make it more realistic, I added two gunshots (enough to kill)
						src << 'sound/weapons/Gunshot.ogg'
						spawn(rand(10,30))
							src << 'sound/weapons/Gunshot.ogg'
					if(10) src << 'sound/weapons/smash.ogg'
					if(11)
						//Same as above, but with tasers.
						src << 'sound/weapons/Taser.ogg'
						spawn(rand(10,30))
							src << 'sound/weapons/Taser.ogg'
				//Rare audio
					if(12)
//These sounds are (mostly) taken from Hidden: Source
						var/list/creepyasssounds = list(
							'sound/effects/ghost.ogg',
							'sound/effects/ghost2.ogg',
							'sound/effects/Heart Beat.ogg',
							'sound/effects/screech.ogg',
							'sound/hallucinations/behind_you1.ogg',
							'sound/hallucinations/behind_you2.ogg',
							'sound/hallucinations/far_noise.ogg',
							'sound/hallucinations/growl1.ogg',
							'sound/hallucinations/growl2.ogg',
							'sound/hallucinations/growl3.ogg',
							'sound/hallucinations/im_here1.ogg',
							'sound/hallucinations/im_here2.ogg',
							'sound/hallucinations/i_see_you1.ogg',
							'sound/hallucinations/i_see_you2.ogg',
							'sound/hallucinations/look_up1.ogg',
							'sound/hallucinations/look_up2.ogg',
							'sound/hallucinations/over_here1.ogg',
							'sound/hallucinations/over_here2.ogg',
							'sound/hallucinations/over_here3.ogg',
							'sound/hallucinations/turn_around1.ogg',
							'sound/hallucinations/turn_around2.ogg',
							'sound/hallucinations/veryfar_noise.ogg',
							'sound/hallucinations/wail.ogg'
						)
						src << pick(creepyasssounds)
			if(66 to 70)
				//Flashes of danger
				//src << "Danger Flash"
				if(!halbody)
					var/list/possible_points = list()
					for(var/turf/simulated/floor/F in view(src,world.view))
						possible_points += F
					if(possible_points.len)
						var/turf/simulated/floor/target = pick(possible_points)
						switch(rand(1,4))
							if(1)
								halbody = image('icons/mob/human.dmi',target,"husk_l",TURF_LAYER)
							if(2,3)
								halbody = image('icons/mob/human.dmi',target,"husk_s",TURF_LAYER)
							if(4)
								halbody = image('icons/mob/alien.dmi',target,"alienother",TURF_LAYER)
							if(5)
								halbody = image('icons/mob/xcomalien.dmi',target,"chryssalid",TURF_LAYER)

						if(client) client.images += halbody
						spawn(rand(50,80)) //Only seen for a brief moment.
							if(client) client.images -= halbody
							halbody = null
			if(71 to 72)
				//Fake death
				src.sleeping_willingly = 1
				src.sleeping = 1
				hal_crit = 1
				hal_screwyhud = 1
				spawn(rand(50,100))
					src.sleeping_willingly = 0
					src.sleeping = 0
					hal_crit = 0
					hal_screwyhud = 0
	handling_hal = 0

