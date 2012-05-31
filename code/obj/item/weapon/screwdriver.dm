// SCREWDRIVER
/obj/item/weapon/screwdriver/New()
	icon_state = pick("screwdriver","screwdriver2","screwdriver3","screwdriver4","screwdriver5","screwdriver6","screwdriver7")
	if (prob(75))
		src.pixel_y = rand(0, 16)
	return

/obj/item/weapon/screwdriver/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))	return ..()
	if(user.zone_sel.selecting != "eyes" && user.zone_sel.selecting != "head")
		return ..()
	if((user.mutations & CLUMSY) && prob(50))
		M = user
	return eyestab(M,user)
