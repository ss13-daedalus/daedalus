/obj/item/police_tape
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	icon = 'police_tape.dmi'
	anchored = 1
	density = 1
	req_access = list(access_security)

/obj/item/police_tape/Bumped(M as mob)
	if(src.allowed(M))
		var/turf/T = get_turf(src)
		M:loc = T

/obj/item/police_tape/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if ((mover.flags & 2 || istype(mover, /obj/effect/meteor) || mover.throwing == 1) )
		return 1
	else
		return 0

/obj/item/police_tape/attackby(obj/item/weapon/W as obj, mob/user as mob)
	breaktape(W, user)

/obj/item/police_tape/attack_hand(mob/user as mob)
	breaktape(null, user)

/obj/item/police_tape/attack_paw(mob/user as mob)
	breaktape(/obj/item/weapon/wirecutters,user)

/obj/item/police_tape/proc/breaktape(obj/item/weapon/W as obj, mob/user as mob)
	if(user.a_intent == "help" && ((!is_sharp(W) && src.allowed(user)) ||(!is_cut(W) && !src.allowed(user))))
		user << "You can't break the tape with that!"
		return
	user.show_viewers(text("\blue [] breaks the police tape!", user))
	var/OX = src.x
	var/OY = src.y
	if(src.icon_state == "horizontal")
		var/N = 0
		var/X = OX + 1
		var/turf/T = src.loc
		while(N != 1)
			N = 1
			T = locate(X,T.y,T.z)
			for (var/obj/item/police_tape/P in T)
				N = 0
				if(P.icon_state == "horizontal")
					del(P)
			X += 1

		X = OX - 1
		N = 0
		while(N != 1)
			N = 1
			T = locate(X,T.y,T.z)
			for (var/obj/item/police_tape/P in T)
				N = 0
				if(P.icon_state == "horizontal")
					del(P)
			X -= 1

	if(src.icon_state == "vertical")
		var/N = 0
		var/Y = OY + 1
		var/turf/T = src.loc
		while(N != 1)
			N = 1
			T = locate(T.x,Y,T.z)
			for (var/obj/item/police_tape/P in T)
				N = 0
				if(P.icon_state == "vertical")
					del(P)
			Y += 1

		Y = OY - 1
		N = 0
		while(N != 1)
			N = 1
			T = locate(T.x,Y,T.z)
			for (var/obj/item/police_tape/P in T)
				N = 0
				if(P.icon_state == "vertical")
					del(P)
			Y -= 1

	del(src)
	return

