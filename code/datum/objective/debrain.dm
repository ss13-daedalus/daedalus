datum/objective/debrain//I want braaaainssss
	New(var/text,var/joba,var/datum/mind/targeta)
		target = targeta
		job = joba
		explanation_text = "Remove and recover the brain of [target.current.real_name], the [target.assigned_role]."

	proc/find_target()
		..()
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Steal the brain of [target.current.real_name] the [target.role_alt_title ? target.role_alt_title : (!role_type ? target.assigned_role : target.special_role)]."
		else
			explanation_text = "Free Objective"
		return target


	check_completion()
		if(!target)//If it's a free objective.
			return 1
		if(!owner.current||owner.current.stat==2)//If you're otherwise dead.
			return 0
		var/list/all_items = owner.current.get_contents()
		for(var/obj/item/device/mmi/mmi in all_items)
			if(mmi.brainmob&&mmi.brainmob.mind==target)	return 1
		for(var/obj/item/brain/brain in all_items)
			if(brain.brainmob&&brain.brainmob.mind==target)	return 1
		return 0

