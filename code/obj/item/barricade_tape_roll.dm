/obj/item/barricade_tape_roll
	name = "tape roll"
	icon = 'icons/barricade_tape.dmi'
	icon_state = "rollstart"
	flags = FPRINT
	w_class = 1.0
	var
		turf/start
		turf/end
		tape_type = /obj/item/barricade_tape
		icon_base

	var/tapestartx = 0
	var/tapestarty = 0
	var/tapestartz = 0
	var/tapeendx = 0
	var/tapeendy = 0
	var/tapeendz = 0

/obj/item/barricade_tape_roll/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon_state = "police_start"
	tape_type = /obj/item/barricade_tape/police
	icon_base = "police"

/obj/item/barricade_tape_roll/engineering
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	icon_state = "engineering_start"
	tape_type = /obj/item/barricade_tape/engineering
	icon_base = "engineering"

/obj/item/barricade_tape_roll/attack_self(mob/user as mob)
	if(icon_state == "[icon_base]_start")
		start = get_turf(src)
		usr << "\blue You place the first end of the [src]."
		icon_state = "[icon_base]_stop"
	else
		icon_state = "[icon_base]_start"
		end = get_turf(src)
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			usr << "\blue [src] can only be laid horizontally or vertically."

		var/turf/cur = start
		var/dir
		if (start.x == end.x)
			var/d = end.y-start.y
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x,end.y+d,end.z))
			dir = "v"
		else
			var/d = end.x-start.x
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x+d,end.y,end.z))
			dir = "h"

		while (cur!=end)
			if(cur.density == 1)
				usr << "\blue You can't run [src] through a wall!"
				return
			cur = get_step_towards(cur,end)

		cur = start
		var/tapetest = 0
		while (cur!=end)
			for(var/obj/item/barricade_tape/Ptest in cur)
				if(Ptest.icon_state == "[Ptest.icon_base]_[dir]")
					tapetest = 1
			if(tapetest != 1)
				var/obj/item/barricade_tape/P = new tape_type(cur)
				P.icon_state = "[P.icon_base]_[dir]"
			cur = get_step_towards(cur,end)
	//is_blocked_turf(var/turf/T)
		usr << "\blue You finish placing the [src]."	//Git Test

/obj/item/barricade_tape_roll/police/afterattack(var/atom/A, mob/user as mob)
	if (istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/item/barricade_tape/P = new tape_type(T.x,T.y,T.z)
		P.loc = locate(T.x,T.y,T.z)
		P.icon_state = "[src.icon_base]_door"
		P.layer = 3.2
		user << "\blue You finish placing the [src]."
