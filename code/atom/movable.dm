/atom/movable/Bump(var/atom/A as mob|obj|turf|area, yes)
	spawn( 0 )
		if ((A && yes))
			A.last_bumped = world.time
			A.Bumped(src)
		return
	..()
	return


