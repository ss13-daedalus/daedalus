

/* NOTES:

This system could be expanded to migrate all of our current mutations to. Maybe.


*/


/* /datum/mutations :
 *
 *		A /datum representation of "hidden" mutations.
 *
 */
/datum/mutations

	var/list/requirements = list() // list of randomly-genned requirements
	var/required = 1 // the number of requirements to generate

	var/list/races = list("human") // list of races the mutation effect

	proc/get_mutation(var/mob/living/carbon/M) // Called when check_mutation() is successful
		..()

	proc/check_mutation(var/mob/living/carbon/M) // Called in dna.dm, when a target's SE is modified

		if(! ("all" in races)) // "all" means it affects everyone!
			if(istype(M, /mob/living/carbon/human))
				if(! ("human" in races))
					return
			if(istype(M, /mob/living/carbon/monkey))
				if(! ("monkey" in races))
					return
			// TODO: add more races maybe??


		var/passes = 0
		for(var/datum/mutationreq/require in requirements)

			var/se_block[] = getblockbuffer(M.dna.struc_enzymes, require.block, 3) // focus onto the block
			if(se_block.len == 3) // we want to make sure there are exactly 3 entries

				if(se_block[require.subblock] == require.reqID)

					passes++

		if(passes == required) // all requirements met
			get_mutation(M)


	Lasereyes
		/*
		 	Lets you shoot laser beams through your eyes. Fancy!
		 */
		required = 2

		get_mutation(var/mob/living/carbon/M)
			M << "\blue You feel a searing heat inside your eyes!"
			M.mutations |= LASER

	Healing
		/*
			Lets you heal other people, and yourself. But it doesn't let you heal dead people.
		*/
		required = 2

		get_mutation(var/mob/living/carbon/M)
			M << "\blue You a pleasant warmth pulse throughout your body..."
			M.mutations |= HEAL

/* /datum/mutationreq :
 *
 *		A /datum representation of a requirement in order for a mutation to happen.
 *
 */

