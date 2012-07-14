/obj/effect/critter/roach
	name = "cockroach"
	desc = "An unpleasant insect that lives in filthy places."
	icon_state = "roach"
	health = 5
	max_health = 5
	aggressive = 0
	defensive = 1
	wanderer = 1
	atkcarbon = 1
	atksilicon = 0
	attacktext = "bites"

	Die()
		..()
		del(src)

