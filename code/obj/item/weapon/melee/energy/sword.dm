// SWORD
/obj/item/weapon/melee/energy/sword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/melee/energy/sword/New()
	color = pick("red","blue","green","purple")

/obj/item/weapon/melee/energy/sword/attack_self(mob/living/user as mob)
	if ((user.mutations & CLUMSY) && prob(50))
		user << "\red You accidentally cut yourself with [src]."
		user.take_organ_damage(5,5)
	active = !active
	if (active)
		force = 30
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass1"
		else
			icon_state = "sword[color]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		user << "\blue [src] is now active."
	else
		force = 3
		if(istype(src,/obj/item/weapon/melee/energy/sword/pirate))
			icon_state = "cutlass0"
		else
			icon_state = "sword0"
		w_class = 2
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		user << "\blue [src] can now be concealed."
	add_fingerprint(user)
	user.update_clothing()
	return

/obj/item/weapon/melee/energy/sword/green
	New()
		color = "green"

/obj/item/weapon/melee/energy/sword/red
	New()
		color = "red"
