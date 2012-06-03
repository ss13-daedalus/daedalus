// the power cable object

/obj/structure/cable/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable

	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1) hide(T.intact)


/obj/structure/cable/Del()		// called when a cable is deleted

	if(!defer_powernet_rebuild)	// set if network will be rebuilt manually

		if(netnum && powernets && powernets.len >= netnum)		// make sure cable & powernet data is valid
			var/datum/powernet/PN = powernets[netnum]
			PN.cut_cable(src)									// updated the powernets
	else
		if(Debug) diary << "Defered cable deletion at [x],[y]: #[netnum]"
	..()													// then go ahead and delete the cable

/obj/structure/cable/hide(var/i)

	if(level == 1 && istype(loc, /turf))
		invisibility = i ? 101 : 0
	updateicon()

/obj/structure/cable/proc/updateicon()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"


// returns the powernet this cable belongs to
/obj/structure/cable/proc/get_powernet()
	var/datum/powernet/PN			// find the powernet
	if(netnum && powernets && powernets.len >= netnum)
		PN = powernets[netnum]
	return PN

/obj/structure/cable/attack_hand(mob/user)
	if(ishuman(user))
		if(istype(user:gloves, /obj/item/clothing/gloves/space_ninja)&&user:gloves:candrain&&!user:gloves:draining)
			call(/obj/item/clothing/gloves/space_ninja/proc/drain)("WIRE",src,user:wear_suit)
	return

/obj/structure/cable/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if(T.intact)
		return

	if(istype(W, /obj/item/weapon/wire_cutters))

		if (shock(user, 50))
			return

		if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/weapon/cable_coil(T, 2, color)
		else
			new/obj/item/weapon/cable_coil(T, 1, color)

		for(var/mob/O in viewers(src, null))
			O.show_message("\red [user] cuts the cable.", 1)

		if(defer_powernet_rebuild)
			if(netnum && powernets && powernets.len >= netnum)
				var/datum/powernet/PN = powernets[netnum]
				PN.cut_cable(src)
		del(src)

		return	// not needed, but for clarity


	else if(istype(W, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/coil = W
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/device/multitool))

		var/datum/powernet/PN = get_powernet()		// find the powernet

		if(PN && (PN.avail > 0))		// is it powered?
			user << "\red [PN.avail]W in power network."

		else
			user << "\red The cable is not powered."

		shock(user, 5, 0.2)

	else
		if (W.flags & CONDUCT)
			shock(user, 50, 0.7)

	src.add_fingerprint(user)

// shock the user with probability prb

/obj/structure/cable/proc/shock(mob/user, prb, var/siemens_coeff = 1.0)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernets[src.netnum], src, siemens_coeff))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return 1
	else
		return 0

/obj/structure/cable/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if (prob(50))
				new/obj/item/weapon/cable_coil(src.loc, src.d1 ? 2 : 1, color)
				del(src)

		if(3.0)
			if (prob(25))
				new/obj/item/weapon/cable_coil(src.loc, src.d1 ? 2 : 1, color)
				del(src)
	return

/obj/structure/cable/proc/merge_connected_networks(var/direction)
	var/turf/TB
	if((d1 == direction || d2 == direction) != 1)
		return
	TB = get_step(src, direction)

	for(var/obj/structure/cable/TC in TB)

		if(!TC)
			continue

		if(src == TC)
			continue

		var/fdir = (!direction)? 0 : turn(direction, 180)

		if(TC.d1 == fdir || TC.d2 == fdir)

			if(!netnum)
				var/datum/powernet/PN = powernets[TC.netnum]
				netnum = TC.netnum
				PN = powernets[netnum]
				PN.cables += src
				continue

			if(TC.netnum != netnum)
				var/datum/powernet/PN = powernets[netnum]
				var/datum/powernet/TPN = powernets[TC.netnum]

				PN.merge_powernets(TPN)

/obj/structure/cable/proc/merge_connected_networks_on_turf()


	for(var/obj/structure/cable/C in loc)


		if(!C)
			continue

		if(C == src)
			continue
		if(netnum == 0)
			var/datum/powernet/PN = powernets[C.netnum]
			netnum = C.netnum
			PN.cables += src
			continue

		var/datum/powernet/PN = powernets[netnum]
		var/datum/powernet/TPN = powernets[C.netnum]

		PN.merge_powernets(TPN)

	for(var/obj/machinery/power/M in loc)

		if(!M)
			continue

		if(!M.netnum)
			var/datum/powernet/PN = powernets[netnum]
			PN.nodes += M
			M.netnum = netnum
			M.powernet = powernets[M.netnum]

		if(M.netnum < 0)
			continue

		var/datum/powernet/PN = powernets[netnum]
		var/datum/powernet/TPN = powernets[M.netnum]

		PN.merge_powernets(TPN)

	for(var/obj/machinery/power/apc/N in loc)
		if(!N)	continue

		var/obj/machinery/power/M
		M = N.terminal
		if(!M)	continue

		if(!M.netnum)
			if(!netnum)continue
			var/datum/powernet/PN = powernets[netnum]
			PN.nodes += M
			M.netnum = netnum
			M.powernet = powernets[M.netnum]
			continue

		var/datum/powernet/PN = powernets[netnum]
		var/datum/powernet/TPN = powernets[M.netnum]

		PN.merge_powernets(TPN)

obj/structure/cable/proc/color_cable(var/colorC)
	var/color_n = "red"
	if(colorC)
		color_n = colorC
	color = color_n
	switch(colorC)
		if("red")
			icon = 'icons/obj/power_cond_red.dmi'
		if("yellow")
			icon = 'icons/obj/power_cond_yellow.dmi'
		if("green")
			icon = 'icons/obj/power_cond_green.dmi'
		if("blue")
			icon = 'icons/obj/power_cond_blue.dmi'
