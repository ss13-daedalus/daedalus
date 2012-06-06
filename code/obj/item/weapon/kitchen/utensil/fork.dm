
// FORK

/obj/item/weapon/kitchen/utensil/fork/attack(mob/living/M as mob, mob/living/carbon/user as mob)
	if(istype(M,/mob/living/carbon))
		if (bite)
			if(M == user)
				user.visible_message( \
					"\blue [user] eats a delicious forkful of [bite]!", \
					"\blue You eat a delicious forkful of [bite]!")
			else
				user.visible_message( \
					"\blue [user] feeds [M] a delicious forkful of [bite]!", \
					"\blue You feed [M] a delicious forkful of [bite]!")
			spawn(0)
				bite.reagents.reaction(M, INGEST)
				bite.reagents.trans_to(M)
				del(bite)
				src.icon_state = "fork"
		else if(user.zone_sel.selecting == "eyes")
			if((user.mutations & CLUMSY) && prob(50))
				M = user
			return eyestab(M, user)
		else
			user << "\red Your fork does not have any food on it."
	else
		user << "\red You can't seem to feed [M]."

/obj/item/weapon/kitchen/utensil/fork/afterattack(obj/item/weapon/reagent_containers/food/snacks/snack as obj, mob/living/carbon/user as mob)
	if(istype(snack))
		if(bite)
			user << "\red You already have [bite] on your fork."
		else
			bite = new snack.type(src)
			icon_state = "forkloaded"
			user.visible_message( \
				"[user] takes a piece of [bite] with their fork!", \
				"\blue You take a piece of [bite] with your fork!" \
			)
			if(bite.reagents && snack.reagents)	//transfer bit's worth of reagents to
				bite.reagents.clear_reagents()
				if(snack.reagents.total_volume)
					snack.reagents.reaction(src, TOUCH) // react "food" with fork
					spawn(0)
						if(snack.reagents.total_volume > snack.bitesize)
							snack.reagents.trans_to(bite, snack.bitesize)
						else
							snack.reagents.trans_to(bite, snack.reagents.total_volume)
						snack.bitecount++
						if(!snack.reagents.total_volume)
							// due to the trash code being hard-coded to place in hand, do magic trick
							// free active hand
							user.drop_item(src)

							// consumption fills active hand, drop it back down
							snack.On_Consume()
							var/obj/trash = user.get_active_hand()
							if(trash)
								user.drop_item(trash)
								trash.loc = get_turf(snack.loc) // move trash to snack's turf

							// put fork back in hand
							user.put_in_hand(src)
							user << "\red You grab the last bite of [snack]."
							del(snack)
	else
		return ..()


