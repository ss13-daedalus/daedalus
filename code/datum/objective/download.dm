datum/objective/download
	var/target_amount
	proc/gen_amount_goal()
		target_amount = rand(10,20)
		explanation_text = "Download [target_amount] research levels."
		return target_amount


	check_completion()
		if(!ishuman(owner.current))
			return 0
		if(!owner.current || owner.current.stat == 2)
			return 0
		if(!(istype(owner.current:wear_suit, /obj/item/clothing/suit/space/space_ninja)&&owner.current:wear_suit:s_initialized))
			return 0
		var/current_amount
		var/obj/item/clothing/suit/space/space_ninja/S = owner.current:wear_suit
		if(!S.stored_research.len)
			return 0
		else
			for(var/datum/tech/current_data in S.stored_research)
				if(current_data.level>1)	current_amount+=(current_data.level-1)
		if(current_amount<target_amount)	return 0
		return 1


