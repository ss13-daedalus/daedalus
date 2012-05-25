/obj/item/clothing/head/helmet/space/rig
	name = "engineer HERP helmet"
	desc = "A Hazardous Environment Ruggedized Protection helmet. Has radiation shielding and is made for use in a vaccuum or other hazardous conditions."
	icon_state = "rig-engineering"
	item_state = "rig_helm"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 35, bio = 100, rad = 20)
	allowed = list(/obj/item/device/flashlight)

/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining DERP helmet"
	desc = "A Durable EVA Radiation Protection helmet.  Made for use in hazardous conditions."
	icon_state = "rig-mining"

/obj/item/clothing/head/helmet/space/rig/elite
	name = "advanced DERP helmet"
	desc = "A Durable EVA Radiation Protection helmet.  Made for use in hazardous conditions."
	icon_state = "rig-white"

/obj/item/clothing/head/helmet/space/rig/engspace_helmet
	name = "engineering space helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding and a visor that can be toggled on and off."
	icon_state = "engspace_helmet"
	item_state = "engspace_helmet"
	see_face = 0.0
	var/up = 0

/obj/item/clothing/head/helmet/space/rig/cespace_helmet
	name = "chief engineer's space helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding and a visor that can be toggled on and off."
	icon_state = "cespace_helmet"
	item_state = "cespace_helmet"
	see_face = 0.0
	var/up = 0

/obj/item/clothing/head/helmet/space/rig/security
	name = "security DERP helmet"
	desc = "A Durable EVA Radiation Protection helmet.  Made for use in hazardous conditions."
	icon_state = "rig-security"
	armor = list(melee = 60, bullet = 10, laser = 30, energy = 5, bomb = 45, bio = 100, rad = 10)
