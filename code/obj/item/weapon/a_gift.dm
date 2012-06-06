// TODO: Figure out just exactly what the hell a_gift is so that it can be named properly

/obj/item/weapon/a_gift/ex_act()
	del(src)
	return

/obj/item/weapon/a_gift/attack_self(mob/M as mob)
	switch(pick("flash", "t_gun", "l_gun", "shield", "sword", "axe"))
		if("flash")
			var/obj/item/device/flash/W = new /obj/item/device/flash( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("l_gun")
			var/obj/item/weapon/gun/energy/laser/W = new /obj/item/weapon/gun/energy/laser( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("t_gun")
			var/obj/item/weapon/gun/energy/taser/W = new /obj/item/weapon/gun/energy/taser( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("sword")
			var/obj/item/weapon/melee/energy/sword/W = new /obj/item/weapon/melee/energy/sword( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		if("axe")
			var/obj/item/weapon/melee/energy/axe/W = new /obj/item/weapon/melee/energy/axe( M )
			if (M.hand)
				M.l_hand = W
			else
				M.r_hand = W
			W.layer = 20
			W.add_fingerprint(M)
			//SN src = null
			del(src)
			return
		else
	return
