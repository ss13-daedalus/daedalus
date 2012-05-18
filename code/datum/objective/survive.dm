datum/objective/survive
	explanation_text = "Stay alive."

	check_completion()
		if(!owner.current || owner.current.stat == 2)
			return 0

		return 1
	get_points()
		return INFINITY

	get_weight(var/job)
		return 1

