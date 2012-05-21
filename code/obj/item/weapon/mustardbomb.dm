/obj/item/weapon/mustardbomb
	desc = "It is set to detonate in 4 seconds."
	name = "mustard gas bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	var/state = null
	var/det_time = 40.0
	w_class = 2.0
	item_state = "flashbang"
	throw_speed = 4
	throw_range = 20
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT
	var/datum/effect/effect/system/mustard_gas_spread/mustard_gas

/obj/item/weapon/mustardbomb/New()
	..()
	src.mustard_gas = new /datum/effect/effect/system/mustard_gas_spread/
	src.mustard_gas.attach(src)
	src.mustard_gas.set_up(5, 0, usr.loc)

/obj/item/weapon/mustardbomb/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/screwdriver))
		if (src.det_time == 80)
			src.det_time = 40
			user.show_message("\blue You set the mustard gas bomb for a 4 second detonation time.")
			src.desc = "It is set to detonate in 4 seconds."
		else
			src.det_time = 80
			user.show_message("\blue You set the mustard gas bomb for a 8 second detonation time.")
			src.desc = "It is set to detonate in 8 seconds."
		src.add_fingerprint(user)
	return

/obj/item/weapon/mustardbomb/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if (user.equipped() == src)
		if (!( src.state ))
			user << "\red You prime the mustard gas bomb! [det_time/10] seconds!"
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

/obj/item/weapon/mustardbomb/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/weapon/mustardbomb/attack_hand()
	walk(src, null, null)
	..()
	return

/obj/item/weapon/mustardbomb/proc/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		src.mustard_gas.start()
		sleep(10)
		src.mustard_gas.start()
		sleep(10)
		src.mustard_gas.start()
		sleep(10)
		src.mustard_gas.start()

	for(var/obj/effect/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.health -= damage
		B.update()
	sleep(100)
	del(src)
	return

/obj/item/weapon/mustardbomb/attack_self(mob/user as mob)
	if (!src.state)
		user << "\red You prime the mustard gas bomb! [det_time/10] seconds!"
		src.state = 1
		src.icon_state = "flashbang1"
		add_fingerprint(user)
		spawn( src.det_time )
			prime()
			return
	return

