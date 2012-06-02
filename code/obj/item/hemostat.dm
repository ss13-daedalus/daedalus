////////////
//Hemostat//
////////////

/obj/item/weapon/hemostat/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
		if(S.destroyed)
			if(!S.bleeding)
				user << "\red There is nothing bleeding here!"
				return 0
			if(!S.cutaway)
				user << "\red The flesh hasn't been cleanly cut!"
				return 0
			if(M != user)
				M.visible_message( \
					"\red [user] is beginning to clamp bleeders in the stump where [H]'s [S.display_name] used to be with [src].", \
					"\red [user] begins to clamp bleeders in the stump where [S.display_name] used to be with [src]!")
			else
				M.visible_message( \
					"\red [user] begins to clamp bleeders in the stump where \his [S.display_name]  used to be with [src]!", \
					"\red You begin to clamp bleeders in the stump where your [S.display_name] used to be with [src]!")

			if(do_mob(user, H, 100))
				if(M != user)
					M.visible_message( \
						"\red [user] finishes clamping bleeders in the stump where [H]'s [S.display_name] used to be with [src]!", \
						"\red [user] finishes clamping bleeders in the stump where your [S.display_name] used to be with [src]!")
				else
					M.visible_message( \
						"\red [user] finishes clamping bleeders in the stump where \his [S.display_name] used to be with [src]!", \
						"\red You finish clamping bleeders in the stump where your [S.display_name] used to be with [src]!")

				if(H == user && prob(25))
					user << "\red You slip!"
					S.take_damage(15)

				S.bleeding = 0
				M.updatehealth()
				M.UpdateDamageIcon()

			return 1

	if(user.zone_sel.selecting == "chest")
		if(istype(M, /mob/living/carbon/human))
			switch(M:embryo_op_stage)
				if(1.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is beginning to clamp bleeders in [M]'s cut-open torso with [src].", 1)
						M << "\red [user] begins to clamp bleeders in your chest with [src]!"
						user << "\red You clamp bleeders in [M]'s torso with [src]!"
						M:embryo_op_stage = 2.0
						return
				if(5.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] cleans out the debris from [M]'s cut open torso with [src].", 1)
						M << "\red [user] begins to clean out the debris in your torso with [src]!"
						user << "\red You clean out the debris from in [M]'s torso with [src]!"
						M:embryo_op_stage = 6.0
						return

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
				if(1.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is beginning to clamp bleeders in [M]'s abdomen cut open with [src].", 1)
						M << "\red [user] begins to clamp bleeders in your abdomen with [src]!"
						user << "\red You clamp bleeders in [M]'s abdomen with [src]!"
						M:appendix_op_stage = 2.0
						return
				if(4.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is removing [M]'s appendix with [src].", 1)
						M << "\red [user] begins to remove your appendix with [src]!"
						user << "\red You remove [M]'s appendix with [src]!"
						for(var/datum/disease/D in M.viruses)
							if(istype(D, /datum/disease/appendicitis))
								new /obj/item/weapon/appendixinflamed(get_turf(M))
								M:appendix_op_stage = 5.0
								return
						new /obj/item/weapon/appendix(get_turf(M))
						M:appendix_op_stage = 5.0
						return

	if (user.zone_sel.selecting == "eyes")

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M.eye_op_stage)
			if(2.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] is having \his eyes mended by [user].", 1)
					M << "\red [user] begins to mend your eyes with [src]!"
					user << "\red You mend [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to have \his eyes mended.", \
						"\red You begin to mend your eyes with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
				M:eye_op_stage = 3.0
				return
	if(user.zone_sel.selecting == "head")
		if(istype(M, /mob/living/carbon/human) && M:brain_op_stage == 1)
			M:brain_op_stage = 0
			var/datum/organ/external/S = M:organs["head"]
			if(!S || !istype(S))
				return ..()
			M:brain_op_stage = 0
			S.open = 1
			if(!try_bone_surgery(M, user))
				return ..()
		else
			return ..()

	if(user.zone_sel.selecting == "mouth")

		var/mob/living/carbon/human/H = M
		if(istype(H) && ( \
				(H.head && H.head.flags & HEADCOVERSEYES) || \
				(H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || \
				(H.glasses && H.glasses.flags & GLASSESCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		var/mob/living/carbon/monkey/Mo = M
		if(istype(Mo) && ( \
				(Mo.wear_mask && Mo.wear_mask.flags & MASKCOVERSEYES) \
			))
			user << "\red You're going to need to remove that mask/helmet/glasses first."
			return

		if(istype(M, /mob/living/carbon/alien))//Aliens don't have mouths either.
			user << "\red You cannot locate any mouth on this creature!"
			return

		if(istype(M, /mob/living/carbon/human))
			switch(M:face_op_stage)
				if(1.0)
					if(M != user)
						M.visible_message( \
							"\red [user] is beginning is beginning to clamp bleeders in [M]'s face and neck with [src].", \
							"\red [user] begins to clamp bleeders on your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] begins to clamp bleeders on their face and neck with [src]!", \
							"\red You begin to clamp bleeders on your face and neck with [src]!")

					if(do_mob(user, M, 50))
						if(M != user)
							M.visible_message( \
								"\red [user] stops the bleeding on [M]'s face and neck with [src]!", \
								"\red [user] stops the bleeding on your face and neck with [src]!")
						else
							M.visible_message( \
								"\red [user] stops the bleeding on their face and neck with [src]!", \
								"\red You stop the bleeding on your face and neck with [src]!")

						if(M == user && prob(25))
							user << "\red You mess up!"
							if(istype(M, /mob/living/carbon/human))
								var/datum/organ/external/affecting = M:get_organ("head")
								affecting.take_damage(15)
								M.updatehealth()
							else
								M.take_organ_damage(15)

						M.face_op_stage = 2.0

						M.updatehealth()
						M.UpdateDamageIcon()
						return
				if(3.0)
					if(M != user)
						M.visible_message( \
							"\red [user] is beginning to reshape [M]'s vocal chords and face with [src].", \
							"\red [user] begins to reshape your vocal chords and face [src]!")
					else
						M.visible_message( \
							"\red [user] begins to reshape their vocal chords and face and face with [src]!", \
							"\red You begin to reshape your vocal chords and face with [src]!")

					if(do_mob(user, M, 120))
						if(M != user)
							M.visible_message( \
								"\red Halfway there...", \
								"\red Halfway there...")
						else
							M.visible_message( \
								"\red Halfway there...", \
								"\red Halfway there...")

					if(do_mob(user, M, 120))
						if(M != user)
							M.visible_message( \
								"\red [user] reshapes [M]'s vocal chords and face with [src]!", \
								"\red [user] reshapes your vocal chords and face with [src]!")
						else
							M.visible_message( \
								"\red [user] reshapes their vocal chords and face with [src]!", \
								"\red You reshape your vocal chords and face with [src]!")

						if(M == user && prob(25))
							user << "\red You mess up!"
							if(istype(M, /mob/living/carbon/human))
								var/datum/organ/external/affecting = M:get_organ("head")
								affecting.take_damage(15)
								M.updatehealth()
							else
								M.take_organ_damage(15)

						M.face_op_stage = 4.0

						M.updatehealth()
						M.UpdateDamageIcon()
						return

// Hemostat Bone Surgery
	// bone surgery doable?
	if(!try_bone_surgery(M, user))
		return ..()


/obj/item/weapon/hemostat/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]

	if(!S || !istype(S))
		return 0

	if(S.destroyed)
		return ..()

	if(S.robot)
		user << "Medical equipment for a robot arm?  How would that do any good..."
		return

	if(!S.open)
		user << "\red There is skin in the way!"
		return 0

	if(!S.bleeding)
		user << "\red [H] is not bleeding in \his [S.display_name]!"
		return 0

	if(H != user)
		H.visible_message( \
			"\red [user] is beginning to clamp bleeders in the wound in [H]'s [S.display_name] with [src].", \
			"\red [user] begins to clamp bleeders in the wound in your [S.display_name] with [src]!")
	else
		H.visible_message( \
			"\red [user] begins to clamp bleeders in the wound in \his [S.display_name] with [src]!", \
			"\red You begin to clamp bleeders in the wound in your [S.display_name] with [src]!")

	if(do_mob(user, H, 50))
		if(H != user)
			H.visible_message( \
				"\red [user] clamps bleeders in the wound in [H]'s [S.display_name] with [src]!", \
				"\red [user] clamps bleeders in the wound in your [S.display_name] with [src]!")
		else
			H.visible_message( \
				"\red [user] clamps bleeders in the wound in \his [S.display_name] with [src]!", \
				"\red You clamp bleeders in the wound in your [S.display_name] with [src]!")

		if(H == user && prob(25))
			user << "\red You mess up!"
			S.take_damage(15)

		S.bleeding = 0

		H.updatehealth()
		H.UpdateDamageIcon()

	return 1
