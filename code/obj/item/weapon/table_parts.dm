// TABLE PARTS

/obj/item/weapon/table_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( src.loc )
		//SN src = null
		del(src)

/obj/item/weapon/table_parts/attack_self(mob/user as mob)
	var/obj/structure/table/T = new /obj/structure/table( user.loc )
	T.add_fingerprint(usr)
	del(src)
	return

// WOODEN TABLE PARTS
/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/wood( src.loc )
		//SN src = null
		del(src)
	else
		..()

/obj/item/weapon/table_parts/wood/attack_self(mob/user as mob)
	new /obj/structure/table/woodentable( user.loc )
	del(src)
	return


// REINFORCED TABLE PARTS
/obj/item/weapon/table_parts/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/plasteel( src.loc )
		//SN src = null
		del(src)

/obj/item/weapon/table_parts/reinforced/attack_self(mob/user as mob)
	new /obj/structure/table/reinforced( user.loc )
	del(src)
	return

