/*--------
//CONTAINS
CRAYONS
--------*/
/obj/item/weapon/storage/crayon_box/New()
	..()
	new /obj/item/toy/crayon/red(src)
	new /obj/item/toy/crayon/orange(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/green(src)
	new /obj/item/toy/crayon/blue(src)
	new /obj/item/toy/crayon/purple(src)
	updateIcon()

/obj/item/weapon/storage/crayon_box/proc/updateIcon()
	overlays = list() //resets list
	overlays += image('icons/obj/crayons.dmi',"crayonbox")
	for(var/obj/item/toy/crayon/crayon in contents)
		overlays += image('icons/obj/crayons.dmi',crayon.colourName)

/obj/item/weapon/storage/crayon_box/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/toy/crayon))
		switch(W:colourName)
			if("mime")
				usr << "This crayon is too sad to be contained in this box."
				return
			if("rainbow")
				usr << "This crayon is too powerful to be contained in this box."
				return
	..()
	updateIcon()

/obj/item/weapon/storage/crayon_box/attack_hand(mob/user as mob)
	updateIcon()
	..()

/obj/item/weapon/storage/crayon_box/MouseDrop(obj/over_object as obj)

	if (ishuman(usr) || ismonkey(usr))
		var/mob/M = usr
		if (!( istype(over_object, /obj/screen) ))
			return ..()
		if ((!( M.restrained() ) && !( M.stat )))
			if (over_object.name == "r_hand")
				if (!( M.r_hand ))
					M.u_equip(src)
					M.r_hand = src
			else
				if (over_object.name == "l_hand")
					if (!( M.l_hand ))
						M.u_equip(src)
						M.l_hand = src
			M.update_clothing()
			src.add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if (usr.s_active)
				usr.s_active.close(usr)
			src.show_to(usr)
			return
	return
