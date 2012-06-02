// RACK PARTS
/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( src.loc )
		del(src)
		return
	return

/obj/item/weapon/rack_parts/attack_self(mob/user as mob)
	var/obj/structure/rack/R = new /obj/structure/rack( user.loc )
	R.add_fingerprint(user)
	del(src)
	return
