// attach a wire to a power machine - leads from the turf you are standing on

/obj/machinery/power/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/weapon/cable_coil))

		var/obj/item/weapon/cable_coil/coil = W

		var/turf/T = user.loc

		if(T.intact || !istype(T, /turf/simulated/floor))
			return

		if(get_dist(src, user) > 1)
			return

		if(!directwired)		// only for attaching to directwired machines
			return

		var/dirn = get_dir(user, src)

		for(var/obj/structure/cable/LC in T)
			if( (LC.d1 == dirn && LC.d2 == 0 ) || ( LC.d2 == dirn && LC.d1 == 0) )
				user << "There's already a cable at that position."
				return

		var/obj/structure/cable/NC = new(T)

		NC.color_cable(coil.color)

		NC.d1 = 0
		NC.d2 = dirn
		NC.add_fingerprint()
		NC.updateicon()

		NC.merge_connected_networks(NC.d2)
		NC.merge_connected_networks_on_turf()
		if(netnum == 0 && NC.netnum == 0)
			var/datum/powernet/PN = new()

			PN.number = powernets.len + 1
			powernets += PN
			NC.netnum = PN.number
			netnum = PN.number
			PN.cables += NC
			PN.nodes += src
			powernet = PN
		else if(netnum == 0)
			netnum = NC.netnum
			var/datum/powernet/PN = powernets[netnum]
			powernet = PN
			PN.nodes += src
		NC.merge_connected_networks_on_turf()

		coil.use(1)
		if (NC.shock(user, 50))
			if (prob(50)) //fail
				new/obj/item/weapon/cable_coil(NC.loc, 1, NC.color)
				del(NC)
		return
	else
		..()
	return
