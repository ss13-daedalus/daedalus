// WRAPPING PAPER

/obj/item/weapon/wrapping_paper/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (!( locate(/obj/structure/table, src.loc) ))
		user << "\blue You MUST put the paper on a table!"
	if (W.w_class < 4)
		if ((istype(user.l_hand, /obj/item/weapon/wire_cutters) || istype(user.r_hand, /obj/item/weapon/wire_cutters)))
			var/a_used = 2 ** (src.w_class - 1)
			if (src.amount < a_used)
				user << "\blue You need more paper!"
				return
			else
				src.amount -= a_used
				user.drop_item()
				var/obj/item/weapon/gift/G = new /obj/item/weapon/gift( src.loc )
				G.size = W.w_class
				G.w_class = G.size + 1
				G.icon_state = text("gift[]", G.size)
				G.gift = W
				W.loc = G
				G.add_fingerprint(user)
				W.add_fingerprint(user)
				src.add_fingerprint(user)
			if (src.amount <= 0)
				new /obj/item/weapon/c_tube( src.loc )
				//SN src = null
				del(src)
				return
		else
			user << "\blue You need scissors!"
	else
		user << "\blue The object is FAR too large!"
	return


/obj/item/weapon/wrapping_paper/examine()
	set src in oview(1)

	..()
	usr << text("There is about [] square units of paper left!", src.amount)
	return

/obj/item/weapon/wrapping_paper/attack(mob/target as mob, mob/user as mob)
	if (!istype(target, /mob/living/carbon/human)) return
	if (istype(target:wear_suit, /obj/item/clothing/suit/straight_jacket) || target:stat)
		if (src.amount > 2)
			var/obj/effect/spresent/present = new /obj/effect/spresent (target:loc)
			src.amount -= 2

			if (target:client)
				target:client:perspective = EYE_PERSPECTIVE
				target:client:eye = present

			target:loc = present
			target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been wrapped with [src.name]  by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to wrap [target.name] ([target.ckey])</font>")
			log_admin("ATTACK: [user] ([user.ckey]) wrapped up [target] ([target.ckey]) with [src].")
			message_admins("ATTACK: [user] ([user.ckey]) wrapped up [target] ([target.ckey]) with [src].")
			log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to wrap [target.name] ([target.ckey])</font>")

		else
			user << "/blue You need more paper."
	else
		user << "Theyre moving around too much. a Straitjacket would help."
