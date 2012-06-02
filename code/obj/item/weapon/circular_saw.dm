////////////////
//CIRCULAR SAW//
////////////////

/obj/item/weapon/circular_saw/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))
		return ..()

	if((user.mutations & CLUMSY) && prob(50))
		M = user
		return eyestab(M,user)

	if(!((locate(/obj/machinery/optable, M.loc) && M.resting) || (locate(/obj/structure/stool/bed/roller, M.loc) && (M.buckled || M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat)) && prob(75) || (locate(/obj/structure/table/, M.loc) && (M.lying || M.weakened || M.stunned || M.paralysis || M.sleeping || M.stat) && prob(66))))
		return ..()

	src.add_fingerprint(user)

	if(user.zone_sel.selecting == "head" || istype(M, /mob/living/carbon/metroid))

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

		switch(M:brain_op_stage)
			if(0)
				if(!hasorgans(M))
					return ..()
				var/datum/organ/external/S = M:organs["head"]
				if(S.destroyed)
					return
				for(var/mob/O in viewers(M, null))
					O.show_message(text("\red [M] gets \his [S.display_name] sawed at with [src] by [user].... It looks like [user] is trying to cut it off!"), 1)
				if(!do_after(user,rand(50,70)))
					for(var/mob/O in viewers(M, null))
						O.show_message(text("\red [user] tried to cut [M]'s [S.display_name] off with [src], but failed."), 1)
					return
				for(var/mob/O in viewers(M, null))
					O.show_message(text("\red [M] gets \his [S.display_name] sawed off with [src] by [user]."), 1)
				S.destroyed = 1
				S.droplimb()
				M:update_body()
			if(1.0)
				if(istype(M, /mob/living/carbon/metroid))
					return
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his skull sawed open with [src] by [user].", 1)
					M << "\red [user] begins to saw open your head with [src]!"
					user << "\red You saw [M]'s head open with [src]!"
				else
					user.visible_message( \
						"\red [user] saws open \his skull with [src]!", \
						"\red You begin to saw open your head with [src]!" \
					)
				if(M == user && prob(25))
					user << "\red You mess up!"
					if(istype(M, /mob/living/carbon/human))
						var/datum/organ/external/affecting = M:get_organ("head")
						affecting.take_damage(40)
						M.updatehealth()
					else
						M.take_organ_damage(40)

				if(istype(M, /mob/living/carbon/human))
					var/datum/organ/external/affecting = M:get_organ("head")
					affecting.take_damage(7)
				else
					M.take_organ_damage(7)

				M.updatehealth()
				M:brain_op_stage = 2.0

			if(2.0)
				if(istype(M, /mob/living/carbon/metroid))
					if(M.stat == 2)
						var/mob/living/carbon/metroid/Metroid = M
						if(Metroid.cores > 0)
							for(var/mob/O in (viewers(M) - user - M))
								O.show_message("\red [M.name] is having one of its cores sawed out with [src] by [user].", 1)

							Metroid.cores--
							M << "\red [user] begins to remove one of your cores with [src]! ([Metroid.cores] cores remaining)"
							user << "\red You cut one of [M]'s cores out with [src]! ([Metroid.cores] cores remaining)"

							new/obj/item/metroid_core(M.loc)

							if(Metroid.cores <= 0)
								M.icon_state = "baby metroid dead-nocore"

					return

			if(3.0)
				if(M != user)
					for(var/mob/O in (viewers(M) - user - M))
						O.show_message("\red [M] has \his spine's connection to the brain severed with [src] by [user].", 1)
					M << "\red [user] severs your brain's connection to the spine with [src]!"
					user << "\red You sever [M]'s brain's connection to the spine with [src]!"
				else
					user.visible_message( \
						"\red [user] severs \his brain's connection to the spine with [src]!", \
						"\red You sever your brain's connection to the spine with [src]!" \
						)

				user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
				M.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"

				log_admin("ATTACK: [user] ([user.ckey]) debrained [M] ([M.ckey]) with [src].")
				message_admins("ATTACK: [user] ([user.ckey]) debrained [M] ([M.ckey]) with [src].")
				log_attack("<font color='red'>[user.name] ([user.ckey]) debrained [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")


				var/obj/item/brain/B = new(M.loc)
				B.transfer_identity(M)

				M:brain_op_stage = 4.0
				M.death()//You want them to die after the brain was transferred, so not to trigger client death() twice.

			else
				..()
		return

	else if(user.zone_sel.selecting != "chest" && hasorgans(M))
		var/mob/living/carbon/H = M
		var/datum/organ/external/S = H:organs[user.zone_sel.selecting]
		if(S.destroyed)
			return

		if(S.robot)
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, M)
			spark_system.attach(M)
			spark_system.start()
			spawn(10)
				del(spark_system)
		for(var/mob/O in viewers(H, null))
			O.show_message(text("\red [H] gets \his [S.display_name] sawed at with [src] by [user]... It looks like [user] is trying to cut it off!"), 1)
		if(!do_after(user, rand(20,80)))
			for(var/mob/O in viewers(H, null))
				O.show_message(text("\red [user] tried to cut [H]'s [S.display_name] off with [src], but failed."), 1)
			return
		for(var/mob/O in viewers(H, null))
			O.show_message(text("\red [H] gets \his [S.display_name] sawed off with [src] by [user]."), 1)
		S.droplimb(1)
		H:update_body()
	else
		return ..()
/*
	else if((!(user.zone_sel.selecting == "head")) || (!(user.zone_sel.selecting == "groin")) || (!(istype(M, /mob/living/carbon/human))))
		return ..()
*/
	return
