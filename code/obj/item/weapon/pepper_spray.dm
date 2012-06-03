//Pepper spray, set up to make the 2 different types
/obj/item/weapon/pepper_spray //This is riot control
	desc = "Manufactured by UhangInc., used to blind and down an opponent quickly."
	icon = 'icons/obj/weapons.dmi'
	name = "pepper spray"
	icon_state = "pepperspray"
	item_state = "pepperspray"
	flags = ONBELT|TABLEPASS|FPRINT|USEDELAY
	throwforce = 3
	w_class = 2.0
	throw_speed = 2
	throw_range = 10
	var/catch = 1
	var/BottleSize = 1
	var/ReagentAmount = 45

/obj/item/weapon/pepper_spray/small //And this is for personal defense.
	desc = "This appears to be a small, nonlethal, single use personal defense weapon.  Hurts like a bitch, though."
	icon = 'icons/obj/weapons.dmi'
	name = "mace"
	icon_state = "pepperspray"
	item_state = "pepperspray"
	flags = ONBELT|TABLEPASS|FPRINT|USEDELAY
	throwforce = 3
	w_class = 1.0
	throw_speed = 2
	throw_range = 10
	catch = 1
	BottleSize = 0
	ReagentAmount = 1

/obj/item/weapon/pepper_spray/New()
	var/datum/reagents/R = new/datum/reagents(ReagentAmount)
	reagents = R
	R.my_atom = src
	R.add_reagent("condensedcapsaicin", ReagentAmount)

/obj/item/weapon/pepper_spray/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/weapon/pepper_spray/attack_self(var/mob/user as mob)
	if(catch)
		user << "\blue You flip the safety off."
		catch = 0
		return
	else
		user << "\blue You flip the safety on."
		catch = 1
		return

/obj/item/weapon/pepper_spray/afterattack(atom/A as mob|obj, mob/user as mob)
	if ( A == src )
		return
	if (istype(A, /obj/item/weapon/storage ))
		return
	if (istype(A, /obj/effect/proc_holder/spell ))
		return
	else if (istype(A, /obj/structure/reagent_dispensers/peppertank) && get_dist(src,A) <= 1)
		if(src.reagents.total_volume < ReagentAmount)
			A.reagents.trans_to(src, ReagentAmount - src.reagents.total_volume)
			user << "\blue Pepper spray refilled"
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			return
		else
			user << "\blue Pepper spray is already full!"
			return
	else if (catch == 1)
		user << "\blue The safety is on!"
		return
	else if (src.reagents.total_volume < 1)
		user << "\blue [src] is empty!"
		return
	playsound(src.loc, 'sound/effects/spray2.ogg', 50, 1, -6)

	var/SprayNum = 0 //Setting up the differentiation for the 2 bottles.   --SkyMarshal
	var/SprayAmt = 0
	if(BottleSize)
		SprayNum = 3
		SprayAmt = 5
	else
		SprayNum = 1
		SprayAmt = 1

	var/Sprays[SprayNum]
	for(var/i=1, i<=SprayNum, i++) // intialize sprays
		if(src.reagents.total_volume < 1) break
		var/obj/effect/decal/D = new/obj/effect/decal(get_turf(src))
		D.name = "chemicals"
		D.icon = 'icons/obj/chempuff.dmi'
		D.create_reagents(SprayAmt)
		src.reagents.trans_to(D, SprayAmt)

		D.icon += get_reagent_color_mix(D.reagents.reagent_list)

		Sprays[i] = D

	//var/direction = get_dir(src, A)
	//var/turf/T = get_turf(A)
	//var/turf/T1 = get_step(T,turn(direction, 90))
	//var/turf/T2 = get_step(T,turn(direction, -90))
	//var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=Sprays.len, i++)
		spawn()
			var/obj/effect/decal/D = Sprays[i]
			if(!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = get_turf(A) //pick(the_targets)
			//the_targets -= my_target

			var/list/affected = new()	// BubbleWrap
			for(var/j=1, j<=rand(6,8), j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					if ( !(t in affected) )	// Only spray each person once, removes chat spam
						D.reagents.reaction(t)
						affected += t
				sleep(2)
			del(D)
	sleep(1)

	if(isrobot(user)) //Cyborgs can clean forever if they keep charged
		var/mob/living/silicon/robot/janitor = user
		janitor.cell.charge -= 20
		var/refill = src.reagents.get_master_reagent_id()
		spawn(600)
			src.reagents.add_reagent(refill, 45)
	return


/obj/item/weapon/pepper_spray/examine()
	set src in usr
	if(BottleSize)
		usr << text("\icon[] [] units of pepper spray left!", src, src.reagents.total_volume)
		..()
		return
	else
		usr << text("\icon[] [] use(s) remaining!", src, src.reagents.total_volume)
		..()
		return
