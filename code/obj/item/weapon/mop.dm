// MOP
/obj/item/weapon/mop
	desc = "The world of the janitor wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	var/mopping = 0
	var/mopcount = 0
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = 3.0
	flags = FPRINT | TABLEPASS


/obj/item/weapon/mop/New()
	var/datum/reagents/R = new/datum/reagents(5)
	reagents = R
	R.my_atom = src


/obj/item/weapon/mop/proc/clean(turf/simulated/A as turf)
	src.reagents.reaction(A,1,10)
	A.clean_blood()
	for(var/obj/effect/rune/R in A)
		del(R)
	for(var/obj/effect/decal/cleanable/R in A)
		del(R)
	for(var/obj/effect/overlay/R in A)
		del(R)

/obj/item/weapon/mop/afterattack(atom/A, mob/user as mob)
	if (isnull(A))
		user << "\red You've encountered a nasty bug. You should tell a developer what you were trying to clean with the mop."
		return

	if (src.reagents.total_volume < 1 || mopcount >= 5)
		user << "\blue Your mop is dry!"
		return

	if (istype(A, /turf/simulated))
		for(var/mob/O in viewers(user, null))
			O.show_message("\red <B>[user] begins to clean \the [A]</B>", 1)
		sleep(40)
		if(A)
			clean(A)
		user << "\blue You have finished mopping!"
		mopcount++
	else if (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		for(var/mob/O in viewers(user, null))
			O.show_message("\red <B>[user] begins to clean \the [get_turf(A)]</B>", 1)
		sleep(40)
		if(A)
			clean(get_turf(A))
		user << "\blue You have finished mopping!"
		mopcount++

	if(mopcount >= 5) //Okay this stuff is an ugly hack and i feel bad about it.
		spawn(5)
			src.reagents.clear_reagents()
			mopcount = 0
	return

