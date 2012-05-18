/obj/item/proc/transfer_soul(var/choice as text, var/target, var/mob/U as mob).
	switch(choice)
		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/obj/item/device/soulstone/C = src
			if(C.imprinted != "empty")
				U << "\red <b>Capture failed!</b>: \black The soul stone has already been imprinted with [C.imprinted]'s mind!"
			else
				if (T.stat == 0)
					U << "\red <b>Capture failed!</b>: \black Kill or maim the victim first!"
				else
					if(T.client == null)
						U << "\red <b>Capture failed!</b>: \black The soul has already fled it's mortal frame."
					else
						if(C.contents.len)
							U << "\red <b>Capture failed!</b>: \black The soul stone is full! Use or free an existing soul to make room."
						else
							for(var/obj/item/W in T)
								T.drop_from_slot(W)
							new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
							T.invisibility = 101
							var/atom/movable/overlay/animation = new /atom/movable/overlay( T.loc )
							animation.icon_state = "blank"
							animation.icon = 'icons/mob/mob.dmi'
							animation.master = T
							flick("dust-h", animation)
							del(animation)
							var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade( T.loc )
							S.loc = C //put shade in stone
							S.nodamage = 1 //So they won't die inside the stone somehow
							S.canmove = 0//Can't move out of the soul stone
							S.name = "Shade of [T.name]"
							if (T.client)
								T.client.mob = S
							S.cancel_camera()
							C.icon_state = "soulstone2"
							C.name = "Soul Stone: [S.name]"
							S << "Your soul has been captured! You are now bound to [U.name]'s will, help them suceed in their goals at all costs."
							U << "\blue <b>Capture successful!</b>: \black [T.name]'s soul has been ripped from their body and stored within the soul stone."
							U << "The soulstone has been imprinted with [S.name]'s mind, it will no longer react to other souls."
							C.imprinted = "[S.name]"
							del T
		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			var/obj/item/device/soulstone/C = src
			if (T.alive == 0)
				U << "\red <b>Capture failed!</b>: \black The shade has already been banished!"
			else
				if(C.contents.len)
					U << "\red <b>Capture failed!</b>: \black The soul stone is full! Use or free an existing soul to make room."
				else
					if(T.name != C.imprinted)
						U << "\red <b>Capture failed!</b>: \black The soul stone has already been imprinted with [C.imprinted]'s mind!"
					else
						T.loc = C //put shade in stone
						T.nodamage = 1
						T.canmove = 0
						T.health = T.maxHealth
						C.icon_state = "soulstone2"
						T << "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form"
						U << "\blue <b>Capture successful!</b>: \black [T.name]'s has been recaptured and stored within the soul stone."
		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/obj/item/device/soulstone/C = src
			var/mob/living/simple_animal/shade/A = locate() in C
			if(A)
				var/construct_class = alert(U, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
				var/mob/living/simple_animal/Z
				switch(construct_class)
					if("Juggernaut")
						Z = new /mob/living/simple_animal/constructarmoured (get_turf(T.loc))
						if (A.client)
							A.client.mob = Z
						del(T)
						Z << "<B>You are playing a Juggernaut. Though slow, you can withstand extreme punishment, and rip apart enemies and walls alike.</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall(Z)
						Z.cancel_camera()
						del(C)

					if("Wraith")
						Z = new /mob/living/simple_animal/constructwraith (get_turf(T.loc))
						if (A.client)
							A.client.mob = Z
						del(T)
						Z << "<B>You are playing a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift(Z)
						Z.cancel_camera()
						del(C)

					if("Artificer")
						Z = new /mob/living/simple_animal/constructbuilder (get_turf(T.loc))
						if (A.client)
							A.client.mob = Z
						del(T)
						Z << "<B>You are playing an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, repair allied constructs (by clicking on them), and even create new constructs</B>"
						Z << "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>"
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/wall(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/floor(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/wall/reinforced(Z)
						Z.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone(Z)
						Z.cancel_camera()
						del(C)
			else
				U << "\red <b>Creation failed!</b>: \black The soul stone is empty! Go kill someone!"
	return

