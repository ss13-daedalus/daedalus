
/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (istype(O, /obj/item/weapon/plant_bag))
		var/obj/item/weapon/plant_bag/S = O
		if (S.mode == 1)
			for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(src.x,src.y,src.z))
				if (S.contents.len < S.capacity)
					S.contents += G;
				else
					user << "\blue The plant bag is full."
					return
			user << "\blue You pick up all the plants."
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
			else
				user << "\blue The plant bag is full."
	return
