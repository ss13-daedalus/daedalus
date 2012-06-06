
/obj/item/weapon/emp_grenade
	desc = "It is set to detonate in 5 seconds."
	name = "emp grenade"
	w_class = 2.0
	icon = 'icons/obj/device.dmi'
	icon_state = "emp"
	item_state = "emp"
	throw_speed = 4
	throw_range = 20
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	origin_tech = "materials=2;magnets=3"
	var
		active = 0
		det_time = 50
	proc
		prime()
		clown_check(var/mob/living/user)


	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if (istype(target, /obj/item/weapon/storage)) return ..() // Trying to put it in a full container
		if (istype(target, /obj/item/weapon/gun/grenadelauncher)) return ..()
		if((user.equipped() == src)&&(!active)&&(clown_check(user)))
			user << "\red You prime the emp grenade! [det_time/10] seconds!"
			src.active = 1
			src.icon_state = "empar"
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
			spawn( src.det_time )
				prime()
				return
			user.dir = get_dir(user, target)
			user.drop_item()
			var/t = (isturf(target) ? target : target.loc)
			walk_towards(src, t, 3)
		return


	attack_self(mob/user as mob)
		if(!active)
			if(clown_check(user))
				user << "\red You prime the EMP grenade! [det_time/10] seconds!"
				src.active = 1
				src.icon_state = "empar"
				add_fingerprint(user)
				spawn(src.det_time)
					prime()
					return
		return


	prime()
		playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
		var/turf/T = get_turf(src)
		if(T)
			T.hotspot_expose(700,125)
		if(empulse(src, 5, 7))
			del(src)
		return


	clown_check(var/mob/living/user)
		if((user.mutations & CLUMSY) && prob(50))
			user << "\red Huh? How does this thing work?!"
			src.active = 1
			src.icon_state = "empar"
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
			spawn( 5 )
				prime()
			return 0
		return 1
