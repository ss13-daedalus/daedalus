// BLADE
//Most of the other special functions are handled in their own files.

/obj/item/weapon/melee/energy/blade/New()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	return

/obj/item/weapon/melee/energy/blade/dropped()
	del(src)
	return

/obj/item/weapon/melee/energy/blade/proc/throw()
	del(src)
	return
