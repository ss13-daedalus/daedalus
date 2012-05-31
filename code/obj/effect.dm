/*
	Some slapped-together star effects for maximum space immershuns. Basically consists of a
	spawner, an ender, and bgstar. Spawners create bgstars, bgstars shoot off into a direction
	until they reach a starender.
*/

/obj/effect/bgstar
	name = "star"
	var/speed = 10
	var/direction = SOUTH
	layer = 2 // TURF_LAYER

	New()
		..()
		pixel_x += rand(-2,30)
		pixel_y += rand(-2,30)
		var/starnum = pick("1", "1", "1", "2", "3", "4")

		icon_state = "star"+starnum

		speed = rand(2, 5)

	proc/startmove()

		while(src)
			sleep(speed)
			step(src, direction)
			for(var/obj/effect/starender/E in loc)
				del(src)


/obj/effect/starender
	invisibility = 101

/obj/effect/starspawner
	invisibility = 101
	var/spawndir = SOUTH
	var/spawning = 0

	West
		spawndir = WEST

	proc/startspawn()
		spawning = 1
		while(spawning)
			sleep(rand(2, 30))
			var/obj/effect/bgstar/S = new/obj/effect/bgstar(locate(x,y,z))
			S.direction = spawndir
			spawn()
				S.startmove()

// from the mop definition file.

/obj/effect/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/mop))
		return
	..()
