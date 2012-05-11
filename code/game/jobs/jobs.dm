var/const
	ENGSEC	=(1<<0)

	CAPTAIN			=(1<<0)
	HOS				=(1<<1)
	WARDEN			=(1<<2)
	DETECTIVE		=(1<<3)
	OFFICER			=(1<<4)
	CHIEF			=(1<<5)
	ENGINEER		=(1<<6)
	ATMOSTECH		=(1<<7)
	ROBOTICIST		=(1<<8)
	AI				=(1<<9)
	CYBORG			=(1<<10)


	MEDSCI		=(1<<1)

	RD				=(1<<0)
	SCIENTIST		=(1<<1)
	CHEMIST			=(1<<2)
	CMO				=(1<<3)
	DOCTOR			=(1<<4)
	GENETICIST		=(1<<5)


	CIVILIAN	=(1<<2)

	HOP				=(1<<0)
	BARTENDER		=(1<<1)
	BOTANIST		=(1<<2)
	CHEF			=(1<<3)
	JANITOR			=(1<<4)
	LIBRARIAN		=(1<<5)
	QUARTERMASTER	=(1<<6)
	CARGOTECH		=(1<<7)
	MINER			=(1<<8)
	LAWYER			=(1<<9)
	CHAPLAIN		=(1<<10)
	CLOWN			=(1<<11)
	MIME			=(1<<12)
	ASSISTANT		=(1<<13)


var/list/assistant_occupations = list(
	"Assistant",
	"Atmospheric Technician",
	"Cargo Technician",
	"Chaplain",
	"Lawyer",
	"Librarian"
)


var/list/command_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer"
)


var/list/engineering_positions = list(
	"Chief Engineer",
	"Station Engineer",
	"Atmospheric Technician",
	"Roboticist"
)


var/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Geneticist"
)


var/list/science_positions = list(
	"Research Director",
	"Scientist",
	"Chemist"
)


var/list/civilian_positions = list(
	"Head of Personnel",
	"Bartender",
	"Botanist",
	"Chef",
	"Janitor",
	"Librarian",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner",
	"Lawyer",
	"Chaplain",
	"Assistant"
)


var/list/security_positions = list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer"
)


var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	"pAI"
)


/proc/guest_jobbans(var/job)
	return ((job in command_positions) || (job in nonhuman_positions) || (job in security_positions))

/proc/GetRank(var/job)
	switch(job)
		if("Bartender", "Barkeep", "Chef", "Cook", "Culinary Technician", "Butcher", "Baker", "Lawyer", "Attorney at Law", "Attorney", "esq.", "Public Defender", "Paralegal", "Librarian", "Literary Specialist", "Bibliotechnician", "Janitor", "Custodian", "Custodial Technician", "Maintenance Technician", "Lighting Specialist", "Assistant", "Unassigned")
			return 0
		if("Chaplain", "Counselor", "Apostate", "Reverend", "Pastor", "Advisor", "Botanist", "Farmer", "Hydroponicist", "Aeroponicist", "Medical Doctor", "Atmospheric Technician", "Geneticist", "Virologist", "Surgeon", "Emergency Medical Technician", "Nurse", "General Practitioner", "M.D.")
			return 1
		if("Quartermaster", "Logistics Director", "Cargo Technician", "Dockworker", "Warehouser", "Shipping and Receiving Technician", "Chemist", "Station Engineer", "Technician", "Electrician", "Roboticist", "Security Officer", "Constable", "Enforcer", "Peacekeeper", "Forensic Technician", "Detective", "Forensic Technician", "Inspector", "Scientist", "Shaft Miner", "Digger", "Resource Extraction Specialist", "Xenobiologist", "Phoron Researcher", "Research Assistant", "PhD", "Chief Medical Officer")
			return 2
		if("Research Director", "Head of Security", "Chief Engineer", "Warden", "Jailor")
			return 3
		if("Captain", "Head of Personnel", "Personnel Director", "Director of Human Resources", "Wizard", "MODE")
			return 4
		else
			message_admins("\"[job]\" NOT GIVEN RANK, REPORT JOBS.DM ERROR TO A CODER")
			return 2
