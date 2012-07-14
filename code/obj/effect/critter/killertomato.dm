/obj/effect/critter/killertomato
	name = "killer tomato"
	desc = "Oh shit, you're really fucked now."
	icon_state = "killertomato"
	health = 15
	max_health = 15
	aggressive = 1
	defensive = 0
	wanderer = 1
	atkcarbon = 1
	atksilicon = 1
	firevuln = 2
	brutevuln = 2


	Harvest(var/obj/item/weapon/W, var/mob/living/user)
		if(..())
			var/success = 0
			if(istype(W, /obj/item/weapon/butch))
				new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
				success = 1
			if(istype(W, /obj/item/weapon/kitchenknife))
				new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
				new /obj/item/weapon/reagent_containers/food/snacks/tomatomeat(src)
				success = 1
			if(success)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red [user.name] cuts apart the [src.name]!", 1)
				del(src)
				return 1
			return 0


