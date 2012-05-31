//////////////
//CIGARETTES//
//////////////

/obj/item/clothing/mask/cigarette
	name = "Cigarette"
	desc = "A roll of tobacco and nicotine."
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = 1
	body_parts_covered = null
	var
		lit = 0
		icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
		icon_off = "cigoff"
		icon_butt = "cigbutt"
		lastHolder = null
		smoketime = 300
		butt_count = 5  //count of butt sprite variations
	proc
		light(var/flavor_text = "[usr] lights the [name].")

		put_out()
			if (src.lit == -1)
				return
			src.lit = -1
			src.damtype = "brute"
			src.icon_state = icon_butt + "[rand(0,butt_count)]"
			src.item_state = icon_off
			src.desc = "A [src.name] butt."
			src.name = "[src.name] butt"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if(istype(W, /obj/item/weapon/welding_tool) && W:welding)
			light("\red [user] casually lights the [name] with [W], what a badass.")

		else if(istype(W, /obj/item/weapon/lighter/zippo) && (W:lit > 0))
			light("\red With a single flick of their wrist, [user] smoothly lights their [name] with their [W]. Damn they're cool.")

		else if(istype(W, /obj/item/weapon/lighter) && (W:lit > 0))
			light("\red After some fiddling, [user] manages to light their [name] with [W].")

		else if(istype(W, /obj/item/weapon/match) && (W:lit > 0))
			light("\red [user] lights their [name] with their [W].")
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
			if(ismob(src.loc))
				var/mob/living/M = src.loc
				M << "\red Your [src.name] goes out."
				put_out()
				M.update_clothing()
			else
				put_out()
			processing_objects.Remove(src)
			return
		if(location)
			location.hotspot_expose(700, 5)
		return


	dropped(mob/user as mob)
		if(src.lit == 1)
			src.visible_message("\red [user] calmly drops and treads on the lit [src], putting it out instantly.")
			put_out()
		return ..()

////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "Premium Cigar"
	desc = "A brown roll of tobacco and... well, you're not quite sure. This thing's huge!"
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff"
	icon_butt = "cigarbutt"
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 1500
	butt_count = 0

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "Cohiba Robusto Cigar"
	desc = "There's little more you could want from a cigar."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "Premium Havanian Cigar"
	desc = "A cigar fit for only the best for the best."
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 7200

