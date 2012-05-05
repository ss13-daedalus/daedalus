// Antibodies, for disease fun.
datum/reagent/antibodies
	data = new/list("antibodies"=0)
	name = "Antibodies"
	id = "antibodies"
	reagent_state = LIQUID
	color = "#0050F0"

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		if(istype(M,/mob/living/carbon))
			if(src.data && method == INGEST)
				if(M:virus2) if(src.data["antibodies"] & M:virus2.antigen)
					M:virus2.dead = 1
					// if the virus is killed this way it immunizes
					M:antibodies |= M:virus2.antigen
		return
