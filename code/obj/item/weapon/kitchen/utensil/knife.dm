
// KNIFE

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/living/user as mob)
	if ((user.mutations & CLUMSY) && prob(50))
		user << "\red You accidentally cut yourself with the [src]."
		user.take_organ_damage(20)
		return
	return ..()
