/mob/living/carbon/alien/adjustToxLoss(amount)
	storedPhoron = min(max(storedPhoron + amount,0),max_phoron) //upper limit of max_phoron, lower limit of 0
	return

/mob/living/carbon/alien/proc/getPhoron()
	return storedPhoron

/mob/living/carbon/alien/eyecheck()
	return 2

/mob/living/carbon/alien/New()
	..()

	for(var/obj/item/clothing/mask/facehugger/facehugger in world)
		if(facehugger.stat == CONSCIOUS)
			var/image/activeIndicator = image('icons/mob/alien.dmi', loc = facehugger, icon_state = "facehugger_active")
			activeIndicator.override = 1
			client.images += activeIndicator

/mob/living/carbon/alien/IsAdvancedToolUser()
	return has_fine_manipulation
