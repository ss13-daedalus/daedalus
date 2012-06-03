// The lighting system
//
// consists of light fixtures (/obj/machinery/light_fixture) and light tube/bulb items (/obj/item/weapon/lamp)


// the standard tube light fixture

/obj/machinery/light_fixture
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	var/base_state = "tube"		// base description and icon_state
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = 1
	layer = 5  					// They were appearing under mobs which is a little weird - Ostaf
	use_power = 2
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	var/on = 0					// 1 if on, 0 if off
	var/on_gs = 0
	var/brightness = 8			// luminosity when on, also used in power calculation
	var/status = LIGHT_OK		// LIGHT_OK, _EMPTY, _BURNED or _BROKEN

	var/light_type = /obj/item/weapon/lamp/tube		// the type of light item
	var/fitting = "tube"
	var/switchcount = 0			// count of number of times switched on/off
								// this is used to calc the probability the light burns out

	var/rigged = 0				// true if rigged to explode

// the smaller bulb light fixture

/obj/machinery/light_fixture/small
	icon_state = "bulb1"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 3
	desc = "A small lighting fixture."
	light_type = /obj/item/weapon/lamp/bulb

/obj/machinery/light_fixture/small/spot
	brightness = 5

/obj/machinery/light_fixture/spot
	name = "spotlight"
	fitting = "large tube"
	light_type = /obj/item/weapon/lamp/tube/large
	brightness = 15

// the desk lamp
/obj/machinery/light_fixture/lamp
	name = "desk lamp"
	icon_state = "lamp1"
	base_state = "lamp"
	fitting = "bulb"
	brightness = 7
	desc = "A desk lamp"
	light_type = /obj/item/weapon/lamp/bulb
	var/switchon = 0		// independent switching for lamps - not controlled by area lightswitch

// green-shaded desk lamp
/obj/machinery/light_fixture/lamp/green
	icon_state = "green1"
	base_state = "green"
	desc = "A green-shaded desk lamp"


// create a new lighting fixture
/obj/machinery/light_fixture/New()
	..()

	spawn(2)
		switch(fitting)
			if("tube")
				if(src.loc && src.loc.loc && isarea(src.loc.loc))
					var/area/A = src.loc.loc
					brightness = A.area_lights_luminosity
				else
					brightness = rand(6,9)
				if(prob(10))
					broken(1)
			if("bulb")
				brightness = 3
				if(prob(25))
					broken(1)
		spawn(1)
			update()

/obj/machinery/light_fixture/Del()
	var/area/A = get_area(src)
	if(A)
		on = 0
//		A.update_lights()
	..()


// update the icon_state and luminosity of the light depending on its state
/obj/machinery/light_fixture/proc/update()

	switch(status)		// set icon_states
		if(LIGHT_OK)
			icon_state = "[base_state][on]"
		if(LIGHT_EMPTY)
			icon_state = "[base_state]-empty"
			on = 0
		if(LIGHT_BURNED)
			icon_state = "[base_state]-burned"
			on = 0
		if(LIGHT_BROKEN)
			icon_state = "[base_state]-broken"
			on = 0
	if(!on)
		use_power = 1
	else
		use_power = 2
	var/oldlum = luminosity

	//luminosity = on * brightness
	sd_SetLuminosity(on * brightness)		// *DAL*

	// if the state changed, inc the switching counter
	if(oldlum != luminosity)
		switchcount++

		// now check to see if the bulb is burned out
		if(status == LIGHT_OK)
			if(on && rigged)
				explode()
			if( prob( min(60, switchcount*switchcount*0.01) ) )
				status = LIGHT_BURNED
				icon_state = "[base_state]-burned"
				on = 0
				sd_SetLuminosity(0)
	active_power_usage = (luminosity * 20)
	if(on != on_gs)
		on_gs = on
//		var/area/A = get_area(src)
//		if(A)
//			A.update_lights()


// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light_fixture/proc/seton(var/s)
	on = (s && status == LIGHT_OK)
	update()

// examine verb
/obj/machinery/light_fixture/examine()
	set src in oview(1)
	if(usr && !usr.stat)
		switch(status)
			if(LIGHT_OK)
				usr << "[desc] It is turned [on? "on" : "off"]."
			if(LIGHT_EMPTY)
				usr << "[desc] The [fitting] has been removed."
			if(LIGHT_BURNED)
				usr << "[desc] The [fitting] is burnt out."
			if(LIGHT_BROKEN)
				usr << "[desc] The [fitting] has been smashed."



// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light_fixture/attackby(obj/item/W, mob/user)

	// attempt to insert light
	if(istype(W, /obj/item/weapon/lamp))
		if(status != LIGHT_EMPTY)
			user << "There is a [fitting] already inserted."
			return
		else
			src.add_fingerprint(user)
			var/obj/item/weapon/lamp/L = W
			if(istype(L, light_type))
				status = L.status
				user << "You insert the [L.name]."
				switchcount = L.switchcount
				rigged = L.rigged
				brightness = L.brightness
				del(L)

				on = has_power()
				update()
				user.update_clothing()
				if(on && rigged)
					explode()
			else
				user << "This type of light requires a [fitting]."
				return

	// attempt to take light apart
	else if(istype(W, /obj/item/weapon/wire_cutters))
		if(status == LIGHT_EMPTY)
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			var/turf/T = get_turf(user)
			user.visible_message("[user] cuts the light's wiring.", "You start to cut the light's wiring.")
			sleep(40)
			if(get_turf(user) == T)
				usr << "\blue You cut the light's wiring."
				var/obj/structure/light_frame/F = new(loc)
				F.anchored = 1
				F.name = "Secured Light Fixture Frame"
				F.dir = dir
				F.light_type = type
				F.icon_state = icon_state
				del(src)
		else
			user << "\blue You need to remove the [fitting] first!"

		// attempt to break the light
		//If xenos decide they want to smash a light bulb with a toolbox, who am I to stop them? /N

	else if(status != LIGHT_BROKEN && status != LIGHT_EMPTY)


		if(prob(1+W.force * 5))

			user << "You hit the light, and it smashes!"
			for(var/mob/M in viewers(src))
				if(M == user)
					continue
				M.show_message("[user.name] smashed the light!", 3, "You hear a tinkle of breaking glass", 2)
			if(on && (W.flags & CONDUCT))
				//if(!user.mutations & COLD_RESISTANCE)
				if (prob(12))
					electrocute_mob(user, get_area(src), src, 0.3)
			broken()

		else
			user << "You hit the light!"

	// attempt to stick weapon into light socket
	else if(status == LIGHT_EMPTY)
		user << "You stick \the [W] into the light socket!"
		if(has_power() && (W.flags & CONDUCT))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			//if(!user.mutations & COLD_RESISTANCE)
			if (prob(75))
				electrocute_mob(user, get_area(src), src, rand(0.7,1.0))


// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light_fixture/proc/has_power()
	var/area/A = src.loc.loc
	return A.master.lightswitch && A.master.power_light


// ai attack - do nothing

/obj/machinery/light_fixture/attack_ai(mob/user)
	return

// Aliens smash the bulb but do not get electrocuted./N
/obj/machinery/light_fixture/attack_alien(mob/living/carbon/alien/humanoid/user)//So larva don't go breaking light bulbs.
	if(status == LIGHT_EMPTY||status == LIGHT_BROKEN)
		user << "\green That object is useless to you."
		return
	else if (status == LIGHT_OK||status == LIGHT_BURNED)
		for(var/mob/M in viewers(src))
			M.show_message("\red [user.name] smashed the light!", 3, "You hear a tinkle of breaking glass", 2)
		broken()
	return
// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light_fixture/attack_hand(mob/user)

	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		user << "There is no [fitting] in this light."
		return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))

			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves

				prot = (G.heat_transfer_coefficient < 0.5)	// *** TODO: better handling of glove heat protection
		else
			prot = 1

		if(prot > 0 || (user.mutations & COLD_RESISTANCE))
			user << "You remove the light [fitting]"
		else
			user << "You try to remove the light [fitting], but you burn your hand on it!"

			var/datum/organ/external/affecting = H.get_organ("[user.hand ? "l" : "r" ]_arm")

			affecting.take_damage( 0, 5 )		// 5 burn damage

			H.updatehealth()
			H.UpdateDamageIcon()
			return				// if burned, don't remove the light

	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/weapon/lamp/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness = src.brightness
	L.loc = usr
	L.layer = 20
	if(user.hand)
		user.l_hand = L
	else
		user.r_hand = L

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0


	L.update()
	L.add_fingerprint(user)

	status = LIGHT_EMPTY
	update()
	user.update_clothing()

// break the light and make sparks if was on

/obj/machinery/light_fixture/proc/broken(var/skip_sound_and_sparks = 0)
	if(status == LIGHT_EMPTY)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		if(on)
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
	status = LIGHT_BROKEN
	update()

// explosion effect
// destroy the whole light fixture or just shatter it

/obj/machinery/light_fixture/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(75))
				broken()
		if(3.0)
			if (prob(50))
				broken()
	return

//blob effect

/obj/machinery/light_fixture/blob_act()
	if(prob(75))
		broken()


// timed process
// use power

/obj/machinery/light_fixture/process()
	return
//	if(on)
//		use_power(luminosity * LIGHTING_POWER_FACTOR, LIGHT)

// called when area power state changes
/obj/machinery/light_fixture/power_change()
	spawn(10)
		var/area/A = src.loc.loc
		A = A.master
		seton(A.lightswitch && A.power_light)

// called when on fire

/obj/machinery/light_fixture/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		broken()

// explode the light

/obj/machinery/light_fixture/proc/explode()
	var/turf/T = get_turf(src.loc)
	spawn(0)
		broken()	// break it first to give a warning
		sleep(2)
		explosion(T, 0, 1, 2, 2)
		sleep(1)
		del(src)




// special handling for desk lamps


// if attack with hand, only "grab" attacks are an attempt to remove bulb
// otherwise, switch the lamp on/off

/obj/machinery/light_fixture/lamp/attack_hand(mob/user)

	if(user.a_intent == "grab")
		..()	// do standard hand attack
	else
		switchon = !switchon
		user << "You switch [switchon ? "on" : "off"] the [name]."
		seton(switchon && powered(LIGHT))


// called when area power state changes
// override since lamp does not use area lightswitch

/obj/machinery/light_fixture/lamp/power_change()
	spawn(rand(0,15))
		var/area/A = src.loc.loc
		A = A.master
		seton(switchon && A.power_light)

// returns whether this lamp has power
// true if area has power and lamp switch is on

/obj/machinery/light_fixture/lamp/has_power()
	var/area/A = src.loc.loc
	return switchon && A.master.power_light
