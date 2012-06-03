/obj/item/weapon/cleaner
	desc = "A chemical that cleans messes."
	icon = 'icons/obj/janitor.dmi'
	name = "space cleaner"
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = ONBELT|TABLEPASS|OPENCONTAINER|FPRINT|USEDELAY
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/catch = 1

/obj/item/weapon/cleaner/New()
	var/datum/reagents/R = new/datum/reagents(250)
	reagents = R
	R.my_atom = src
	R.add_reagent("cleaner", 250)

/obj/item/weapon/cleaner/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/cleaner/attack_self(var/mob/user as mob)
	if(catch)
		user << "\blue You flip the safety off."
		catch = 0
		return
	else
		user << "\blue You flip the safety on."
		catch = 1
		return

/obj/item/weapon/cleaner/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/item/weapon/storage ))
		return
	if (istype(A, /obj/effect/proc_holder/spell ))
		return
	else if (catch == 1)
		user << "\blue The safety is on!"
		return
	else if (src.reagents.total_volume < 1)
		user << "\blue [src] is empty!"
		return

	var/obj/effect/decal/D = new/obj/effect/decal(get_turf(src))
	D.create_reagents(5)
	src.reagents.trans_to(D, 5)

	D.name = "chemicals"
	D.icon = 'icons/obj/chempuff.dmi'

	D.icon += get_reagent_color_mix(D.reagents.reagent_list)

	playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)

	spawn(0)
		for(var/i=0, i<3, i++)
			step_towards(D,A)
			D.reagents.reaction(get_turf(D))
			for(var/atom/T in get_turf(D))
				D.reagents.reaction(T)
			sleep(3)
		del(D)

	if(isrobot(user)) //Cyborgs can clean forever if they keep charged
		var/mob/living/silicon/robot/janitor = user
		janitor.cell.charge -= 20
		var/refill = src.reagents.get_master_reagent_id()
		spawn(600)
			src.reagents.add_reagent(refill, 10)

	if(src.reagents.has_reagent("pacid"))
		message_admins("[key_name_admin(user)] fired Polyacid from a Cleaner bottle.")
		log_game("[key_name(user)] fired Polyacid from a Cleaner bottle.")
	if(src.reagents.has_reagent("lube"))
		message_admins("[key_name_admin(user)] fired Space lube from a Cleaner bottle.")
		log_game("[key_name(user)] fired Space lube from a Cleaner bottle.")
	return

/obj/item/weapon/cleaner/examine()
	set src in usr
	for(var/datum/reagent/R in reagents.reagent_list)
		usr << text("\icon[] [] units of [] left!", src, round(R.volume), R.name)
	//usr << text("\icon[] [] units of cleaner left!", src, src.reagents.total_volume)
	..()
	return
