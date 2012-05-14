/obj/item/ashtray
	icon = 'icons/ashtray.dmi'
	var/
		max_butts 	= 0
		empty_desc 	= ""
		icon_empty 	= ""
		icon_half  	= ""
		icon_full  	= ""
		icon_broken	= ""

/obj/item/ashtray/New()
	..()
	src.pixel_y = rand(-5, 5)
	src.pixel_x = rand(-6, 6)
	return

/obj/item/ashtray/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (health < 1)
		return
	if (istype(W,/obj/item/clothing/mask/cigarette))
		if(user)
			if (contents.len >= max_butts)
				user << "This ashtray is full."
				return
			user.u_equip(W)
			W.loc = src
			if ((user.client && user.s_active != src))
				user.client.screen -= W
			var/obj/item/clothing/mask/cigarette/cig = W
			if (cig.lit == 1)
				src.visible_message("[user] crushes a [cig] in the [src], putting it out.")
				cig.put_out()
			else if (cig.lit == 0)
				user << "You place a [cig] in [src] without even smoking it. Why would you do that?"
			else if (cig.lit == -1)
				src.visible_message("[user] places a [cig] in the [src],.")
			user.update_clothing()
			add_fingerprint(user)
			if (contents.len == max_butts)
				icon_state = icon_full
				desc = empty_desc + " It's stuffed full."
			else if (contents.len > max_butts/2)
				icon_state = icon_half
				desc = empty_desc + " It's half-filled."
	else
		health = max(0,health - W.force)
		user << "You hit [src] with [W]."
		if (health < 1)
			die()
	return

/obj/item/ashtray/throw_impact(atom/hit_atom)
	if (health > 0)
		health = max(0,health - 3)
		if (health < 1)
			die()
			return
		if (contents.len)
			src.visible_message("\red [src] slams into [hit_atom] spilling its contents!")
		for (var/obj/item/clothing/mask/cigarette/O in contents)
			contents -= O
			O.loc = src.loc
		icon_state = icon_empty
	return ..()

/obj/item/ashtray/proc/die()
	src.visible_message("\red [src] shatters spilling its contents!")
	for (var/obj/item/clothing/mask/cigarette/O in contents)
		contents -= O
		O.loc = src.loc
	icon_state = icon_broken

/obj/item/ashtray/glass
	name = "glass ashtray"
	desc = "Glass ashtray. Looks fragile."
	icon_state = "ashtray_gl"
	icon_empty = "ashtray_gl"
	icon_half  = "ashtray_half_gl"
	icon_full  = "ashtray_full_gl"
	icon_broken  = "ashtray_bork_gl"
	max_butts = 12
	health = 12.0
	g_amt = 60
	empty_desc = "Glass ashtray. Looks fragile."
	throwforce = 6.0

	die()
		..()
		name = "shards of glass"
		desc = "Shards of glass with ash on them."
		playsound(src, "shatter", 30, 1)
		return
