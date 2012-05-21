/obj/machinery/scan_consolenew/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/scan_consolenew/blob_act()

	if(prob(75))
		del(src)

/obj/machinery/scan_consolenew/power_change()
	if(stat & BROKEN)
		icon_state = "broken"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "c_unpowered"
			stat |= NOPOWER

