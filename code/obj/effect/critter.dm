/obj/effect/critter
	name = "Critter"
	desc = "Generic critter."
	icon = 'icons/mob/critter.dmi'
	icon_state = "basic"
	layer = 5.0
	density = 1
	anchored = 0
	var
		alive = 1
		health = 10
		max_health = 10
		aggression = 100
		speed = 8
		list/access_list = list()//accesses go here
//AI things
		task = "thinking"
	//Attacks at will
		aggressive = 1
	//Will target an attacker
		defensive = 0
	//Will randomly move about
		wanderer = 1
	//Will open doors it bumps ignoring access
		opensdoors = 0
	//Will randomly travel through vents
		ventcrawl = 0

	//Internal tracking ignore
		frustration = 0
		max_frustration = 8
		attack = 0
		attacking = 0
		steps = 0
		last_found = null
		target = null
		oldtarget_name = null
		target_lastloc = null

		thinkspeed  = 15
		chasespeed  = 4
		wanderspeed = 10
		//The last guy who attacked it
		attacker = null
		//Will not attack this thing
		friend = null
		//How far to look for things dont set this overly high
		seekrange = 7

	//If true will attack these things
		atkcarbon = 1
		atksilicon = 0
		atkcritter = 0
		//Attacks critters of the same type
		atksame = 0
		atkmech = 0

		//Attacks syndies/traitors (distinguishes via mind)
		atksynd = 1
		//Attacks things NOT in its obj/req_access list
		atkreq = 0

	//Damage multipliers
		brutevuln = 1
		firevuln = 1
		//DR
		armor = 0

		//How much damage it does it melee
		melee_damage_lower = 1
		melee_damage_upper = 2
		//Basic attack message when they move to attack and attack
		angertext = "charges at"
		attacktext = "attacks"
		deathtext = "dies!"

		chasestate = null // the icon state to use when attacking or chasing a target
		attackflick = null // the icon state to flick when it attacks
		attack_sound = null // the sound it makes when it attacks!

		attack_speed = 25 // delay of attack


	proc
		patrol_step()
		seek_target()
		Die()
		ChaseAttack()
		RunAttack()
		TakeDamage(var/damage = 0)
		Target_Attacker(var/target)
		Harvest(var/obj/item/weapon/W, var/mob/living/user)//Controls havesting things from dead critters
		AfterAttack(var/mob/living/target)



/* TODO:Go over these and see how/if to add them

	proc/set_attack()
		state = 1
		if(path_idle.len) path_idle = new/list()
		trg_idle = null

	proc/set_idle()
		state = 2
		if (path_target.len) path_target = new/list()
		target = null
		frustration = 0

	proc/set_null()
		state = 0
		if (path_target.len) path_target = new/list()
		if (path_idle.len) path_idle = new/list()
		target = null
		trg_idle = null
		frustration = 0

	proc/path_idle(var/atom/trg)
		path_idle = AStar(src.loc, get_turf(trg), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, anicard, null)
		path_idle = reverselist(path_idle)

	proc/path_attack(var/atom/trg)
		path_target = AStar(src.loc, trg.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, anicard, null)
		path_target = reverselist(path_target)


//Look these over
	var/list/path = new/list()
	var/patience = 35						//The maximum time it'll chase a target.
	var/list/mob/living/carbon/flee_from = new/list()
	var/list/path_target = new/list()		//The path to the combat target.

	var/turf/trg_idle					//It's idle target, the one it's following but not attacking.
	var/list/path_idle = new/list()		//The path to the idle target.



*/





	New()
		spawn(0) process()//I really dont like this much but it seems to work well
		..()


	process()
		set background = 1
		if (!src.alive)	return
		switch(task)
			if("thinking")
				src.attack = 0
				src.target = null
				sleep(thinkspeed)
				walk_to(src,0)
				if (src.aggressive) seek_target()
				if (src.wanderer && !src.target) src.task = "wandering"
			if("chasing")
				if (src.frustration >= max_frustration)
					src.target = null
					src.last_found = world.time
					src.frustration = 0
					src.task = "thinking"
					walk_to(src,0)
				if (target)
					if (get_dist(src, src.target) <= 1)
						var/mob/living/carbon/M = src.target
						ChaseAttack()
						src.task = "attacking"
						if(chasestate)
							icon_state = chasestate
						src.anchored = 1
						src.target_lastloc = M.loc
					else
						var/turf/olddist = get_dist(src, src.target)
						walk_to(src, src.target,1,chasespeed)
						if ((get_dist(src, src.target)) >= (olddist))
							src.frustration++
						else
							src.frustration = 0
						sleep(5)
				else src.task = "thinking"
			if("attacking")
				// see if he got away
				if ((get_dist(src, src.target) > 1) || ((src.target:loc != src.target_lastloc)))
					src.anchored = 0
					src.task = "chasing"
					if(chasestate)
						icon_state = chasestate
				else
					if (get_dist(src, src.target) <= 1)
						var/mob/living/carbon/M = src.target
						if(!src.attacking)	RunAttack()
						if(!src.aggressive)
							src.task = "thinking"
							src.target = null
							src.anchored = 0
							src.last_found = world.time
							src.frustration = 0
							src.attacking = 0
						else
							if(M!=null)
								if(ismob(src.target))
									if(M.health < config.health_threshold_crit)
										src.task = "thinking"
										src.target = null
										src.anchored = 0
										src.last_found = world.time
										src.frustration = 0
										src.attacking = 0
					else
						src.anchored = 0
						src.attacking = 0
						src.task = "chasing"
						if(chasestate)
							icon_state = chasestate
			if("wandering")
				if(chasestate)
					icon_state = initial(icon_state)
				patrol_step()
				sleep(wanderspeed)
		spawn(8)
			process()
		return


	patrol_step()
		var/moveto = locate(src.x + rand(-1,1),src.y + rand(-1, 1),src.z)
		if (istype(moveto, /turf/simulated/floor) || istype(moveto, /turf/simulated/shuttle/floor) || istype(moveto, /turf/unsimulated/floor)) step_towards(src, moveto)
		if(src.aggressive) seek_target()
		steps += 1
		if (steps == rand(5,20)) src.task = "thinking"


	Bump(M as mob|obj)//TODO: Add access levels here
		spawn(0)
			if((istype(M, /obj/machinery/door)))
				if(src.opensdoors)
					M:open()
					src.frustration = 0
			else src.frustration ++
			if((istype(M, /mob/living/)) && (!src.anchored))
				src.loc = M:loc
				src.frustration = 0
			return
		return


	Bumped(M as mob|obj)
		spawn(0)
			var/turf/T = get_turf(src)
			M:loc = T


	seek_target()
		if(!prob(aggression)) return // make them attack depending on aggression levels
	
		src.anchored = 0
		var/T = null
		for(var/mob/living/C in view(src.seekrange,src))//TODO: mess with this
			if (src.target)
				src.task = "chasing"
				break

			// Ignore syndicates and traitors if specified
			if(!atksynd && C.mind)
				var/datum/mind/synd_mind = C.mind
				if( synd_mind.special_role == "Syndicate" || synd_mind.special_role == "traitor" )
					continue
			if((C.name == src.oldtarget_name) && (world.time < src.last_found + 100)) continue
			if(istype(C, /mob/living/carbon/) && !src.atkcarbon) continue
			if(istype(C, /mob/living/silicon/) && !src.atksilicon) continue
			if(atkreq)
				if(src.allowed(C)) continue
			if(C.health < config.health_threshold_crit) continue
			if(istype(C, /mob/living/carbon/) && src.atkcarbon)	src.attack = 1
			if(istype(C, /mob/living/silicon/) && src.atksilicon)	src.attack = 1
			if(atkreq)
				if(!src.allowed(C)) src.attack = 1
			if(src.attack)
				T = C
				break

		if(!src.attack)
			for(var/obj/effect/critter/C in view(src.seekrange,src))
				if(!src.atkcritter) continue
				if(C.health <= config.health_threshold_crit) continue
				if(src.atkcritter)
					if((istype(C, src.type) && !src.atksame) || (C == src))	continue
					src.attack = 1
				if(src.attack)
					T = C
					break

			if(!src.attack)
				for(var/obj/mecha/C in view(src.seekrange,src))
					if(!C.occupant) continue

					if(atkreq && C.occupant)
						if(src.allowed(C.occupant)) continue

					if(!atksynd && C.occupant)
						if(C.occupant.mind)
							var/datum/mind/synd_mind = C.occupant.mind
							if( synd_mind.special_role == "Syndicate" || synd_mind.special_role == "traitor" )
								continue

					if(!src.atkmech) continue
					if(C.health <= config.health_threshold_crit) continue
					if(src.atkmech)	src.attack = 1
					if(src.attack)
						T = C
						break

		if(src.attack)
			src.target = T
			src.oldtarget_name = T:name
			src.task = "chasing"
		return


	ChaseAttack()
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>[src]</B> [src.angertext] at [src.target]!", 1)
		return


	RunAttack()
		src.attacking = 1
		if(ismob(src.target))

			for(var/mob/O in viewers(src, null))
				O.show_message("\red <B>[src]</B> [src.attacktext] [src.target]!", 1)

			var/damage = rand(melee_damage_lower, melee_damage_upper)

			if(istype(target, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = target
				var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
				var/datum/organ/external/affecting = H.get_organ(ran_zone(dam_zone))
				H.apply_damage(damage, BRUTE, affecting, H.run_armor_check(affecting, "melee"))
			else
				target:adjustBruteLoss(damage)

			if(attack_sound)
				playsound(loc, attack_sound, 50, 1, -1)

			AfterAttack(target)


		if(isobj(src.target))
			if(istype(target, /obj/mecha))
				//src.target:take_damage(rand(melee_damage_lower,melee_damage_upper))
				src.target:attack_critter(src)
			else
				src.target:TakeDamage(rand(melee_damage_lower,melee_damage_upper))
		spawn(attack_speed)
			src.attacking = 0
		return



/*TODO: Figure out how to handle special things like this dont really want to give it to every critter
/obj/effect/critter/proc/CritterTeleport(var/telerange, var/dospark, var/dosmoke)
	if (!src.alive) return
	var/list/randomturfs = new/list()
	for(var/turf/T in orange(src, telerange))
		if(istype(T, /turf/space) || T.density) continue
		randomturfs.Add(T)
	src.loc = pick(randomturfs)
	if (dospark)
		var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
	if (dosmoke)
		var/datum/effect/system/harmless_smoke_spread/smoke = new /datum/effect/system/harmless_smoke_spread()
		smoke.set_up(10, 0, src.loc)
		smoke.start()
	src.task = "thinking"
*/

/*
Contains the procs that control attacking critters
*/
/obj/effect/critter

	attackby(obj/item/weapon/W as obj, mob/living/user as mob)
		..()
		if(!src.alive)
			Harvest(W,user)
			return
		var/damage = 0
		switch(W.damtype)
			if("fire") damage = W.force * firevuln
			if("brute") damage = W.force * brutevuln
		TakeDamage(damage)
		if(src.defensive && alive)	Target_Attacker(user)
		return


	attack_hand(var/mob/user as mob)
		if (!src.alive)	..()
		if (user.a_intent == "hurt")
			TakeDamage(rand(1,2) * brutevuln)

			if(istype(user, /mob/living/carbon/human))
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[user] has punched [src]!</B>", 1)
				playsound(src.loc, pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg'), 100, 1)

			else if(istype(user, /mob/living/carbon/alien/humanoid))
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[user] has slashed at [src]!</B>", 1)
				playsound(src.loc, 'sound/weapons/slice.ogg', 25, 1, -1)

			else if(user.type == /mob/living/carbon/human/tajaran)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[user] has slashed at [src]!</B>", 1)
				playsound(src.loc, 'sound/weapons/slice.ogg', 25, 1, -1)

			else
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[user] has bit [src]!</B>", 1)

			if(src.defensive)	Target_Attacker(user)
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("\blue [user] touches [src]!", 1)


	Target_Attacker(var/target)
		if(!target)	return
		src.target = target
		src.oldtarget_name = target:name
		if(task != "chasing" && task != "attacking")
			if(angertext && angertext != "")
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <b>[src]</b> [src.angertext] at [target:name]!", 1)
			src.task = "chasing"
		return


	TakeDamage(var/damage = 0)
		var/tempdamage = (damage-armor)
		if(tempdamage > 0)
			src.health -= tempdamage
		else
			src.health--
		if(src.health <= 0)
			src.Die()


	Die()
		if (!src.alive) return
		src.icon_state += "-dead"
		src.alive = 0
		src.anchored = 0
		src.density = 0
		walk_to(src,0)
		src.visible_message("<b>[src]</b> [deathtext]")


	Harvest(var/obj/item/weapon/W, var/mob/living/user)
		if((!W) || (!user))	return 0
		if(src.alive)	return 0
		return 1


	bullet_act(var/obj/item/projectile/Proj)
		TakeDamage(Proj.damage)
		..()


	ex_act(severity)
		switch(severity)
			if(1.0)
				src.Die()
				return
			if(2.0)
				TakeDamage(20)
				return
		return


	emp_act(serverity)
		switch(serverity)
			if(1.0)
				src.Die()
				return
			if(2.0)
				TakeDamage(20)
				return
		return

	blob_act()
		if(prob(25))
			src.Die()
		return

	attack_animal(mob/living/simple_animal/M as mob)
		if(M.melee_damage_upper == 0)
			M.emote("[M.friendly] [src]")
		else
			for(var/mob/O in viewers(src, null))
				O.show_message("\red <B>[M]</B> [M.attacktext] [src]!", 1)
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
			TakeDamage(damage)
		return
