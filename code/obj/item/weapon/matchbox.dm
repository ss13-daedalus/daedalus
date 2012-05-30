//////////////
//MATCHBOXES//
//////////////
/obj/item/weapon/matchbox
	name = "Matchbox"
	desc = "A small box of Almost But Not Quite Phoron Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	w_class = 1
	flags = ONBELT | TABLEPASS
	var/matchcount = 10
	w_class = 1.0


	attack_hand(mob/user as mob)
		if(user.r_hand == src || user.l_hand == src)
			if(src.matchcount <= 0)
				user << "\red You're out of matches. Shouldn't have wasted so many..."
				return
			else
				src.matchcount--
				var/obj/item/weapon/match/W = new /obj/item/weapon/match(user)
				user.put_in_hand(W)
		else
			return ..()
		if(src.matchcount <= 0)
			src.icon_state = "matchbox_empty"
		else if(src.matchcount <= 3)
			src.icon_state = "matchbox_almostempty"
		else if(src.matchcount <= 6)
			src.icon_state = "matchbox_almostfull"
		else
			src.icon_state = "matchbox"
		src.update_icon()
		return


	attackby(obj/item/weapon/match/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/match) && W.lit == 0)
			W.lit = 1
			W.icon_state = "match_lit"
			processing_objects.Add(W)
		W.update_icon()
		return


