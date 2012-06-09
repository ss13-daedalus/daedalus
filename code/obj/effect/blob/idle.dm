/obj/effect/blob/idle
	name = "blob"
	desc = "it looks... tasty"
	icon_state = "blobidle0"


	New(loc, var/h = 10, var/w = "fire", var/s = "brute")
		src.health = h
		src.weakness = w
		src.strength = s
		src.dir = pick(1,2,4,8)
		src.update_idle()


	proc/update_idle()			//put in stuff here to make it transform? Maybe when its down to around 5 health?
		if(health<=0)
			del(src)
			return
		if(health<4)
			icon_state = "blobc0"
			return
		if(health<10)
			icon_state = "blobb0"
			return
		icon_state = "blobidle0"


	Del()		//idle blob that spawns a normal blob when killed.
		var/obj/effect/blob/B = new /obj/effect/blob( src.loc, src.weakness, src.strength )
		spawn(30)
			B.Life()
		..()



