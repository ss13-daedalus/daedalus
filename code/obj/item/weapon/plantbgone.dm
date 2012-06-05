
// Plant-B-Gone
/obj/item/weapon/plantbgone/New()
	var/datum/reagents/R = new/datum/reagents(100) // 100 units of solution
	reagents = R
	R.my_atom = src
	R.add_reagent("plantbgone", 100)

/obj/item/weapon/plantbgone/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/plantbgone/afterattack(atom/A as mob|obj, mob/user as mob)

	if (istype(A, /obj/item/weapon/storage/backpack ))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if (src.reagents.total_volume < 1)
		src.empty = 1
		user << "\blue Add more Plant-B-Gone mixture!"
		return

	else
		src.empty = 0

		if (istype(A, /obj/machinery/hydroponics)) // We are targeting hydrotray
			return

		else if (istype(A, /obj/effect/blob)) // blob damage in blob code
			return

		else
			var/obj/effect/decal/D = new/obj/effect/decal/(get_turf(src)) // Targeting elsewhere
			D.name = "chemicals"
			D.icon = 'icons/obj/chemical.dmi'
			D.icon_state = "weedpuff"
			D.create_reagents(5)
			src.reagents.trans_to(D, 5) // 5 units of solution used at a time => 20 uses
			playsound(src.loc, 'sound/effects/spray3.ogg', 50, 1, -6)

			spawn(0)
				for(var/i=0, i<3, i++) // Max range = 3 tiles
					step_towards(D,A) // Moves towards target as normally (not thru walls)
					D.reagents.reaction(get_turf(D))
					for(var/atom/T in get_turf(D))
						D.reagents.reaction(T)
					sleep(4)
				del(D)


			if((src.reagents.has_reagent("pacid")) || (src.reagents.has_reagent("lube"))) 	   				// Messages admins if someone sprays polyacid or space lube from a Plant-B-Gone bottle.
				message_admins("[key_name_admin(user)] fired Polyacid/Space lube from a PlantBGone bottle.")		// Polymorph
				log_game("[key_name(user)] fired Polyacid/Space lube from a PlantBGone bottle.")


			return

/obj/item/weapon/plantbgone/examine()
	set src in usr
	usr << text("\icon[] [] units of Plant-B-Gone left!", src, src.reagents.total_volume)
	..()
	return
