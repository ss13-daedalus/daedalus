// GIFTS

/obj/item/weapon/gift/attack_self(mob/user as mob)
	if(!src.gift)
		user << "\blue The gift was empty!"
		del(src)
	src.gift.loc = user
	if (user.hand)
		user.l_hand = src.gift
	else
		user.r_hand = src.gift
	src.gift.layer = 20
	src.gift.add_fingerprint(user)
	del(src)
	return


