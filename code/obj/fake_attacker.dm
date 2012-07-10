// This is part of the Hallucinations system.
/obj/fake_attacker
	icon = null
	icon_state = null
	name = ""
	desc = ""
	density = 0
	anchored = 1
	opacity = 0
	var/mob/living/carbon/human/my_target = null
	var/weapon_name = null
	var/obj/item/weap = null
	var/image/stand_icon = null
	var/image/currentimage = null
	var/icon/base = null
	var/s_tone
	var/mob/living/clone = null
	var/image/left
	var/image/right
	var/image/up
	var/collapse
	var/image/down

	var/health = 100

	attackby(var/obj/item/weapon/P as obj, mob/user as mob)
		step_away(src,my_target,2)
		for(var/mob/M in oviewers(world.view,my_target))
			M << "\red <B>[my_target] flails around wildly.</B>"
		my_target.show_message("\red <B>[src] has been attacked by [my_target] </B>", 1) //Lazy.

		src.health -= P.force


		return

	HasEntered(var/mob/M, somenumber)
		if(M == my_target)
			step_away(src,my_target,2)
			if(prob(30))
				for(var/mob/O in oviewers(world.view , my_target))
					O << "\red <B>[my_target] stumbles around.</B>"

	New()
		..()
		spawn(300)
			if(my_target)
				my_target.hallucinations -= src
			del(src)
		step_away(src,my_target,2)
		spawn attack_loop()


	proc/updateimage()
	//	del src.currentimage


		if(src.dir == NORTH)
			del src.currentimage
			src.currentimage = new /image(up,src)
		else if(src.dir == SOUTH)
			del src.currentimage
			src.currentimage = new /image(down,src)
		else if(src.dir == EAST)
			del src.currentimage
			src.currentimage = new /image(right,src)
		else if(src.dir == WEST)
			del src.currentimage
			src.currentimage = new /image(left,src)
		my_target << currentimage


	proc/attack_loop()
		while(1)
			sleep(rand(5,10))
			if(src.health < 0)
				collapse()
				continue
			if(get_dist(src,my_target) > 1)
				src.dir = get_dir(src,my_target)
				step_towards(src,my_target)
				updateimage()
			else
				if(prob(15))
					if(weapon_name)
						my_target << sound(pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg'))
						my_target.show_message("\red <B>[my_target] has been attacked with [weapon_name] by [src.name] </B>", 1)
						my_target.halloss += 8
						if(prob(20)) my_target.eye_blurry += 3
						if(prob(33))
							if(!locate(/obj/effect/overlay) in my_target.loc)
								fake_blood(my_target)
					else
						my_target << sound(pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg'))
						my_target.show_message("\red <B>[src.name] has punched [my_target]!</B>", 1)
						my_target.halloss += 4
						if(prob(33))
							if(!locate(/obj/effect/overlay) in my_target.loc)
								fake_blood(my_target)

			if(prob(15))
				step_away(src,my_target,2)

	proc/collapse()
		collapse = 1
		updateimage()

