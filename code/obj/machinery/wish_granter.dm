/obj/machinery/wish_granter
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = 1
	density = 1

	var
		charges = 1
		insisting = 0

/obj/machinery/wish_granter/attack_hand(var/mob/user as mob)
	usr.machine = src

	if(charges <= 0)
		user << "The Wish Granter lies silent."
		return

	else if(!istype(user, /mob/living/carbon/human))
		user << "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's."
		return

	else if(is_special_character(user))
		user << "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away."

	else if (!insisting)
		user << "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?"
		insisting++

	else
		user << "You speak.  [pick("I want the station to disappear","Humanity is corrupt, mankind must be destroyed","I want to be rich", "I want to rule the world","I want immortality.")].  The Wish Granter answers."
		user << "Your head pounds for a moment, before your vision clears.  You are the avatar of the Wish Granter, and your power is LIMITLESS!  And it's all yours.  You need to make sure no one can take it from you.  No one can know, first."

		charges--
		insisting = 0

		if (!(user.mutations & HULK))
			user.mutations |= HULK

		if (!(user.mutations & LASER))
			user.mutations |= LASER

		if (!(user.mutations & XRAY))
			user.mutations |= XRAY
			user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			user.see_in_dark = 8
			user.see_invisible = 2

		if (!(user.mutations & COLD_RESISTANCE))
			user.mutations |= COLD_RESISTANCE

		if (!(user.mutations & TK))
			user.mutations |= TK

		if(!(user.mutations & HEAL))
			user.mutations |= HEAL

		ticker.mode.traitors += user.mind
		user.mind.special_role = "Avatar of the Wish Granter"

		var/datum/objective/silence/silence = new
		silence.owner = user.mind
		user.mind.objectives += silence

		var/obj_count = 1
		for(var/datum/objective/OBJ in user.mind.objectives)
			user << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
			obj_count++

		world << "You have a very bad feeling about this."

	return

