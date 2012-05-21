
/obj/item/weapon/smokebomb
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	var/state = null
	var/det_time = 20.0
	w_class = 2.0
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | ONBELT | USEDELAY
	var/datum/effect/effect/system/bad_smoke_spread/smoke

/obj/item/weapon/smokebomb/New()
	..()
	src.smoke = new /datum/effect/effect/system/bad_smoke_spread/
	src.smoke.attach(src)
	src.smoke.set_up(10, 0, usr.loc)

/obj/item/weapon/smokebomb/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/screwdriver))
		if (src.det_time == 60)
			src.det_time = 20
			user.show_message("\blue You set the smoke bomb for a 2 second detonation time.")
			src.desc = "It is set to detonate in 2 seconds."
		else
			src.det_time = 60
			user.show_message("\blue You set the smoke bomb for a 6 second detonation time.")
			src.desc = "It is set to detonate in 6 seconds."
		src.add_fingerprint(user)
	return

/obj/item/weapon/smokebomb/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (user.equipped() == src)
		if (!( src.state ))
			user << "\red You prime the smoke bomb! [det_time/10] seconds!"
			src.state = 1
			src.icon_state = "flashbang1"
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
			spawn( src.det_time )
				prime()
				return
		user.dir = get_dir(user, target)
		user.drop_item()
		var/t = (isturf(target) ? target : target.loc)
		walk_towards(src, t, 3)
		src.add_fingerprint(user)
	return

/obj/item/weapon/smokebomb/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/smokebomb/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/weapon/smokebomb/proc/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		src.smoke.start()
		sleep(10)
		src.smoke.start()
		sleep(10)
		src.smoke.start()
		sleep(10)
		src.smoke.start()

	for(var/obj/effect/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.health -= damage
		B.update()
	sleep(80)
	del(src)
	return

/obj/item/weapon/smokebomb/attack_self(mob/user as mob)
	if (!src.state)
		user << "\red You prime the smoke bomb! [det_time/10] seconds!"
		src.state = 1
		src.icon_state = "flashbang1"
		add_fingerprint(user)
		spawn( src.det_time )
			prime()
			return
	return

