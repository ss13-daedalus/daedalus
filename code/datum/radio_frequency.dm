datum/radio_frequency
	var/frequency as num
	var/list/list/obj/devices = list()

	proc
		post_signal(obj/source as obj|null, datum/signal/signal, var/filter = null as text|null, var/range = null as num|null)
			//log_admin("DEBUG \[[world.timeofday]\]: post_signal {source=\"[source]\", [signal.debug_print()], filter=[filter]}")
//			var/N_f=0
//			var/N_nf=0
//			var/Nt=0
			var/turf/start_point
			if(range)
				start_point = get_turf(source)
				if(!start_point)
					del(signal)
					return 0
			if (filter) //here goes some copypasta. It is for optimisation. -rastaf0
				for(var/obj/device in devices[filter])
					if(device == source)
						continue
					if(range)
						var/turf/end_point = get_turf(device)
						if(!end_point)
							continue
						//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
						if(start_point.z!=end_point.z || get_dist(start_point, end_point) > range)
							continue
					device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
				for(var/obj/device in devices["_default"])
					if(device == source)
						continue
					if(range)
						var/turf/end_point = get_turf(device)
						if(!end_point)
							continue
						//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
						if(start_point.z!=end_point.z || get_dist(start_point, end_point) > range)
							continue
					device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
//					N_f++
			else
				for (var/next_filter in devices)
//					var/list/obj/DDD = devices[next_filter]
//					Nt+=DDD.len
					for(var/obj/device in devices[next_filter])
						if(device == source)
							continue
						if(range)
							var/turf/end_point = get_turf(device)
							if(!end_point)
								continue
							//if(max(abs(start_point.x-end_point.x), abs(start_point.y-end_point.y)) <= range)
							if(start_point.z!=end_point.z || get_dist(start_point, end_point) > range)
								continue
						device.receive_signal(signal, TRANSMISSION_RADIO, frequency)
//						N_nf++

//			log_admin("DEBUG: post_signal(source=[source] ([source.x], [source.y], [source.z]),filter=[filter]) frequency=[frequency], N_f=[N_f], N_nf=[N_nf]")


			del(signal)

		add_listener(obj/device as obj, var/filter as text|null)
			if (!filter)
				filter = "_default"
			//log_admin("add_listener(device=[device],filter=[filter]) frequency=[frequency]")
			var/list/obj/devices_line = devices[filter]
			if (!devices_line)
				devices_line = new
				devices[filter] = devices_line
			devices_line+=device
//			var/list/obj/devices_line___ = devices[filter_str]
//			var/l = devices_line___.len
			//log_admin("DEBUG: devices_line.len=[devices_line.len]")
			//log_admin("DEBUG: devices(filter_str).len=[l]")

		remove_listener(obj/device)
			for (var/devices_filter in devices)
				var/list/devices_line = devices[devices_filter]
				devices_line-=device
				while (null in devices_line)
					devices_line -= null
				if (devices_line.len==0)
					devices -= devices_filter
					del(devices_line)


