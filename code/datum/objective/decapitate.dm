datum/objective/decapitate
	New(var/text,var/joba,var/datum/mind/targeta)
		target = targeta
		job = joba
		explanation_text = "Remove and recover the head of [target.current.real_name], the [target.assigned_role]."
	proc/find_target()
		..()
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role], has defied us for the last time.  Make an example of him, and bring us his severed head."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "[target.current.real_name], the [target.role_alt_title ? target.role_alt_title : (!role_type ? target.assigned_role : target.special_role)], has defied us for the last time.  Make an example of him, and bring us his severed head."
		else
			explanation_text = "Free Objective"
		return target


	check_completion()
		if(target && target.current)
			if(!owner.current||owner.current.stat==2)//If you're otherwise dead.
				return 0
			var/list/all_items = owner.current.get_contents()
			for(var/obj/item/weapon/organ/head/mmi in all_items)
				if(mmi.brainmob&&mmi.brainmob.mind==target)
					return 1
			return 0
		else
			return 1

