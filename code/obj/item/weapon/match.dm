///////////
//MATCHES//
///////////
/obj/item/weapon/match
	name = "Match"
	desc = "A simple match stick, used for lighting tobacco"
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = 0
	var/smoketime = 5
	w_class = 1.0
	origin_tech = "materials=1"


	process()
		var/turf/location = get_turf(src)
		if(src.lit == 1)
			if(location)
				location.hotspot_expose(700, 5)
			src.smoketime--
			sleep(10)
			if(src.smoketime < 1)
				src.icon_state = "match_burnt"
				src.lit = -1
				processing_objects.Remove(src)
				return


	dropped(mob/user as mob)
		if(src.lit == 1)
			spawn(10)
				var/turf/location = get_turf(src)
				location.hotspot_expose(700, 5)
				src.lit = -1
				src.damtype = "brute"
				src.icon_state = "match_burnt"
				src.item_state = "cigoff"
				src.name = "Burnt match"
				src.desc = "A match that has been burnt"
				processing_objects.Remove(src)
		return ..()
