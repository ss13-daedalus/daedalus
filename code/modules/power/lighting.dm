// the light item
// can be tube or bulb subtypes
// will fit into empty /obj/machinery/light_fixture of the corresponding type

/obj/item/weapon/lamp
	icon = 'icons/obj/lighting.dmi'
	flags = FPRINT | TABLEPASS
	force = 2
	throwforce = 5
	w_class = 1
	var/status = 0		// LIGHT_OK, LIGHT_BURNED or LIGHT_BROKEN
	var/base_state
	var/switchcount = 0	// number of times switched
	m_amt = 60
	var/rigged = 0		// true if rigged to explode
	var/brightness = 2 //how much light it gives off
	var/repair_state = 0

/obj/item/weapon/lamp/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_state = "ltube"
	item_state = "c_tube"
	g_amt = 200
	brightness = 8

	large
		w_class = 2
		name = "large light tube"
		brightness = 15

/obj/item/weapon/lamp/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_state = "lbulb"
	item_state = "contvapour"
	g_amt = 100
	brightness = 5

// update the icon state and description of the light
/obj/item/weapon/lamp
	proc/update()
		switch(status)
			if(LIGHT_OK)
				icon_state = base_state
				desc = "A replacement [name]."
			if(LIGHT_BURNED)
				icon_state = "[base_state]-burned"
				desc = "A burnt-out [name]."
				if(repair_state == 1)
					desc += " It has some wires hanging out."
			if(LIGHT_BROKEN)
				icon_state = "[base_state]-broken"
				desc = "A broken [name]."
				if(repair_state == 1)
					desc += " It has some wires hanging out."
				else if(repair_state == 2)
					desc += " It has had new wires put in."


/obj/item/weapon/lamp/New()
	..()
	switch(name)
		if("light tube")
			brightness = rand(6,9)
		if("light bulb")
			brightness = rand(4,6)
	update()


// attack bulb/tube with object
// if a syringe, can inject phoron to make it explode
// also repairing them with wire and screwdriver
// and glass if it's broken
/obj/item/weapon/lamp/attackby(var/obj/item/I, var/mob/user)

	if(istype(I, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = I

		user << "You inject the solution into the [src]."

		if(S.reagents.has_reagent("phoron", 5))

			log_attack("<font color='red'>[user.name] ([user.ckey]) injected a light with phoron.</font>")
			log_admin("ATTACK: [user] ([user.ckey]) injected a light with phoron.")
			message_admins("ATTACK: [user] ([user.ckey]) injected a light with phoron.")

			rigged = 1

		S.reagents.clear_reagents()
		return
	if(status != 0)
		if(istype(I, /obj/item/weapon/cable_coil) && repair_state == 0)
			user << "You put some new wiring into the [src]."
			I:use(1)
			repair_state = 1
			update()
			return
		if(istype(I, /obj/item/weapon/screwdriver) && repair_state == 1)
			user << "You attach the new wiring."
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			if(status == LIGHT_BURNED)
				repair_state = 0
				status = LIGHT_OK
			else
				repair_state = 2
			update()
			return
		if(istype(I, /obj/item/stack/sheet/glass) && status == LIGHT_BROKEN)
			user << "You repair the glass of the [src]." //this is worded terribly
			I:use(1)
			force = 2 //because breaking it changes the force, this changes it back
			if(repair_state == 2)
				repair_state = 0
				status = LIGHT_OK
			else
				status = LIGHT_BURNED
			update()
			return
	..()
	return

// called after an attack with a light item
// shatter light, unless it was an attempt to put it in a light socket
// now only shatter if the intent was harm

/obj/item/weapon/lamp/afterattack(atom/target, mob/user)
	if(istype(target, /obj/machinery/light_fixture))
		return
	if(user.a_intent != "hurt")
		return

	if(status == LIGHT_OK || status == LIGHT_BURNED)
		user << "The [name] shatters!"
		status = LIGHT_BROKEN
		force = 5
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		update()



// a box of replacement light items

/obj/item/weapon/storage/lightbox
	name = "replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	icon_state = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap
	storage_slots=21
	can_hold = list("/obj/item/weapon/lamp/tube", "/obj/item/weapon/lamp/bulb")
	max_combined_w_class = 21

/obj/item/weapon/storage/lightbox/bulbs/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/lamp/bulb(src)

/obj/item/weapon/storage/lightbox/tubes
	name = "replacement tubes"
	icon_state = "lighttube"

/obj/item/weapon/storage/lightbox/tubes/New()
	..()
	for(var/i = 0; i < 21; i++)
		new /obj/item/weapon/lamp/tube(src)

/obj/item/weapon/storage/lightbox/mixed
	name = "replacement lights"
	icon_state = "lightmixed"

/obj/item/weapon/storage/lightbox/mixed/New()
	..()
	for(var/i = 0; i < 14; i++)
		new /obj/item/weapon/lamp/tube(src)
	for(var/i = 0; i < 7; i++)
		new /obj/item/weapon/lamp/bulb(src)

/obj/structure/light_frame
	name = "Light Fixture Frame"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-empty"
	desc = "A lighting fixture frame."
	anchored = 0
	layer = 5
	var/light_type = /obj/machinery/light_fixture
	var/wired = 0
	m_amt = 1000

/obj/structure/light_frame/small
	light_type = /obj/machinery/light_fixture/small
	icon_state = "bulb-empty"

/obj/structure/light_frame/lamp
	light_type = /obj/machinery/light_fixture/lamp
	icon_state = "lamp-empty"

/obj/structure/light_frame/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench) && !anchored)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] secures the light fixture.", "You start to secure the light fixture.")
		sleep(40)
		if(get_turf(user) == T)
			usr << "\blue You secure the light fixture."
			anchored = 1
			name = "Secured Light Fixture Frame"
	else if(istype(W, /obj/item/weapon/wrench) && anchored)
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		var/turf/T = get_turf(user)
		user.visible_message("[user] unsecures the light fixture.", "You start to unsecure the light fixture.")
		sleep(40)
		if(get_turf(user) == T)
			usr << "\blue You unsecure the light fixture."
			anchored = 0
			name = "Light Fixture Frame"
	else if(istype(W, /obj/item/weapon/cable_coil) && anchored)
		var/turf/T = get_turf(user)
		user.visible_message("[user] wires the light fixture.", "You start to wire the light fixture.")
		sleep(40)
		if(get_turf(user) == T)
			var/obj/item/weapon/cable_coil/C = W
			C.use(1)
			usr << "\blue You wire the light fixture."
			var/obj/machinery/light_fixture/L = new light_type(loc)
			L.dir = dir
			L.status = LIGHT_EMPTY
			L.update()
			del(src)
	else if(istype(W, /obj/item/weapon/screwdriver) && !anchored)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
		usr << "\blue You take apart the light fixture."
		new /obj/item/stack/sheet/metal(loc)
		del(src)
	else
		..()

/obj/structure/light_frame/verb/rotate()
	set name = "Rotate Light"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the wall; therefore, you can't rotate it!"
		return 0

	src.dir = turn(src.dir, 90)
	return
