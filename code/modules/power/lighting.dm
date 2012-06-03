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
