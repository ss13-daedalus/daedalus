
/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/cable_coil))
		if(W:amount >= 5)
			W:amount -= 5
			if(!W:amount) del(W)
			user << "<span class='notice'>You add some cable to the potato and slide it inside the battery encasing.</span>"
			new /obj/item/weapon/power_cell/potato(user.loc)
			del(src)
			return
