/////////
//ZIPPO//
/////////

/obj/item/weapon/lighter
	name = "cheap lighter"
	desc = "A cheap-as-free lighter."
	icon = 'icons/obj/items.dmi'
	icon_state = "lighter-g"
	item_state = "lighter-g"
	var/icon_on = "lighter-g-on"
	var/icon_off = "lighter-g"
	w_class = 1
	throwforce = 4
	flags = ONBELT | TABLEPASS | CONDUCT
	var/lit = 0

/obj/item/weapon/lighter/zippo
	name = "Zippo lighter"
	desc = "The zippo."
	icon_state = "zippo"
	item_state = "zippo"
	icon_on = "zippoon"
	icon_off = "zippo"

/obj/item/weapon/lighter/random
	New()
		var/color = pick("r","c","y","g")
		icon_on = "lighter-[color]-on"
		icon_off = "lighter-[color]"
		icon_state = icon_off

/obj/item/weapon/lighter

	attack_self(mob/user)
		if(user.r_hand == src || user.l_hand == src)
			if(!src.lit)
				src.lit = 1
				src.icon_state = icon_on
				src.item_state = icon_on
				if( istype(src,/obj/item/weapon/lighter/zippo) )
					for(var/mob/O in viewers(user, null))
						O.show_message(text("\red Without even breaking stride, [] flips open and lights the [] in one smooth movement.", user, src), 1)
				else
					if(prob(75))
						for(var/mob/O in viewers(user, null))
							O.show_message("\red After a few attempts, [user] manages to light the [src].", 1)
					else
						user << "\red <b>You burn yourself while lighting the lighter.</b>"
						user.adjustFireLoss(5)
						for(var/mob/O in viewers(user, null))
							O.show_message("\red After a few attempts, [user] manages to light the [src], they however burn their finger in the process.", 1)

				user.total_luminosity += 2
				processing_objects.Add(src)
			else
				src.lit = 0
				src.icon_state = icon_off
				src.item_state = icon_off
				if( istype(src,/obj/item/weapon/lighter/zippo) )
					for(var/mob/O in viewers(user, null))
						O.show_message(text("\red You hear a quiet click, as [] shuts off the [] without even looking at what they're doing. Wow.", user, src), 1)
				else
					for(var/mob/O in viewers(user, null))
						O.show_message("\red [user] quietly shuts off the [src].", 1)

				user.total_luminosity -= 2
				processing_objects.Remove(src)
		else
			return ..()
		return


	attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
		if(!istype(M, /mob))
			return

		if(istype(M.wear_mask,/obj/item/clothing/mask/cigarette) && user.zone_sel.selecting == "mouth" && src.lit)
			if(M == user)
				M.wear_mask:light("\red With a single flick of their wrist, [user] smoothly lights their [M.wear_mask.name] with their [src.name]. Damn they're cool.")
			else
				M.wear_mask:light("\red [user] whips the [src.name] out and holds it for [M]. Their arm is as steady as the unflickering flame they light the [M.wear_mask.name] with.")
		else
			..()


	process()
		var/turf/location = get_turf(src)
		if(location)
			location.hotspot_expose(700, 5)
		return


	pickup(mob/user)
		if(lit)
			src.sd_SetLuminosity(0)
			user.total_luminosity += 2
		return


	dropped(mob/user)
		if(lit)
			user.total_luminosity -= 2
			src.sd_SetLuminosity(2)
		return
