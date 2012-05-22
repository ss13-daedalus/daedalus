/obj/item/barricade_tape
	name = "tape"
	icon = 'icons/barricade_tape.dmi'
	anchored = 1
	density = 1
	var/icon_base

/obj/item/barricade_tape/police
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	req_access = list(ACCESS_SECURITY)
	icon_base = "police"

/obj/item/barricade_tape/engineering
	name = "engineering tape"
	desc = "A length of engineering tape. Better not cross it."
	req_access = list(ACCESS_ENGINE,ACCESS_ATMOSPHERICS)
	icon_base = "engineering"

/obj/item/barricade_tape/Bumped(M as mob)
	if(src.allowed(M))
		var/turf/T = get_turf(src)
		M:loc = T

/obj/item/barricade_tape/CanPass(atom/movable/mover, turf/target, height=0, FEA_airgroup=0)
	if(!density) return 1
	if(FEA_airgroup || (height==0)) return 1

	if ((mover.flags & 2 || mover.throwing == 1) )
		return 1
	else
		return 0

/obj/item/barricade_tape/attackby(obj/item/weapon/W as obj, mob/user as mob)
	breaktape(W, user)

/obj/item/barricade_tape/attack_hand(mob/user as mob)
	if (user.a_intent == "help" && src.allowed(user))
		user.show_viewers("\blue [user] lifts [src], allowing passage.")
		src.density = 0
		spawn(200)
			src.density = 1
	else
		breaktape(null, user)

/obj/item/barricade_tape/attack_paw(mob/user as mob)
	breaktape(/obj/item/weapon/wirecutters,user)

/obj/item/barricade_tape/proc/breaktape(obj/item/weapon/W as obj, mob/user as mob)
	if(user.a_intent == "help" && ((!is_sharp(W) && src.allowed(user)) ||(!is_cut(W) && !src.allowed(user))))
		user << "You can't break the [src] with that!"
		return
	user.show_viewers("\blue [user] breaks the [src]!")

	var/dir[2]
	var/icon_dir = src.icon_state
	if(icon_dir == "[src.icon_base]_h")
		dir[1] = EAST
		dir[2] = WEST
	if(icon_dir == "[src.icon_base]_v")
		dir[1] = NORTH
		dir[2] = SOUTH

	for(var/i=1;i<3;i++)
		var/N = 0
		var/turf/cur = get_step(src,dir[i])
		while(N != 1)
			N = 1
			for (var/obj/item/barricade_tape/P in cur)
				if(P.icon_state == icon_dir)
					N = 0
					del(P)
			cur = get_step(cur,dir[i])

	del(src)
	return
