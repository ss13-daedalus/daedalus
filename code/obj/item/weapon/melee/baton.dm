// STUN BATON

// TODO: Rename to stun_baton

/obj/item/weapon/melee/baton/update_icon()
	if(src.status)
		icon_state = "stunbaton_active"
	else
		icon_state = "stunbaton"

/obj/item/weapon/melee/baton/attack_self(mob/user as mob)
	src.status = !( src.status )
	if ((usr.mutations & CLUMSY) && prob(50))
		usr << "\red You grab the stunbaton on the wrong side."
		usr.Paralyse(60)
		return
	if (src.status)
		user << "\blue The baton is now on."
		playsound(src.loc, "sparks", 75, 1, -1)
	else
		user << "\blue The baton is now off."
		playsound(src.loc, "sparks", 75, 1, -1)

	update_icon()
	src.add_fingerprint(user)
	return

/obj/item/weapon/melee/baton/attack(mob/M as mob, mob/user as mob)
	if ((usr.mutations & CLUMSY) && prob(50))
		usr << "\red You grab the stunbaton on the wrong side."
		usr.Weaken(30)
		return
	src.add_fingerprint(user)
	var/mob/living/carbon/human/H = M

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey]) (INTENT: [uppertext(user.a_intent)])</font>")

	log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")



	if(isrobot(M))
		..()
		return

	if (status == 0 || (status == 1 && charges ==0))
		if(user.a_intent == "hurt")
			if(!..()) return
			M.Weaken(5)
			for(var/mob/O in viewers(M))
				if (O.client)	O.show_message("\red <B>[M] has been beaten with the stun baton by [user]!</B>", 1)
			if(status == 1 && charges == 0)
				user << "\red Not enough charge"
			return
		else
			for(var/mob/O in viewers(M))
				if (O.client)	O.show_message("\red <B>[M] has been prodded with the stun baton by [user]! Luckily it was off.</B>", 1)
			if(status == 1 && charges == 0)
				user << "\red Not enough charge"
			return
	if((charges > 0 && status == 1) && (istype(H, /mob/living/carbon)))
		flick("baton_active", src)
		if (user.a_intent == "hurt")
			if(!..()) return
			playsound(src.loc, 'sound/weapons/Genhit.ogg', 50, 1, -1)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				charges--
			if (M.stuttering < 1 && (!(M.mutations & HULK) && M.canstun)  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stuttering = 1
			M.Stun(1)
			M.Weaken(1)
		else
			playsound(src.loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.charge -= 20
			else
				charges--
			if (M.stuttering < 10 && (!(M.mutations & HULK) && M.canstun)  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stuttering = 10
			M.Stun(10)
			M.Weaken(10)
			user.lastattacked = M
			M.lastattacker = user
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been stunned with the stun baton by [user]!</B>", 1, "\red You hear someone fall", 2)

/obj/item/weapon/melee/baton/emp_act(severity)
	switch(severity)
		if(1)
			src.charges = 0
		if(2)
			charges -= 5

