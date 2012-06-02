// So-called 'Classic Baton'

// TODO: Rename to billy_club

/obj/item/weapon/melee/classic_baton/attack(mob/M as mob, mob/living/user as mob)
	if ((user.mutations & CLUMSY) && prob(50))
		user << "\red You club yourself over the head."
		user.Weaken(3 * force)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, "head")
		else
			user.take_organ_damage(2*force)
		return
	src.add_fingerprint(user)

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been attacked with [src.name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to attack [M.name] ([M.ckey])</font>")

	log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'>[user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")


	if (user.a_intent == "hurt")
		if(!..()) return
		playsound(src.loc, "swing_hit", 50, 1, -1)
		if (M.stuttering < 8 && (!(M.mutations & HULK))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
			M.stuttering = 8
		M.Stun(8)
		M.Weaken(8)
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been beaten with the police baton by [user]!</B>", 1, "\red You hear someone fall", 2)
	else
		playsound(src.loc, 'sound/weapons/Genhit.ogg', 50, 1, -1)
		M.Stun(5)
		M.Weaken(5)
		for(var/mob/O in viewers(M))
			if (O.client)	O.show_message("\red <B>[M] has been stunned with the police baton by [user]!</B>", 1, "\red You hear someone fall", 2)
