/////////////////
//SMOKING PIPES//
/////////////////

/obj/item/clothing/mask/pipe
	name = "smoking pipe"
	desc = "A pipe, for smoking. Probably made of meershaum or something."
	icon_state = "cobpipeoff"
	throw_speed = 0.5
	item_state = "cobpipeoff"
	w_class = 1
	body_parts_covered = null
	var
		lit = 0
		icon_on = "cobpipeon"  //Note - these are in masks.dmi
		icon_off = "cobpipeoff"
		lastHolder = null
		smoketime = 100
		maxsmoketime = 100 //make sure this is equal to your smoketime
	proc
		light(var/flavor_text = "[usr] lights the [name].")

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if(istype(W, /obj/item/weapon/weldingtool) && W:welding)
			light("\red [user] casually lights the [name] with [W], what a badass.")

		else if(istype(W, /obj/item/weapon/lighter/zippo) && (W:lit > 0))
			light("\red With a single flick of their wrist, [user] smoothly lights their [name] with their [W]. Damn they're cool.")

		else if(istype(W, /obj/item/weapon/lighter) && (W:lit > 0))
			light("\red After some fiddling, [user] manages to light their [name] with [W].")

		else if(istype(W, /obj/item/weapon/match) && (W:lit > 0))
			light("\red [user] lights \his [name] with \his [W].")
		return

	light(var/flavor_text = "[usr] lights the [name].")
		if(!src.lit)
			src.lit = 1
			src.damtype = "fire"
			src.icon_state = icon_on
			src.item_state = icon_on
			for(var/mob/O in viewers(usr, null))
				O.show_message(flavor_text, 1)
			processing_objects.Add(src)

	process()
		var/turf/location = get_turf(src)
		src.smoketime--
		if(src.smoketime < 1)
			new /obj/effect/decal/ash(location)
			if(ismob(src.loc))
				var/mob/living/M = src.loc
				M << "\red Your [src.name] goes out, and you empty the ash."
				src.lit = 0
				src.icon_state = icon_off
				src.item_state = icon_off
			processing_objects.Remove(src)
			return
		if(location)
			location.hotspot_expose(700, 5)
		return

	dropped(mob/user as mob)
		if(src.lit == 1)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] puts out the [].", user,src.name), 1)
				src.lit = 0
				src.icon_state = icon_off
				src.item_state = icon_off
			processing_objects.Remove(src)
		return ..()

/obj/item/clothing/mask/pipe/attack_self(mob/user as mob) //Refills the pipe. Can be changed to an attackby later, if loose tobacco is added to vendors or something.
	if(src.smoketime <= 0)
		user << "\blue You refill the pipe with tobacco."
		smoketime = maxsmoketime
	return
/*
/obj/item/clothing/mask/pipe/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/match))
		..()
	else
		user << "\red The [src] straight out REFUSES to be lit by such means."
*/// Yeah no. DMTG


/obj/item/clothing/mask/pipe/cobpipe
	name = "corn cob pipe"
	desc = "A nicotine delivery system popularized by folksy backwoodsmen and kept popular in the modern age and beyond by space hipsters."
	smoketime = 400
	maxsmoketime = 400
