/obj/effect/beam/infrared
	name = "Infrared beam"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	var/obj/effect/beam/infrared/next = null
	var/obj/item/device/assembly/infrared_emitter/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
	anchored = 1.0
	flags = TABLEPASS


/obj/effect/beam/infrared/proc/hit()
	//world << "beam \ref[src]: hit"
	if(src.master)
		//world << "beam hit \ref[src]: calling master \ref[master].hit"
		src.master.trigger_beam()
	del(src)
	return

/obj/effect/beam/infrared/proc/vis_spread(v)
	//world << "infrared \ref[src] : vis_spread"
	src.visible = v
	spawn(0)
		if(src.next)
			//world << "infrared \ref[src] : is next [next.type] \ref[next], calling spread"
			src.next.vis_spread(v)
		return
	return

/obj/effect/beam/infrared/process()
	//world << "infrared \ref[src] : process"

	if((src.loc.density || !( src.master )))
		//SN src = null
	//	world << "beam hit loc [loc] or no master [master], deleting"
		del(src)
		return
	//world << "proccess: [src.left] left"

	if(src.left > 0)
		src.left--
	if(src.left < 1)
		if(!( src.visible ))
			src.invisibility = 101
		else
			src.invisibility = 0
	else
		src.invisibility = 0


	//world << "now [src.left] left"
	var/obj/effect/beam/infrared/I = new /obj/effect/beam/infrared( src.loc )
	I.master = src.master
	I.density = 1
	I.dir = src.dir
	//world << "created new beam \ref[I] at [I.x] [I.y] [I.z]"
	step(I, I.dir)

	if(I)
		//world << "step worked, now at [I.x] [I.y] [I.z]"
		if (!( src.next ))
			//world << "no src.next"
			I.density = 0
			//world << "spreading"
			I.vis_spread(src.visible)
			src.next = I
			spawn( 0 )
				//world << "limit = [src.limit] "
				if ((I && src.limit > 0))
					I.limit = src.limit - 1
					//world << "calling next process"
					I.process()
				return
		else
			//world << "is a next: \ref[next], deleting beam \ref[I]"
			del(I)
	else
		//world << "step failed, deleting \ref[src.next]"
		del(src.next)
	spawn(10)
		src.process()
		return
	return

/obj/effect/beam/infrared/Bump()
	del(src)
	return

/obj/effect/beam/infrared/Bumped()
	src.hit()
	return

/obj/effect/beam/infrared/HasEntered(atom/movable/AM as mob|obj)
	if(istype(AM, /obj/effect/beam))
		return
	spawn( 0 )
		src.hit()
		return
	return

/obj/effect/beam/infrared/Del()
	del(src.next)
	..()
	return
