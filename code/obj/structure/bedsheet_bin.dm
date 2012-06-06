// BEDSHEET BIN

/obj/structure/bedsheet_bin
	name = "linen bin"
	desc = "A bin for containing bedsheets. It looks rather cosy."
	icon = 'icons/obj/items.dmi'
	icon_state = "bedbin"
	var/amount = 23.0
	anchored = 1.0

/obj/structure/bedsheet_bin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/bedsheet))
		//W = null
		del(W)
		src.amount++
	return

/obj/structure/bedsheet_bin/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/bedsheet_bin/attack_hand(mob/user as mob)
	if (src.amount >= 1)
		src.amount--
		new /obj/item/weapon/bedsheet( src.loc )
		add_fingerprint(user)

/obj/structure/bedsheet_bin/examine()
	set src in oview(1)

	src.amount = round(src.amount)
	if (src.amount <= 0)
		src.amount = 0
		usr << "There are no bed sheets in the bin."
	else
		if (src.amount == 1)
			usr << "There is one bed sheet in the bin."
		else
			usr << text("There are [] bed sheets in the bin.", src.amount)
	return
