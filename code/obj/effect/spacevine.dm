// SPACE VINES
/obj/effect/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = 1
	density = 0
	pass_flags = PASSTABLE | PASSGRILLE
	var/energy = 0
	var/obj/effect/spacevine_controller/master = null

	New()
		return

	Del()
		if(master)
			master.vines -= src
			master.growth_queue -= src
		..()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (!W || !user || !W.type) return
		switch(W.type)
			if(/obj/item/weapon/circular_saw) del src
			if(/obj/item/weapon/kitchen/utensil/knife) del src
			if(/obj/item/weapon/scalpel) del src
			if(/obj/item/weapon/fireaxe) del src
			if(/obj/item/weapon/hatchet) del src
			if(/obj/item/weapon/melee/energy) del src

			//less effective weapons
			if(/obj/item/weapon/wire_cutters)
				if(prob(25)) del src
			if(/obj/item/weapon/shard)
				if(prob(25)) del src

			else //weapons with subtypes
				if(istype(W, /obj/item/weapon/melee/energy/sword)) del src
				else if(istype(W, /obj/item/weapon/welding_tool))
					if(W:welding) del src
			//TODO: add plant-b-gone
		..()

	attack_hand(mob/user as mob)
		for(var/mob/M in src.loc)
			if(M.buckled == src)
				if(prob(50))
					if(M == user)
						user << "\red You break free from the vines!"
					else
						user << "\red You rip away at the vines and free [M]!"
						M << "\red [user] frees you from the vines!"
					M.buckled = null
				else
					user << "\red You rip away at the vines..."
				break //only process one captured mob.

	attack_paw(mob/user as mob)
		return src.attack_hand(user)

/obj/effect/spacevine/proc/grow()
	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		src.opacity = 1
		layer = 5
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

/obj/effect/spacevine/proc/grab()
	for(var/mob/living/carbon/V in src.loc)
		if((V.stat != DEAD)  && (V.buckled != src)) //if mob not dead or captured
			V.buckled = src
			V << "\red The vines [pick("wind", "tangle")] around you!"
			break //only capture one mob at a time.

/obj/effect/spacevine/proc/spread()
	var/direction = pick(cardinal)
	var/step = get_step(src,direction)
	if(istype(step,/turf/simulated/floor))
		var/turf/simulated/floor/F = step
		if(!locate(/obj/effect/spacevine,F))
			if(F.Enter(src))
				if(master)
					master.spawn_spacevine_piece( F )

/*
/obj/effect/spacevine/proc/Life()
	if (!src) return
	var/Vspread
	if (prob(50)) Vspread = locate(src.x + rand(-1,1),src.y,src.z)
	else Vspread = locate(src.x,src.y + rand(-1, 1),src.z)
	var/dogrowth = 1
	if (!istype(Vspread, /turf/simulated/floor)) dogrowth = 0
	for(var/obj/O in Vspread)
		if (istype(O, /obj/structure/window) || istype(O, /obj/effect/forcefield) || istype(O, /obj/effect/blob) || istype(O, /obj/effect/alien/weeds) || istype(O, /obj/effect/spacevine)) dogrowth = 0
		if (istype(O, /obj/machinery/door/))
			if(O:p_open == 0 && prob(50)) O:open()
			else dogrowth = 0
	if (dogrowth == 1)
		var/obj/effect/spacevine/B = new /obj/effect/spacevine(Vspread)
		B.icon_state = pick("vine-light1", "vine-light2", "vine-light3")
		spawn(20)
			if(B)
				B.Life()
	src.growth += 1
	if (src.growth == 10)
		src.name = "Thick Space Kudzu"
		src.icon_state = pick("vine-med1", "vine-med2", "vine-med3")
		src.opacity = 1
		src.waittime = 80
	if (src.growth == 20)
		src.name = "Dense Space Kudzu"
		src.icon_state = pick("vine-hvy1", "vine-hvy2", "vine-hvy3")
		src.density = 1
	spawn(src.waittime)
		if (src.growth < 20) src.Life()

*/

/obj/effect/spacevine/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(90))
				del(src)
				return
		if(3.0)
			if (prob(50))
				del(src)
				return
	return

/obj/effect/spacevine/temperature_expose(null, temp, volume) //hotspots kill vines
	del src

