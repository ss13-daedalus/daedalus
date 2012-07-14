/obj/effect/critter/walkingmushroom
	name = "Walking Mushroom"
	desc = "A...huge...mushroom...with legs!?"
	icon_state = "walkingmushroom"
	health = 15
	max_health = 15
	aggressive = 0
	defensive = 0
	wanderer = 1
	atkcarbon = 0
	atksilicon = 0
	firevuln = 2
	brutevuln = 1


	Harvest(var/obj/item/weapon/W, var/mob/living/user)
		if(..())
			var/success = 0
			if(istype(W, /obj/item/weapon/butch))
				new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
				new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
				success = 1
			if(istype(W, /obj/item/weapon/kitchenknife))
				new /obj/item/weapon/reagent_containers/food/snacks/hugemushroomslice(src.loc)
				success = 1
			if(success)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red [user.name] cuts apart the [src.name]!", 1)
				del(src)
				return 1
			return 0

