///////////
//Cautery//
///////////

/obj/item/weapon/cautery/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
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
			if(S.open != 3)
				user << "\red The wound hasn't been prepared yet!"
				return 0
			if(M != user)
				M.visible_message( \
					"\red [user] is adjusting the area around [H]'s [S.display_name] for reattachment with [src].", \
					"\red [user] is adjusting the area around your [S.display_name] for reattachment with [src]!")
			else
				M.visible_message( \
					"\red [user] begins adjusting the area around \his [S.display_name] for reattachment with [src]!", \
					"\red You begin adjusting the area around your [S.display_name] for reattachment with [src]!")

			if(do_mob(user, H, 100))
				if(M != user)
					M.visible_message( \
						"\red [user] finishes adjusting the area around [H]'s [S.display_name]!", \
						"\red [user] finishes adjusting the area around your [S.display_name]!")
				else
					M.visible_message( \
						"\red [user] finishes adjusting the area around \his [S.display_name]!", \
						"\red You finish adjusting the area around your [S.display_name]!")

				if(H == user && prob(25))
					user << "\red You mess up!"
					S.take_damage(15)

				S.open = 0
				S.stage = 0
				S.attachable = 1
				M.updatehealth()
				M.UpdateDamageIcon()

			return 1

	if(user.zone_sel.selecting == "chest")
		if(istype(M, /mob/living/carbon/human))
			if(M:embryo_op_stage == 6.0 || M:embryo_op_stage ==  3.0 || M:embryo_op_stage ==  7.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [user] is beginning to cauterize the incision in [M]'s torso with [src].", 1)
					M << "\red [user] begins to cauterize the incision in your torso with [src]!"
					user << "\red You cauterize the incision in [M]'s torso with [src]!"
					M:embryo_op_stage = 0.0
					return

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
				if(5.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [user] is beginning to cauterize the incision in [M]'s abdomen with [src].", 1)
						M << "\red [user] begins to cauterize the incision in your abdomen with [src]!"
						user << "\red You cauterize the incision in [M]'s abdomen with [src]!"
						M:appendix_op_stage = 6.0
						for(var/datum/disease/appendicitis/appendicitis in M.viruses)
							appendicitis.cure()
							M.resistances += appendicitis
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
			if(3.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] is having \his eyes cauterized by [user].", 1)
					M << "\red [user] begins to cauterize your eyes!"
					user << "\red You cauterize [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to have \his eyes cauterized.", \
						"\red You begin to cauterize your eyes!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
						M.updatehealth()
					else
						M.take_organ_damage(15)
				M.disabilities &= ~128
				M.eye_stat = 0
				M:eye_op_stage = 0.0
				return

	if (user.zone_sel.selecting == "mouth")


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

		switch(M.face_op_stage)
			if(5.0)
				if(M != user)
					M.visible_message( \
						"\red [user] is beginning is cauterize [M]'s face and neck with [src].", \
						"\red [user] begins cauterize your face and neck with [src]!")
				else
					M.visible_message( \
						"\red [user] begins to cauterize their face and neck with [src]!", \
						"\red You begin to cauterize your face and neck with [src]!")

				if(do_mob(user, M, 50))
					if(M != user)
						M.visible_message( \
							"\red [user] cauterizes [M]'s face and neck with [src]!", \
							"\red [user] cauterizes your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] cauterizes their face and neck with [src]!", \
							"\red You cauterize your face and neck with [src]!")

					if(M == user && prob(25))
						user << "\red You mess up!"
						if(istype(M, /mob/living/carbon/human))
							var/datum/organ/external/affecting = M:get_organ("head")
							affecting.take_damage(15)
							M.updatehealth()
						else
							M.take_organ_damage(15)

					for(var/datum/organ/external/head/head)
						if(head && head.disfigured)
							head.disfigured = 0
					M.real_name = "[M.original_name]"
					M.name = "[M.original_name]"
					M << "\blue Your face feels better."
					M.warn_flavor_changed()
					M:face_op_stage = 0.0
					M.updatehealth()
					M.UpdateDamageIcon()
					return

//Cautery Bone Surgery

	if(!try_bone_surgery(M, user))
		return ..()

/obj/item/weapon/cautery/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
	if(!istype(H))
		return 0
	var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
	if(!S || !istype(S))
		return 0

	if(S.destroyed)
		user << "What [S.display_name]?"

	if(S.robot)
		user << "Medical equipment for a robot arm?  How would that do any good..."
		return
	if(!S.open)
		user << "\red There is no wound to close up!"
		return 0

	if(H != user)
		H.visible_message( \
			"\red [user] is beginning to cauterize the incision in [H]'s [S.display_name] with [src].", \
			"\red [user] begins to cut open the wound in your [S.display_name] with [src]!")
	else
		H.visible_message( \
			"\red [user] begins to cauterize the incision in \his [S.display_name] with [src]!", \
			"\red You begin to cauterize the incision in your [S.display_name] with [src]!")

	if(do_mob(user, H, rand(70,100)))
		if(H != user)
			H.visible_message( \
				"\red [user] cauterizes the incision in [H]'s [S.display_name] with [src]!", \
				"\red [user] cauterizes the incision in your [S.display_name] with [src]!")
		else
			H.visible_message( \
				"\red [user] cauterizes the incision in \his [S.display_name] with [src]!", \
				"\red You cauterize the incision in your [S.display_name] with [src]!")

		if(H == user && prob(25))
			user << "\red You mess up!"
			S.take_damage(15)

		S.open = 0
		if(S.display_name == "chest" && H:embryo_op_stage == 1.0)
			H:embryo_op_stage = 0.0
		if(S.display_name == "groin" && H:appendix_op_stage == 1.0)
			H:appendix_op_stage = 0.0

		H.updatehealth()
		H.UpdateDamageIcon()

	return 1
