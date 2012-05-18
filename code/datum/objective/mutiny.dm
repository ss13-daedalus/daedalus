datum/objective/mutiny
	proc/find_target()
		..()
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : target.assigned_role]."
		else
			explanation_text = "Free Objective"
		return target


	find_target_by_role(role, role_type=0)
		..(role, role_type)
		if(target && target.current)
			explanation_text = "Assassinate [target.current.real_name], the [target.role_alt_title ? target.role_alt_title : (!role_type ? target.assigned_role : target.special_role)]."
		else
			explanation_text = "Free Objective"
		return target


	check_completion()
		if(target && target.current)
			var/turf/T = get_turf(target.current)
			if(target.current.stat == 2)
				return 1
			else if((T) && (T.z != 1))//If they leave the station they count as dead for this
				return 2
			else
				return 0
		else
			return 1

