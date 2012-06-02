/////////////////
//BONE INJECTOR//
/////////////////

/obj/item/weapon/bone_injector
	name = "Bone-repairing Nanites Injector"
	desc = "This injects the person with nanites that repair bones."
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter1"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/uses = 5

/obj/item/weapon/bone_injector/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/weapon/bone_injector/proc/inject(mob/M as mob)
	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		for(var/name in H.organs)
			var/datum/organ/external/e = H.organs[name]
			if(e.destroyed) // this is nanites, not space magic
				continue
			e.brute_dam = 0.0
			e.burn_dam = 0.0
			e.bandaged = 0.0
			e.max_damage = initial(e.max_damage)
			e.bleeding = 0
			e.open = 0
			e.broken = 0
			e.destroyed = 0
			e.perma_injury = 0
			e.update_icon()
		H.update_body()
		H.update_face()
		H.UpdateDamageIcon()

	uses--
	if(uses == 0)
		spawn(0)//this prevents the collapse of space-time continuum
			del(src)
	return uses

/obj/item/weapon/bone_injector/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [M.name] ([M.ckey])</font>")
	log_admin("ATTACK: [user] ([user.ckey]) injected [M] ([M.ckey]) with [src].")

	if (user)
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [] has been injected with [] by [].", M, src, user), 1)
			//Foreach goto(192)
		if (!(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey)))
			user << "\red Apparently it didn't work."
			return
		inject(M)//Now we actually do the heavy lifting.

		if(!isnull(user))//If the user still exists. Their mob may not.
			user.show_message(text("\red You inject [M]"))
	return
