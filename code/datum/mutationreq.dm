/datum/mutationreq
	var/block		// The block to read
	var/subblock	// The sub-block to read
	var/reqID		// The required hexadecimal identifier to be equal to the sub-block being read.




/*
HEY: If you want to be able to get superpowers easily just uncomment this shit.
mob/verb/checkmuts()
	for(var/datum/mutations/mut in global_mutations)

		for(var/datum/mutationreq/R in mut.requirements)
			src << "Block: [R.block]"
			src << "Sub-Block: [R.subblock]"
			src << "Required ID: [R.reqID]"
			src << ""

mob/verb/editSE(t as text)
	src:dna:struc_enzymes = t
	domutcheck(src)

*/

