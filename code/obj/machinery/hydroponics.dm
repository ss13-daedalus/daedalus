/obj/machinery/hydroponics/attackby(var/obj/item/O as obj, var/mob/user as mob)
	..()
	if (istype(O, /obj/item/weapon/plant_bag))
		src.attack_hand(user)
		var/obj/item/weapon/plant_bag/S = O
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if (S.contents.len < S.capacity)
				S.contents += G;
			else
				user << "\blue The plant bag is full."
				return
