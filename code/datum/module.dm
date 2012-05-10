// module datum.
// this is per-object instance, and shows the condition of the modules in the object
// actual modules needed is referenced through module_types and the object type

/datum/module
	var/status				// bits set if working, 0 if broken
	var/installed			// bits set if installed, 0 if missing

/datum/module/New(var/obj/O)

	var/type = O.type		// the type of the creating object

	var/mneed = mods.inmodlist(type)		// find if this type has modules defined

	if(!mneed)		// not found in module list?
		del(src)	// delete self, thus ending proc

	var/needed = mods.getbitmask(type)		// get a bitmask for the number of modules in this object
	status = needed
	installed = needed
