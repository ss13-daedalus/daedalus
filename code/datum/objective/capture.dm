datum/objective/capture
	var/separation_time = 0
	var/almost_complete = 0

	New(var/text,var/joba,var/datum/mind/targeta)
		target = targeta
		job = joba
		explanation_text = "Capture [target.current.real_name], the [target.assigned_role]."

	check_completion()
		if(target && target.current)
			if(target.current.stat == 2)
				if(config.require_heads_alive) return 0
			else
				if(!target.current.handcuffed)
					return 0
		else if(config.require_heads_alive) return 0
		return 1

	find_target_by_role(var/role)
		for(var/datum/mind/possible_target in ticker.minds)
			if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human) && (possible_target.assigned_role == role))
				target = possible_target
				break

		if(target && target.current)
			explanation_text = "Capture [target.current.real_name], the [target.assigned_role]."
		else
			explanation_text = "Free Objective"

		return target

	get_points()
		if(target)
			var/difficulty = GetRank(target.assigned_role) + 1
			switch(GetRank(job))
				if(4)
					return 20*difficulty
				if(3)
					return 30*difficulty
				if(2)
					return 40*difficulty
				if(1)
					return 55*difficulty
				if(0)
					return 60*difficulty
		else
			return INFINITY

	get_weight()
		if(target)
			return 1
		return 0

datum/objective/capture
	var/target_amount
	proc/gen_amount_goal()
		target_amount = rand(5,10)
		explanation_text = "Accumulate [target_amount] capture points."
		return target_amount


	check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
		var/captured_amount = 0
		var/area/centcom/holding/A = locate()
		for(var/mob/living/carbon/human/M in A)//Humans.
			if(M.stat==2)//Dead folks are worth less.
				captured_amount+=0.5
				continue
			captured_amount+=1
		for(var/mob/living/carbon/monkey/M in A)//Monkeys are almost worthless, you failure.
			captured_amount+=0.1
		for(var/mob/living/carbon/alien/larva/M in A)//Larva are important for research.
			if(M.stat==2)
				captured_amount+=0.5
				continue
			captured_amount+=1
		for(var/mob/living/carbon/alien/humanoid/M in A)//Aliens are worth twice as much as humans.
			if(istype(M, /mob/living/carbon/alien/humanoid/queen))//Queens are worth three times as much as humans.
				if(M.stat==2)
					captured_amount+=1.5
				else
					captured_amount+=3
				continue
			if(M.stat==2)
				captured_amount+=1
				continue
			captured_amount+=2
		if(captured_amount<target_amount)
			return 0
		return 1


