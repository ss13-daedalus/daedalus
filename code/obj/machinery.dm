/obj/machinery/proc/state(var/msg)
	for(var/mob/O in hearers(src, null))
		O.show_message("\icon[src] \blue [msg]", 2)
