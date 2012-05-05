/obj/item/weapon/virus_dish
	name = "Virus containment/growth dish"
	icon = 'items.dmi'
	icon_state = "implantcase-b"
	var/datum/disease2/disease/virus2 = null
	var/growth = 0
	var/info = 0
	var/analysed = 0

	reagents = list()

/obj/item/weapon/virus_dish/random
	name = "Virus Sample"

/obj/item/weapon/virus_dish/random/New()
	..()
	// add a random virus to this dish
	src.virus2 = new /datum/disease2/disease
	src.virus2.makerandom()
	growth = rand(5, 50)

/obj/item/weapon/virus_dish/attackby(var/obj/item/weapon/W as obj,var/mob/living/carbon/user as mob)
	if(istype(W,/obj/item/weapon/label) || istype(W,/obj/item/weapon/reagent_containers/syringe))
		return
	..()
	if(prob(50))
		user << "The dish shatters"
		if(virus2.infectionchance > 0)
			for(var/mob/living/carbon/target in view(null, src)) if(!target.virus2)
				if(airborne_can_reach(src.loc, target.loc))
					if(target.get_infection_chance())
						infect_virus2(target,src.virus2)
		del src

/obj/item/weapon/virus_dish/examine()
	usr << "This is a virus containment dish"
	if(src.info)
		usr << "It has the following information about its contents"
		usr << src.info
