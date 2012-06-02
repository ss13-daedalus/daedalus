/////////////
//RETRACTOR//
/////////////
/obj/item/weapon/retractor/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
		if(S.destroyed)
			if(S.bleeding)
				user << "\red There's too much blood here!"
				return 0
			if(!S.cutaway)
				user << "\red The flesh hasn't been cleanly cut!"
				return 0
			if(M != user)
				M.visible_message( \
					"\red [user] is beginning reposition flesh and nerve endings where [H]'s [S.display_name] used to be with [src].", \
					"\red [user] begins to reposition flesh and nerve endings where [S.display_name] used to be with [src]!")
			else
				M.visible_message( \
					"\red [user] begins to reposition flesh and nerve endings where \his [S.display_name]  used to be with [src]!", \
					"\red You begin to reposition flesh and nerve endings where your [S.display_name] used to be with [src]!")

			if(do_mob(user, H, 100))
				if(M != user)
					M.visible_message( \
						"\red [user] finishes repositioning flesh and nerve endings where [H]'s [S.display_name] used to be with [src]!", \
						"\red [user] finishes repositioning flesh and nerve endings where your [S.display_name] used to be with [src]!")
				else
					M.visible_message( \
						"\red [user] finishes repositioning flesh and nerve endings where \his [S.display_name] used to be with [src]!", \
						"\red You finish repositioning flesh and nerve endings where your [S.display_name] used to be with [src]!")

				if(H == user && prob(25))
					user << "\red You slip!"
					S.take_damage(15)

				S.open = 3
				M.updatehealth()
				M.UpdateDamageIcon()

				return 1

	if(user.zone_sel.selecting == "chest")
		if(istype(M, /mob/living/carbon/human))
			switch(M:embryo_op_stage)
				if(2.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] retracts the flap in [M]'s cut-open torso with [src].", 1)
						M << "\red [user] begins to retracts the flap in your chest with [src]!"
						user << "\red You retract the flap in [M]'s torso with [src]!"
						M:embryo_op_stage = 3.0
						return
				if(4.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] rips the larva out of [M]'s torso!", 1)
						M << "\red [user] begins to rip the larva out of [M]'s torso!"
						user << "\red You rip the larva out of [M]'s torso!"
						var/mob/living/carbon/alien/larva/stupid = new(M.loc)
						stupid.death(0)
						//Make a larva and kill it. -- SkyMarshal
						M:embryo_op_stage = 5.0
						for(var/datum/disease/alien_embryo in M.viruses)
							alien_embryo.cure()
						return

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
				if(2.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] retracts the flap in [M]'s abdomen cut open with [src].", 1)
						M << "\red [user] begins to retract the flap in your abdomen with [src]!"
						user << "\red You retract the flap in [M]'s abdomen with [src]!"
						M:appendix_op_stage = 3.0
						return

	if (user.zone_sel.selecting == "eyes")

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove whatever is covering the patient's face first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove whatever is covering the patient's face first."
			return

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M.eye_op_stage)
			if(1.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] is having \his eyes retracted by [user].", 1)
					M << "\red [user] begins to seperate your eyes with [src]!"
					user << "\red You seperate [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to have \his eyes retracted.", \
						"\red You begin to pry open your eyes with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You slip!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)

				M:eye_op_stage = 2.0
				return

	if(user.zone_sel.selecting == "mouth")

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove whatever is covering the patient's face first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove whatever is covering the patient's face first."
			return

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M:face_op_stage)
			if(2.0)
				if(M != user)
					M.visible_message( \
						"\red [user] is beginning to retract the skin on [M]'s face and neck with [src].", \
						"\red [user] begins to retract the flap on your face and neck with [src]!")
				else
					M.visible_message( \
						"\red [user] begins to retract the skin on their face and neck with [src]!", \
						"\red You begin to retract the skin on your face and neck with [src]!")

				if(do_mob(user, M, 60))
					if(M != user)
						M.visible_message( \
							"\red [user] retracts the skin on [M]'s face and neck with [src]!", \
							"\red [user] retracts the skin on your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] retracts the skin on their face and neck with [src]!", \
							"\red You retract the skin on your face and neck with [src]!")

					if(M == user && prob(25))
						user << "\red You slip!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
					M.face_op_stage = 3.0

				M.updatehealth()
				M.UpdateDamageIcon()
				return
			if(4.0)
				if(M != user)
					M.visible_message( \
						"\red [user] is beginning to pull skin back into place on [M]'s face with [src].", \
						"\red [user] begins to pull skin back into place on your face with [src]!")
				else
					M.visible_message( \
						"\red [user] begins to pull skin back into place on their face with [src]!", \
						"\red You begin to pull skin back into place on your face with [src]!")

				if(do_mob(user, M, 90))
					if(M != user)
						M.visible_message( \
							"\red [user] pulls the skin back into place on [M]'s face with [src]!", \
							"\red [user] pulls the skin back into place on your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] pulls the skin back into place on their face and neck with [src]!", \
							"\red You pull the skin back into place on your face and neck with [src]!")

					if(M == user && prob(25))
						user << "\red You slip!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
					M.face_op_stage = 5.0

				M.updatehealth()
				M.UpdateDamageIcon()
				return

// Retractor Bone Surgery
	// bone surgery doable?
	if(!try_bone_surgery(M, user))
		return ..()

/obj/item/weapon/retractor/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if(!S || !istype(S))
		return 0

	if(S.destroyed)
		return ..()

	if(S.robot)
		user << "The robot's structure is too tough for this tool."
		return

	if(!S.open)
		user << "\red There is skin in the way!"
		return 0
	if(S.bleeding)
		user << "\red [H] is profusely bleeding in \his [S.display_name]!"
		return 0

	if(H != user)
		H.visible_message( \
			"\red [user] is beginning to retract the flap in the wound in [H]'s [S.display_name] with [src].", \
			"\red [user] begins to retract the flap in the wound in your [S.display_name] with [src]!")
	else
		H.visible_message( \
			"\red [user] begins to retract the flap in the wound in \his [S.display_name] with [src]!", \
			"\red You begin to retract the flap in the wound in your [S.display_name] with [src]!")

	if(do_mob(user, H, 30))
		if(H != user)
			H.visible_message( \
				"\red [user] retracts the flap in the wound in [H]'s [S.display_name] with [src]!", \
				"\red [user] retracts the flap in the wound in your [S.display_name] with [src]!")
		else
			H.visible_message( \
				"\red [user] retracts the flap in the wound in \his [S.display_name] with [src]!", \
				"\red You retract the flap in the wound in your [S.display_name] with [src]!")

		if(H == user && prob(25))
			user << "\red You slip!"
			S.take_damage(15)

		S.open = 2

		H.updatehealth()
		H.UpdateDamageIcon()

	return 1
