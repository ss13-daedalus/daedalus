/obj/effect/spacevine_controller
	var/list/obj/effect/spacevine/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the spacevines' size to something less than 20 plots, it won't grow anymore.

	New()
		if(!istype(src.loc,/turf/simulated/floor))
			del(src)

		spawn_spacevine_piece(src.loc)
		processing_objects.Add(src)

	Del()
		processing_objects.Remove(src)
		..()

	proc/spawn_spacevine_piece(var/turf/location)
		var/obj/effect/spacevine/SV = new(location)
		growth_queue += SV
		vines += SV
		SV.master = src

	process()
		if(!vines)
			del(src) //space  vines exterminated. Remove the controller
			return
		if(!growth_queue)
			del(src) //Sanity check
			return
		if(vines.len >= 250 && !reached_collapse_size)
			reached_collapse_size = 1
		if(vines.len >= 30 && !reached_slowdown_size )
			reached_slowdown_size = 1

		var/length = 0
		if(reached_collapse_size)
			length = 0
		else if(reached_slowdown_size)
			if(prob(25))
				length = 1
			else
				length = 0
		else
			length = 1
		length = min( 30 , max( length , vines.len / 5 ) )
		var/i = 0
		var/list/obj/effect/spacevine/queue_end = list()

		for( var/obj/effect/spacevine/SV in growth_queue )
			i++
			queue_end += SV
			growth_queue -= SV
			if(SV.energy < 2) //If tile isn't fully grown
				if(prob(20))
					SV.grow()
			else //If tile is fully grown
				SV.grab()

			//if(prob(25))
			SV.spread()
			if(i >= length)
				break

		growth_queue = growth_queue + queue_end
		//sleep(5)
		//src.process()

