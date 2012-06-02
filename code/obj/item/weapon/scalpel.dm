///////////
//SCALPEL//
///////////
/obj/item/weapon/scalpel/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	//if(M.mutations & HUSK)	return ..()

	if((user.mutations & CLUMSY) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	src.add_fingerprint(user)

	if(((user.zone_sel.selecting == "l_arm") || (user.zone_sel.selecting == "r_arm") || (user.zone_sel.selecting == "l_leg") || (user.zone_sel.selecting == "r_leg")) & (istype(M, /mob/living/carbon/human)))
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/S = H.organs[user.zone_sel.selecting]
		if(S.destroyed)
			if(M != user)
				M.visible_message( \
					"\red [user] is beginning to cut away at the flesh where [H]'s [S.display_name] used to be with [src].", \
					"\red [user] begins to cut away at the flesh where [S.display_name] used to be with [src]!")
			else
				M.visible_message( \
					"\red [user] begins to cut away at the flesh where \his [S.display_name]  used to be with [src]!", \
					"\red You begin to cut away at the flesh where your [S.display_name] used to be with [src]!")

			if(do_mob(user, H, 100))
				if(M != user)
					M.visible_message( \
						"\red [user] finishes cutting where [H]'s [S.display_name] used to be with [src]!", \
						"\red [user] finishes cutting where your [S.display_name] used to be with [src]!")
				else
					M.visible_message( \
						"\red [user] finishes cutting where \his [S.display_name] used to be with [src]!", \
						"\red You finish cutting where your [S.display_name] used to be with [src]!")

				S.cutaway = 1
				S.bleeding = 1
				M.updatehealth()
				M.UpdateDamageIcon()
			else
				var/a = pick(1,2,3)
				var/msg
				if(a == 1)
					msg = "\red [user]'s move slices open [H]'s wound, causing massive bleeding"
					S.brute_dam += 35
					S.createwound(rand(1,3))
				else if(a == 2)
					msg = "\red [user]'s move slices open [H]'s wound, and causes \him to accidentally stab himself"
					S.brute_dam += 35
					var/datum/organ/external/userorgan = user:organs["chest"]
					if(userorgan)
						userorgan.brute_dam += 35
					else
						user.take_organ_damage(35)
				else if(a == 3)
					msg = "\red [user] quickly stops the surgery"
				for(var/mob/O in viewers(H))
					O.show_message(msg, 1)

	if(user.zone_sel.selecting == "chest")
		if(istype(M, /mob/living/carbon/human))
			switch(M:embryo_op_stage)
//				if(0.0)
//					if(M != user)
//						for(var/mob/O in (viewers(M) - user - M))
//							O.show_message("\red [M] is beginning to have \his torso cut open with [src] by [user].", 1)
//						M << "\red [user] begins to cut open your torso with [src]!"
//						user << "\red You cut [M]'s torso open with [src]!"
//						M:embryo_op_stage = 1.0
//						return
				if(3.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M] has \his stomach cut open with [src] by [user].", 1)
						M << "\red [user] cuts open your stomach with [src]!"
						user << "\red You cut [M]'s stomach open with [src]!"
						for(var/datum/disease/D in M.viruses)
							if(istype(D, /datum/disease/alien_embryo))
								user << "\blue There's something wiggling in there!"
								M:embryo_op_stage = 4.0
						if(M:embryo_op_stage == 3.0)
							M:embryo_op_stage = 7.0 //Make it not cut their stomach open again and again if no larvae.
						return

	if(user.zone_sel.selecting == "groin")
		if(istype(M, /mob/living/carbon/human))
			switch(M:appendix_op_stage)
//				if(0.0)
//					if(M != user)
//						for(var/mob/O in (viewers(M) - user - M))
//							O.show_message("\red [M] is beginning to have \his abdomen cut open with [src] by [user].", 1)
//						M << "\red [user] begins to cut open your abdomen with [src]!"
//						user << "\red You cut [M]'s abdomen open with [src]!"
//						M:appendix_op_stage = 1.0
				if(3.0)
					if(M != user)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M] has \his appendix seperated with [src] by [user].", 1)
						M << "\red [user] seperates your appendix with [src]!"
						user << "\red You seperate [M]'s appendix with [src]!"
						M:appendix_op_stage = 4.0
						return

	if(user.zone_sel.selecting == "head" || istype(M, /mob/living/carbon/metroid))

		var/mob/living/carbon/human/H = M

		if(istype(H) && H.organs["head"])
			var/datum/organ/external/affecting = H.organs["head"]
			if(affecting.destroyed)
				return ..()

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

		switch(M:brain_op_stage)
			if(0.0)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M.name] has its flesh cut open with [src] by [user].", 1)
						M << "\red [user] cuts open your flesh with [src]!"
						user << "\red You cut [M]'s flesh open with [src]!"
						M:brain_op_stage = 1.0

					return

				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his head cut open with [src] by [user].", 1)
					M << "\red [user] cuts open your head with [src]!"
					user << "\red You cut [M]'s head open with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to cuts open \his skull with [src]!", \
						"\red You begin to cut open your head with [src]!" \
					)

				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
					else
						M.take_organ_damage(15)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:get_organ("head")
					affecting.take_damage(7)
					affecting.open = 1
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 1.0
				return

			if(1)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						for(var/mob/O in (viewers(M) - user - M))
							O.show_message("\red [M.name] has its silky inndards cut apart with [src] by [user].", 1)
						M << "\red [user] cuts apart your innards with [src]!"
						user << "\red You cut [M]'s silky innards apart with [src]!"
						M:brain_op_stage = 2.0
					return
			if(2.0)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						var/mob/living/carbon/metroid/Metroid = M
						if(Metroid.cores > 0)
							if(istype(M, /mob/living/carbon/metroid))
								user << "\red You attempt to remove [M]'s core, but [src] is ineffective!"
					return

				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his connections to the brain delicately severed with [src] by [user].", 1)
					M << "\red [user] delicately severs your brain with [src]!"
					user << "\red You sever [M]'s brain with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to delicately remove the connections to \his brain with [src]!", \
						"\red You begin to cut open your head with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You nick an artery!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(75)
					else
						M.take_organ_damage(75)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:get_organ("head")
					affecting.take_damage(7)
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 3.0
			else
				..()
			return

	if(user.zone_sel.selecting == "eyes")

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

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N
			user << "\red You cannot locate any eyes on this creature!"
			return

		switch(M:eye_op_stage)
			if(0.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his eyes incised with [src] by [user].", 1)
					M << "\red [user] cuts open your eyes with [src]!"
					user << "\red You make an incision around [M]'s eyes with [src]!"
				else
					user.visible_message( \
						"\red [user] begins to cut around \his eyes with [src]!", \
						"\red You begin to cut open your eyes with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(15)
					else
						M.take_organ_damage(15)

				M.updatehealth()
				M:eye_op_stage = 1.0
				return

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

		if(istype(M, /mob/living/carbon/alien) || istype(M, /mob/living/carbon/metroid))//Aliens don't have eyes./N
			user << "\red You cannot locate any face on this creature!"
			return

		switch(M:face_op_stage)
			if(0.0)
				if(M != user)
					M.visible_message( \
						"\red [user] is beginning is cut open [M]'s face and neck with [src].", \
						"\red [user] begins to cut open your face and neck with [src]!")
				else
					M.visible_message( \
						"\red [user] begins to cut open their face and neck with [src]!", \
						"\red You begin to cut open your face and neck with [src]!")

				if(do_mob(user, M, 50))
					if(M != user)
						M.visible_message( \
							"\red [user] cuts open [M]'s face and neck with [src]!", \
							"\red [user] cuts open your face and neck with [src]!")
					else
						M.visible_message( \
							"\red [user] cuts open their face and neck with [src]!", \
							"\red You cut open your face and neck with [src]!")

					if(M == user && prob(25))
						user << "\red You mess up!"
						if(istype(M, /mob/living/carbon/human))
							var/datum/organ/external/affecting = M:get_organ("head")
							affecting.take_damage(15)
							M.updatehealth()
						else
							M.take_organ_damage(15)

					M.face_op_stage = 1.0

					M.updatehealth()
					M.UpdateDamageIcon()
					return

// Scalpel Bone Surgery

	if(!try_bone_surgery(M, user) && user.a_intent == "hurt") // if we call ..(), we'll attack them, so require a hurt intent
		return ..()
/* wat
	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()
*/
	return

/obj/item/weapon/scalpel/proc/try_bone_surgery(mob/living/carbon/human/H as mob, mob/living/user as mob)
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

	if(S.open)
		user << "\red The wound is already open!"
		return 0

	if(H != user)
		H.visible_message( \
			"\red [user] is beginning to cut open the wound in [H]'s [S.display_name] with [src].", \
			"\red [user] begins to cut open the wound in your [S.display_name] with [src]!")
	else
		H.visible_message( \
			"\red [user] begins to cut open the wound in \his [S.display_name] with [src]!", \
			"\red You begin to cut open the wound in your [S.display_name] with [src]!")

	if(do_mob(user, H, 100))
		if(H != user)
			H.visible_message( \
				"\red [user] cuts open the wound in [H]'s [S.display_name] with [src]!", \
				"\red [user] cuts open the wound in your [S.display_name] with [src]!")
		else
			H.visible_message( \
				"\red [user] cuts open the wound in \his [S.display_name] with [src]!", \
				"\red You cut open the wound in your [S.display_name] with [src]!")

		if(H == user && prob(25))
			user << "\red You mess up!"
			S.take_damage(15)

		S.open = 1
		S.bleeding = 1
		if(S.display_name == "chest")
			H:embryo_op_stage = 1.0
		if(S.display_name == "groin")
			H:appendix_op_stage = 1.0
		H.updatehealth()
		H.UpdateDamageIcon()
	else
		var/a = pick(1,2,3)
		var/msg
		if(a == 1)
			msg = "\red [user]'s move slices open [H]'s wound, causing massive bleeding"
			S.brute_dam += 35
			S.createwound(rand(1,3))
		else if(a == 2)
			msg = "\red [user]'s move slices open [H]'s wound, and causes \him to accidentally stab himself"
			S.brute_dam += 35
			var/datum/organ/external/userorgan = user:organs["chest"]
			if(userorgan)
				userorgan.brute_dam += 35
			else
				user.take_organ_damage(35)
		else if(a == 3)
			msg = "\red [user] quickly stops the surgery"
		for(var/mob/O in viewers(H))
			O.show_message(msg, 1)

	return 1
