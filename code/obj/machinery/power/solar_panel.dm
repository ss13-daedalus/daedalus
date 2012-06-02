/obj/machinery/power/solar_panel
	name = "solar panel"
	desc = "A solar electrical generator."
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	anchored = 1
	density = 1
	directwired = 1
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0
	var
		health = 10
		id = 1
		obscured = 0
		sunfrac = 0
		adir = SOUTH
		ndir = SOUTH
		turn_angle = 0
		obj/machinery/power/solar_control/control = null
	proc
		healthcheck()
		updateicon()
		update_solar_exposure()
		broken()


	New()
		..()
		spawn(10)
			updateicon()
			update_solar_exposure()
			if(powernet)
				for(var/obj/machinery/power/solar_control/SC in powernet.nodes)
					if(SC.id == id)
						control = SC


	attackby(obj/item/weapon/W, mob/user)
		..()
		if (W)
			src.add_fingerprint(user)
			src.health -= W.force
			src.healthcheck()
			return


	blob_act()
		src.health--
		src.healthcheck()
		return


	healthcheck()
		if (src.health <= 0)
			if(!(stat & BROKEN))
				broken()
			else
				new /obj/item/weapon/shard(src.loc)
				new /obj/item/weapon/shard(src.loc)
				del(src)
				return
		return


	updateicon()
		overlays = null
		if(stat & BROKEN)
			overlays += image('icons/obj/power.dmi', icon_state = "solar_panel-b", layer = FLY_LAYER)
		else
			overlays += image('icons/obj/power.dmi', icon_state = "solar_panel", layer = FLY_LAYER)
			src.dir = angle2dir(adir)
		return


	update_solar_exposure()
		if(!sun)
			return
		if(obscured)
			sunfrac = 0
			return
		var/p_angle = abs((360+adir)%360 - (360+sun.angle)%360)
		if(p_angle > 90)			// if facing more than 90deg from sun, zero output
			sunfrac = 0
			return
		sunfrac = cos(p_angle) ** 2


	process()
		if(stat & BROKEN)	return
		if(!control)	return
		if(obscured)	return

		var/sgen = SOLAR_GEN_RATE * sunfrac
		add_avail(sgen)
		if(powernet && control)
			if(control in powernet.nodes) //this line right here...
				control.gen += sgen

		if(adir != ndir)
			spawn(10+rand(0,15))
				adir = (360+adir+dd_range(-10,10,ndir-adir))%360
				updateicon()
				update_solar_exposure()


	broken()
		stat |= BROKEN
		updateicon()
		return


	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				if(prob(15))
					new /obj/item/weapon/shard( src.loc )
				return
			if(2.0)
				if (prob(25))
					new /obj/item/weapon/shard( src.loc )
					del(src)
					return
				if (prob(50))
					broken()
			if(3.0)
				if (prob(25))
					broken()
		return


	blob_act()
		if(prob(75))
			broken()
			src.density = 0


/obj/machinery/power/solar_panel/fake/process()
	machines.Remove(src)
	return
