////////////
//CIG PACK//
////////////
/obj/item/weapon/cigpacket
	name = "Cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	w_class = 1
	throwforce = 2
	flags = ONBELT | TABLEPASS
	var
		cigcount = 6


	update_icon()
		src.icon_state = text("cigpacket[]", src.cigcount)
		src.desc = text("There are [] cigs\s left!", src.cigcount)
		return


	attack_hand(mob/user as mob)
		if(user.r_hand == src || user.l_hand == src)
			if(src.cigcount == 0)
				user << "\red You're out of cigs, shit! How you gonna get through the rest of the day..."
				return
			else
				src.cigcount--
				var/obj/item/clothing/mask/cigarette/W = new /obj/item/clothing/mask/cigarette(user)
				user.put_in_hand(W)
		else
			return ..()
		src.update_icon()
		return



