/obj/item/police_tape_roll
	name = "police tape roll"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon = 'icons/police_tape.dmi'
	icon_state = "rollstart"
	flags = FPRINT
	w_class = 1.0
	var/tapestartx = 0
	var/tapestarty = 0
	var/tapestartz = 0
	var/tapeendx = 0
	var/tapeendy = 0
	var/tapeendz = 0

/obj/item/police_tape_roll/attack_self(mob/user as mob)
	if(icon_state == "rollstart")
		tapestartx = src.loc.x
		tapestarty = src.loc.y
		tapestartz = src.loc.z
		usr << "\blue You place the first end of the police tape."
		icon_state = "rollstop"
	else
		tapeendx = src.loc.x
		tapeendy = src.loc.y
		tapeendz = src.loc.z
		var/tapetest = 0
		if(tapestartx == tapeendx && tapestarty > tapeendy && tapestartz == tapeendz)
			for(var/Y=tapestarty,Y>=tapeendy,Y--)
				var/turf/T = get_turf(locate(tapestartx,Y,tapestartz))
				if(T.density == 1)
					usr << "\blue You can't run police tape through a wall!"
					icon_state = "rollstart"
					return
			for(var/Y=tapestarty,Y>=tapeendy,Y--)
				var/turf/T = get_turf(locate(tapestartx,Y,tapestartz))
				for(var/obj/item/police_tape/Ptest in T)
					if(Ptest.icon_state == "vertical")
						tapetest = 1
				if(tapetest != 1)
					var/obj/item/police_tape/P = new/obj/item/police_tape(tapestartx,Y,tapestartz)
					P.loc = locate(tapestartx,Y,tapestartz)
					P.icon_state = "vertical"
			usr << "\blue You finish placing the police tape."	//Git Test

		if(tapestartx == tapeendx && tapestarty < tapeendy && tapestartz == tapeendz)
			for(var/Y=tapestarty,Y<=tapeendy,Y++)
				var/turf/T = get_turf(locate(tapestartx,Y,tapestartz))
				if(T.density == 1)
					usr << "\blue You can't run police tape through a wall!"
					icon_state = "rollstart"
					return
			for(var/Y=tapestarty,Y<=tapeendy,Y++)
				var/turf/T = get_turf(locate(tapestartx,Y,tapestartz))
				for(var/obj/item/police_tape/Ptest in T)
					if(Ptest.icon_state == "vertical")
						tapetest = 1
				if(tapetest != 1)
					var/obj/item/police_tape/P = new/obj/item/police_tape(tapestartx,Y,tapestartz)
					P.loc = locate(tapestartx,Y,tapestartz)
					P.icon_state = "vertical"
			usr << "\blue You finish placing the police tape."

		if(tapestarty == tapeendy && tapestartx > tapeendx && tapestartz == tapeendz)
			for(var/X=tapestartx,X>=tapeendx,X--)
				var/turf/T = get_turf(locate(X,tapestarty,tapestartz))
				if(T.density == 1)
					usr << "\blue You can't run police tape through a wall!"
					icon_state = "rollstart"
					return
			for(var/X=tapestartx,X>=tapeendx,X--)
				var/turf/T = get_turf(locate(X,tapestarty,tapestartz))
				for(var/obj/item/police_tape/Ptest in T)
					if(Ptest.icon_state == "horizontal")
						tapetest = 1
				if(tapetest != 1)
					var/obj/item/police_tape/P = new/obj/item/police_tape(X,tapestarty,tapestartz)
					P.loc = locate(X,tapestarty,tapestartz)
					P.icon_state = "horizontal"
			usr << "\blue You finish placing the police tape."

		if(tapestarty == tapeendy && tapestartx < tapeendx && tapestartz == tapeendz)
			for(var/X=tapestartx,X<=tapeendx,X++)
				var/turf/T = get_turf(locate(X,tapestarty,tapestartz))
				if(T.density == 1)
					usr << "\blue You can't run police tape through a wall!"
					icon_state = "rollstart"
					return
			for(var/X=tapestartx,X<=tapeendx,X++)
				var/turf/T = get_turf(locate(X,tapestarty,tapestartz))
				for(var/obj/item/police_tape/Ptest in T)
					if(Ptest.icon_state == "horizontal")
						tapetest = 1
				if(tapetest != 1)
					var/obj/item/police_tape/P = new/obj/item/police_tape(X,tapestarty,tapestartz)
					P.loc = locate(X,tapestarty,tapestartz)
					P.icon_state = "horizontal"
			usr << "\blue You finish placing the police tape."

		if(tapestarty != tapeendy && tapestartx != tapeendx)
			usr << "\blue Police tape can only be laid horizontally or vertically."
		icon_state = "rollstart"

/obj/item/police_tape_roll/afterattack(var/atom/A, mob/user as mob)
	if (istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/item/police_tape/P = new/obj/item/police_tape(T.x,T.y,T.z)
		P.loc = locate(T.x,T.y,T.z)
		P.icon_state = "door"
		P.layer = 3.2
		user << "\blue You finish placing the police tape."
