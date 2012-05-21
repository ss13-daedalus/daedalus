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
/datum/event

	var/Lifetime  = 0
	var/ActiveFor = 0

	New()
		..()
		if(!Lifetime)
			Lifetime = rand(30, 120)

	proc
		Announce()

		Tick()

		Die()

		LongTerm()
			LongTermEvent = ActiveEvent
			ActiveEvent = null
