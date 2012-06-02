datum/objective/steal
	var/obj/item/steal_target

	check_completion()
		if(steal_target)
			if(!owner)
				// An objective without an owner cannot be complete.
				return 0
			if(owner.current.check_contents_for(steal_target))
				return 1
			else
				return 0


	captainslaser
		steal_target = /obj/item/weapon/gun/energy/laser/captain
		explanation_text = "Steal the captain's antique laser gun."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 60
				if(1)
					return 50
				if(2)
					return 40
				if(3)
					return 30
				if(4)
					return 20

		get_weight(var/job)
			if(GetRank(job) == 4)
				return 10
			else
				return 20


	phorontank
		steal_target = /obj/item/weapon/tank/phoron
		explanation_text = "Steal a small phoron tank."
		weight = 20

		get_points(var/job)
			if(job in science_positions || job in command_positions)
				return 20
			return 40

		get_weight(var/job)
			return 20

		check_completion()
			if(!owner)
				return 0 // Can't succeed if there's no one to.
			var/list/all_items = owner.current.get_contents()
			for(var/obj/item/I in all_items)
				if(!istype(I, steal_target))	continue//If it's not actually that item.
				if(I:air_contents:toxins) return 1 //If they got one with phoron
			return 0


	/*Removing this as an objective.  Not necessary to have two theft objectives in the same room.
	steal/captainssuit
		steal_target = /obj/item/clothing/under/rank/captain
		explanation_text = "Steal a captain's rank jumpsuit"
		weight = 50

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return INFINITY
	*/


	handtele
		steal_target = /obj/item/weapon/handheld_teleporter
		explanation_text = "Steal a handheld teleporter."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		get_weight(var/job)
			if(GetRank(job) == 4)
				return 10
			else
				return 20


	RCD
		steal_target = /obj/item/weapon/rcd
		explanation_text = "Steal a rapid construction device."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		get_weight(var/job)
			if(GetRank(job) == 4)
				return 10
			else
				return 20


	/*burger
		steal_target = /obj/item/weapon/reagent_containers/food/snacks/human/burger
		explanation_text = "Steal a burger made out of human organs, this will be presented as proof of NanoTrasen's chronic lack of standards."
		weight = 60

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 80
				if(1)
					return 65
				if(2)
					return 55
				if(3)
					return 40
				if(4)
					return 25*/


	jetpack
		steal_target = /obj/item/weapon/tank/jetpack/oxygen
		explanation_text = "Steal a blue oxygen jetpack."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		get_weight(var/job)
			if(GetRank(job) == 4)
				return 10
			else
				return 20


	magboots
		steal_target = /obj/item/clothing/shoes/magboots
		explanation_text = "Steal a pair of \"NanoTrasen\" brand magboots."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		get_weight(var/job)
			if(GetRank(job) == 4)
				return 10
			else
				return 20


	blueprints
		steal_target = /obj/item/blueprints
		explanation_text = "Steal the station's blueprints."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		get_weight(var/job)
			if(GetRank(job) == 4)
				return 10
			else
				return 20


	voidsuit
		steal_target = /obj/item/clothing/suit/space/nasavoid
		explanation_text = "Steal a voidsuit."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		get_weight(var/job)
			return 20


	nuke_disk
		steal_target = /obj/item/weapon/disk/nuclear
		explanation_text = "Steal the station's nuclear authentication disk."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 90
				if(1)
					return 80
				if(2)
					return 70
				if(3)
					return 40
				if(4)
					return 25

		get_weight(var/job)
			if(GetRank(job) == 4)
				return 10
			else
				return 20

	nuke_gun
		steal_target = /obj/item/weapon/gun/energy/gun/nuclear
		explanation_text = "Steal a nuclear powered gun."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 90
				if(1)
					return 85
				if(2)
					return 80
				if(3)
					return 75
				if(4)
					return 75

		get_weight(var/job)
			return 2

	diamond_drill
		steal_target = /obj/item/weapon/pickaxe/diamonddrill
		explanation_text = "Steal a diamond drill."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 90
				if(1)
					return 85
				if(2)
					return 70
				if(3)
					return 75
				if(4)
					return 75

		get_weight(var/job)
			return 2

	boh
		steal_target = /obj/item/weapon/storage/backpack/holding
		explanation_text = "Steal a \"bag of holding.\""
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 90
				if(1)
					return 85
				if(2)
					return 80
				if(3)
					return 75
				if(4)
					return 75

		get_weight(var/job)
			return 2

	hyper_cell
		steal_target = /obj/item/weapon/power_cell/hyper
		explanation_text = "Steal a hyper capacity power cell."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 90
				if(1)
					return 85
				if(2)
					return 80
				if(3)
					return 75
				if(4)
					return 75

		get_weight(var/job)
			return 2

	lucy
		steal_target = /obj/item/stack/sheet/diamond
		explanation_text = "Steal 10 diamonds."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 90
				if(1)
					return 85
				if(2)
					return 80
				if(3)
					return 75
				if(4)
					return 75

		get_weight(var/job)
			return 2

		check_completion()
			if(!owner)
				return 0
			var/target_amount = 10
			var/found_amount = 0.0//Always starts as zero.
			for(var/obj/item/I in owner.current.get_contents())
				if(!istype(I, steal_target))	continue//If it's not actually that item.
				found_amount += I:amount
			return found_amount>=target_amount

	gold
		steal_target = /obj/item/stack/sheet/gold
		explanation_text = "Steal 50 gold bars."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 90
				if(1)
					return 85
				if(2)
					return 80
				if(3)
					return 75
				if(4)
					return 70

		get_weight(var/job)
			return 2

		check_completion()
			if(!owner)
				return 0
			var/target_amount = 50
			var/found_amount = 0.0//Always starts as zero.
			for(var/obj/item/I in owner.current.get_contents())
				if(!istype(I, steal_target))	continue//If it's not actually that item.
				found_amount += I:amount
			return found_amount>=target_amount

	uranium
		steal_target = /obj/item/stack/sheet/uranium
		explanation_text = "Steal 25 uranium bars."
		weight = 20

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 90
				if(1)
					return 85
				if(2)
					return 80
				if(3)
					return 75
				if(4)
					return 70

		get_weight(var/job)
			return 2

		check_completion()
			if(!owner)
				return 0
			var/target_amount = 25
			var/found_amount = 0.0//Always starts as zero.
			for(var/obj/item/I in owner.current.get_contents())
				if(!istype(I, steal_target))	continue//If it's not actually that item.
				found_amount += I:amount
			return found_amount>=target_amount


	/*Needs some work before it can be put in the game to differentiate ship implanters from syndicate implanters.
	steal/implanter
		steal_target = /obj/item/weapon/implanter
		explanation_text = "Steal an implanter"
		weight = 50

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return INFINITY
	*/
	cyborg
		steal_target = /obj/item/robot_parts/robot_suit
		explanation_text = "Steal a completed cyborg shell (no brain)"
		weight = 30

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		check_completion()
			if(steal_target)
				if (!owner)
					return 0
				for(var/obj/item/robot_parts/robot_suit/objective in owner.current.get_contents())
					if(istype(objective,/obj/item/robot_parts/robot_suit) && objective.check_completion())
						return 1
				return 0

		get_weight(var/job)
			return 20
	AI
		steal_target = /obj/structure/AIcore
		explanation_text = "Steal a finished AI, either by intellicard or stealing the whole construct."
		weight = 50

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		get_weight(var/job)
			return 15

		check_completion()
			if(steal_target)
				if(!owner)
					return 0
				for(var/obj/item/device/aicard/C in owner.current.get_contents())
					for(var/mob/living/silicon/ai/M in C)
						if(istype(M, /mob/living/silicon/ai) && M.stat != 2)
							return 1
				for(var/mob/living/silicon/ai/M in world)
					if(istype(M.loc, /turf))
						if(istype(get_area(M), /area/shuttle/escape))
							return 1
				for(var/obj/structure/AIcore/M in world)
					if(istype(M.loc, /turf) && M.state == 4)
						if(istype(get_area(M), /area/shuttle/escape))
							return 1
				return 0

	drugs
		steal_target = /datum/reagent/space_drugs
		explanation_text = "Steal some space drugs."
		weight = 40

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		check_completion()
			if(steal_target)
				if(!owner)
					return 0
				if(owner.current.check_contents_for_reagent(steal_target))
					return 1
				else
					return 0

		get_weight(var/job)
			return 20


	pacid
		steal_target = /datum/reagent/pacid
		explanation_text = "Steal some polytrinic acid."
		weight = 40

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		check_completion()
			if(steal_target)
				if(!owner)
					return 0
				if(owner.current.check_contents_for_reagent(steal_target))
					return 1
				else
					return 0

		get_weight(var/job)
			return 20


	reagent
		weight = 20

		var/target_name
		New(var/text,var/joba)
			..()
			var/list/items = list("Sulphuric acid", "Polytrinic acid", "Space Lube", "Unstable mutagen",\
			 "Leporazine", "Cryptobiolin", "Lexorin ",\
			  "Kelotane", "Dexalin", "Tricordrazine")
			target_name = pick(items)
			switch(target_name)
				if("Sulphuric acid")
					steal_target = /datum/reagent/acid
				if("Polytrinic acid")
					steal_target = /datum/reagent/pacid
				if("Space Lube")
					steal_target = /datum/reagent/lube
				if("Unstable mutagen")
					steal_target = /datum/reagent/mutagen
				if("Leporazine")
					steal_target = /datum/reagent/leporazine
				if("Cryptobiolin")
					steal_target =/datum/reagent/cryptobiolin
				if("Lexorin")
					steal_target = /datum/reagent/lexorin
				if("Kelotane")
					steal_target = /datum/reagent/kelotane
				if("Dexalin")
					steal_target = /datum/reagent/dexalin
				if("Tricordrazine")
					steal_target = /datum/reagent/tricordrazine

			explanation_text = "Steal a container filled with [target_name]."

		get_points(var/job)
			switch(GetRank(job))
				if(0)
					return 75
				if(1)
					return 60
				if(2)
					return 50
				if(3)
					return 30
				if(4)
					return 20

		check_completion()
			if(steal_target)
				if(!owner)
					return 0
				if(owner.current.check_contents_for_reagent(steal_target))
					return 1
				else
					return 0

		get_weight(var/job)
			return 20

