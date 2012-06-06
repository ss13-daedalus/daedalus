/obj/effect/spresent/relaymove(mob/user as mob)
	if (user.stat)
		return
	user << "\blue You cant move."

/obj/effect/spresent/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (!istype(W, /obj/item/weapon/wire_cutters))
		user << "/blue I need wire cutters for that."
		return

	user << "\blue You cut open the present."

	for(var/mob/M in src) //Should only be one but whatever.
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	del(src)

