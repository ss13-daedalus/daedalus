/datum/event
	var/listener
	var/proc_name

	New(tlistener,tprocname)
		listener = tlistener
		proc_name = tprocname
		return ..()

	proc/Fire()
		//world << "Event fired"
		if(listener)
			call(listener,proc_name)(arglist(args))
			return 1
		return
