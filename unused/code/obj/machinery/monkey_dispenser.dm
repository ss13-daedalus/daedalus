/obj/machinery/monkey_dispenser
	name = "Monkey dispenser"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_0"
	density = 1
	anchored = 1

	var/cloning = 0

/obj/machinery/monkey_dispenser/attack_hand()
	if(!cloning)
		cloning = 150

		icon_state = "pod_g"

/obj/machinery/monkey_dispenser/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)
	//src.updateDialog()

	if(cloning)
		cloning -= 1
		if(!cloning)
			new /mob/living/carbon/monkey(src.loc)
			icon_state = "pod_0"



	return
