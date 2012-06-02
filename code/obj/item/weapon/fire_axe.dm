
////////////FIREAXE!//////////////

/obj/item/weapon/fire_axe  // DEM AXES MAN, marker -Agouri
	icon_state = "fireaxe0"
	name = "fire axe"
	desc = "A tool for breaking down those obstructions that stop you from fighting that fire."  //Less ROBUST. --SkyMarshal
	force = 5
	w_class = 4.0
	flags = ONBACK
	twohanded = 1
	force_unwielded = 5
	force_wielded = 18


/obj/item/weapon/fire_axe/update_icon()  //Currently only here to fuck with the on-mob icons.
	icon_state = text("fireaxe[]",wielded)
	return

/obj/item/weapon/fire_axe/pickup(mob/user)
	wielded = 0
	name = "Fire Axe (Unwielded)"

/obj/item/weapon/fire_axe/attack_self(mob/user as mob)
	if( istype(user,/mob/living/carbon/monkey) )
		user << "\red It's too heavy for you to fully wield"
		return

//welp, all is good, now to see if he's trying do twohandedly wield it or unwield it

	..()

/obj/item/weapon/offhand/dropped(mob/user as mob)
	del(src)

/obj/item/weapon/fire_axe/afterattack(atom/A as mob|obj|turf|area, mob/user as mob)
	..()
	if(A && wielded && (istype(A,/obj/structure/window) || istype(A,/obj/structure/grille))) //destroys windows and grilles in one hit
		if(istype(A,/obj/structure/window)) //should just make a window.Break() proc but couldn't bother with it
			var/obj/structure/window/W = A

			new /obj/item/weapon/shard( W.loc )
			if(W.reinf) new /obj/item/stack/rods( W.loc)

			if (W.dir == SOUTHWEST)
				new /obj/item/weapon/shard( W.loc )
				if(W.reinf) new /obj/item/stack/rods( W.loc)
		del(A)
