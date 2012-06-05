
// Nettle

/obj/item/weapon/grown/nettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		user << "\red The nettle burns your bare hand!"
		if(hasorgans(user))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/datum/organ/external/affecting = user:get_organ(organ)
			affecting.take_damage(0,force)
		else
			user.take_organ_damage(0,force)

/obj/item/weapon/grown/nettle/afterattack(atom/A as mob|obj, mob/user as mob)
	if(force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off
	else
		usr << "All the leaves have fallen off the nettle from violent whacking."
		del(src)
