/obj/item/weapon/disease_disk
	name = "Blank GNA disk"
	icon = 'cloning.dmi'
	icon_state = "datadisk0"
	var/datum/disease2/effectholder/effect = null
	var/stage = 1

/obj/item/weapon/disease_disk/premade/New()
	name = "Blank GNA disk (stage: [5-stage])"
	effect = new /datum/disease2/effectholder
	effect.effect = new /datum/disease2/effect/invisible
	effect.stage = stage
