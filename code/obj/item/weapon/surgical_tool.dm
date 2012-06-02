//////////////////////////////
// Bone Gel and Bone Setter //
//////////////////////////////

/obj/item/weapon/surgical_tool
	name = "surgical tool"
	var/list/stage = list() //Stage to act on
	var/time = 50 //Time it takes to use
	var/list/wound = list()//Wound type to act on

	proc/get_message(var/mnumber,var/M,var/user,var/datum/organ/external/organ)//=Start,2=finish,3=walk away,4=screw up, 5 = closed wound
	proc/screw_up(mob/living/carbon/M as mob,mob/living/carbon/user as mob,var/datum/organ/external/organ)
		organ.brute_dam += 30
/obj/item/weapon/surgical_tool/proc/IsFinalStage(var/stage)
	var/a = 3
	return stage == a

/obj/item/weapon/surgical_tool/attack(mob/living/carbon/human/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return
	if((usr.mutations & 16) && prob(50))
		M << "\red You stab yourself in the eye."
		M.disabilities |= 128
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	var/zone = user.zone_sel.selecting
	if (istype(M.organs[zone], /datum/organ/external))
		var/datum/organ/external/temp = M.organs[zone]
		var/msg

		if(temp.destroyed)
			return ..()

        // quickly convert embryo removal to bone surgery
		if(zone == "chest" && M.embryo_op_stage == 3)
			M.embryo_op_stage = 0
			temp.open = 2
			temp.bleeding = 0

		// quickly convert appendectomy to bone surgery
		if(zone == "groin" && M.appendix_op_stage == 3)
			M.appendix_op_stage = 0
			temp.open = 2
			temp.bleeding = 0

		msg = get_message(1,M,user,temp)
		for(var/mob/O in viewers(M,null))
			O.show_message("\red [msg]",1)
		if(do_mob(user,M,time))
			if(temp.open == 2 && !temp.bleeding)
				if(temp.wound in wound)
					if(temp.stage in stage)
						temp.stage += 1

						if(IsFinalStage(temp.stage))
							temp.broken = 0
							temp.stage = 0
							temp.perma_injury = 0
							temp.brute_dam = temp.min_broken_damage -1
						msg = get_message(2,M,user,temp)
					else
						msg = get_message(4,M,user,temp)
						screw_up(M,user,temp)
				else
					msg = get_message(5,M,user,temp)
		else
			msg = get_message(3,M,user,temp)

		for(var/mob/O in viewers(M,null))
			O.show_message("\red [msg]",1)


/*Broken bone
 Basic:
 Open -> Clean -> Bone-gel -> pop-into-place -> Bone-gel -> close -> glue -> clean

 Split:
 Open -> Clean -> Tweasers -> bone-glue -> close -> glue -> clean

 The above might not apply anymore.

*/

/obj/item/weapon/surgical_tool/bonegel
	name = "bone gel"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone gel"

/obj/item/weapon/surgical_tool/bonegel/New()
	stage += 0
	stage += 2
	wound += "broken"
	wound += "fracture"
	wound += "hairline fracture"
/obj/item/weapon/surgical_tool/bonegel/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts applying bone gel to [m]'s [organ.display_name]"
		if(2)
			z="[usr] finishes applying bone gel to [m]'s [organ.display_name]"
		if(3)
			z="[usr] stops applying bone gel to [m]'s [organ.display_name]"
		if(4)
			z="[usr] applies bone gel incorrectly to [m]'s [organ.display_name]"
		if(5)
			z="[usr] lubricates [m]'s [organ.display_name]"
	return z

/obj/item/weapon/surgical_tool/bonesetter
	name = "bone setter"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "bone setter"

/obj/item/weapon/surgical_tool/bonesetter/New()
	stage += 1
	wound += "broken"
	wound += "fracture"
	wound += "hairline fracture"
/obj/item/weapon/surgical_tool/bonesetter/get_message(var/n,var/m,var/usr,var/datum/organ/external/organ)
	var/z
	switch(n)
		if(1)
			z="[usr] starts popping [m]'s [organ.display_name] bone into place"
		if(2)
			z="[usr] finishes popping [m]'s [organ.display_name] bone into place"
		if(3)
			z="[usr] stops popping [m]'s [organ.display_name] bone into place"
		if(4)
			z="[usr] pops [m]'s [organ.display_name] bone into the wrong place"
		if(5)
			z="[usr] performs chiropractice on [m]'s [organ.display_name]"
	return z


