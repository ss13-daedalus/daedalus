/obj/effect/proc_holder/power
	name = "Power"
	desc = "Placeholder"
	density = 0
	opacity = 0

	var/helptext = ""

	var/allowduringlesserform = 0
	var/isVerb = 1 // Is it an active power, or passive?
	var/verbpath = null // Path to a verb that contains the effects.
	var/genomecost = 500000 // Cost for the changling to evolve this power.

/obj/effect/proc_holder/power/absorb_dna
	name = "Absorb DNA"
	desc = "Permits us to syphon the DNA from a human.  They become one with us, and we become stronger."
	genomecost = 0

	verbpath = /client/proc/changeling_absorb_dna

/obj/effect/proc_holder/power/transform
	name = "Transform"
	desc = "We take on the apperance and voice of one we have absorbed."
	genomecost = 0

	verbpath = /client/proc/changeling_transform

/obj/effect/proc_holder/power/lesser_form
	name = "Lesser Form"
	desc = "We debase ourselves and become lesser.  We become a monkey."
	genomecost = 1

	verbpath = /client/proc/changeling_lesser_form

/obj/effect/proc_holder/power/changeling_greater_form
	name = "Greater Form"
	desc = "We become the pinnicle of evolution.  We will show the humans what happens when they leave their isle of ignorance."
	genomecost = 250

	// doesn't happen lol.  Yet!

/obj/effect/proc_holder/power/fakedeath
	name = "Fake Death"
	desc = "We fake our death while we heal."
	genomecost = 0
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_fakedeath

/obj/effect/proc_holder/power/deaf_sting
	name = "Deaf Sting"
	desc = "We silently sting a human, completely deafening them for a short time."
	genomecost = 1
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_deaf_sting

/obj/effect/proc_holder/power/blind_sting
	name = "Blind Sting"
	desc = "We silently sting a human, completely blinding them for a short time."
	genomecost = 2
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_blind_sting

/obj/effect/proc_holder/power/paralysis_sting
	name = "Paralysis Sting"
	desc = "We silently sting a human, paralyzing them for a short time.  We must be wary, they can still whisper."
	genomecost = 5


	verbpath = /client/proc/changeling_paralysis_sting

/obj/effect/proc_holder/power/silence_sting
	name = "Silence Sting"
	desc = "We silently sting a human, completely silencing them for a short time."
	helptext = "Does not provide a warning to a victim that they&apos;ve been stung, until they try to speak and can&apos;t."  // Man, fuck javascript.  &apos; == '
	genomecost = 2
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_silence_sting

/obj/effect/proc_holder/power/transformation_sting
	name = "Transformation Sting"
	desc = "We silently sting a human, injecting a retrovirus that forces them to transform into another."
	genomecost = 2

	verbpath = /client/proc/changeling_transformation_sting

/obj/effect/proc_holder/power/unfat_sting
	name = "Unfat Sting"
	desc = "We silently sting a human, forcing them to rapidly metobolize their fat."
	genomecost = 1


	verbpath = /client/proc/changeling_unfat_sting

/obj/effect/proc_holder/power/boost_range
	name = "Boost Range"
	desc = "We evolve the ability to shoot our stingers at humans, with some preperation."
	genomecost = 2
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_boost_range


/obj/effect/proc_holder/power/Epinephrine
	name = "Epinephrine sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	helptext = "Gives the ability to instantly recover from stuns.  High chemical cost."
	genomecost = 4

	verbpath = /client/proc/changeling_unstun

/obj/effect/proc_holder/power/ChemicalSynth
	name = "Rapid Chemical Synthesis"
	desc = "We evolve new pathways for producing our necessary chemicals, permitting us to naturally create them faster."
	helptext = "Doubles the rate at which we naturally recharge chemicals."
	genomecost = 4
	isVerb = 0

	verbpath = /client/proc/changeling_fastchemical

/obj/effect/proc_holder/power/EngorgedGlands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	helptext = "Allows us to store an extra 25 units of chemicals."
	genomecost = 4
	isVerb = 0


	verbpath = /client/proc/changeling_engorgedglands

/obj/effect/proc_holder/power/DigitalCamoflague
	name = "Digital Camoflauge"
	desc = "We evolve the ability to distort our form and proprtions, defeating common altgorthms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill.  However, humans looking at us will find us.. uncanny.  We must constantly expend chemicals to maintain our form like this."
	genomecost = 4
	allowduringlesserform = 1

	verbpath = /client/proc/changeling_digitalcamo

/obj/effect/proc_holder/power/DeathSting
	name = "Death Sting"
	desc = "We silently sting a human, filling him with potent chemicals. His rapid death is all but assured."
	genomecost = 10

	verbpath = /client/proc/changeling_DEATHsting

/obj/effect/proc_holder/power/rapidregeneration
	name = "Rapid Regeneration"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	helptext = "Heals a moderate amount of damage every tick."
	genomecost = 8

	verbpath = /client/proc/changeling_rapidregen

/obj/effect/proc_holder/power/LSDSting
	name = "Hallucination Sting"
	desc = "We evolve the ability to sting a target with a powerful hallunicationary chemical."
	helptext = "The target does not notice they&apos;ve been stung.  The effect occurs after 30 to 60 seconds."
	genomecost = 3

	verbpath = /client/proc/changeling_lsdsting

