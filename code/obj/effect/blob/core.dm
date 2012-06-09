/obj/effect/blob/core/New()
	..()
	spawn()
		src.blobdebug = 1
		src.Life()
		src.weakness = pick("fire", "brute", "cold", "acid", "elec")
		src.strength = pick("fire", "brute", "cold", "acid", "elec")
		if(src.strength == src.weakness) //Yes, they could have the same weakness and strength, but this should reduce the odds.
			src.strength = pick("fire", "brute", "cold", "acid", "elec")
		var/w = src.weakness
		if(w)
			if(w == "fire")
				src.fire_resist = 1
			if(w == "brute")
				src.brute_resist = 1


