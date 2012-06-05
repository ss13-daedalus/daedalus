
// Deathnettle

/obj/item/weapon/grown/deathnettle/pickup(mob/living/carbon/human/user as mob)
	if(!user.gloves)
		if(hasorgans(user))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/datum/organ/external/affecting = user:get_organ(organ)
			affecting.take_damage(0,force)
		else
			user.take_organ_damage(0,force)
		if(prob(50))
			user.Paralyse(5)
			user << "\red You are stunned by the Deathnettle when you try picking it up!"

/obj/item/weapon/grown/deathnettle/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!..()) return
	if(istype(M, /mob/living))
		M << "\red You are stunned by the powerful acid of the Deathnettle!"
		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Had the [src.name] used on them by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] on [M.name] ([M.ckey])</font>")

		log_admin("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
		message_admins("ATTACK: [user] ([user.ckey]) attacked [M] ([M.ckey]) with [src].")
		log_attack("<font color='red'> [user.name] ([user.ckey]) used the [src.name] on [M.name] ([M.ckey])</font>")

		M.eye_blurry += force/7
		if(prob(20))
			M.Paralyse(force/6)
			M.Weaken(force/15)
		M.drop_item()

/obj/item/weapon/grown/deathnettle/afterattack(atom/A as mob|obj, mob/user as mob)
	if (force > 0)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off

	else
		usr << "All the leaves have fallen off the deathnettle from violent whacking."
		del(src)
