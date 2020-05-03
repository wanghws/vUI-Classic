local vUI, GUI, Language, Assets, Settings = select(2, ...):get()

GUI:AddOptions(function(self)
	self:CreateSpacer("ZZZ")
	
	local Left, Right = self:CreateWindow(Language["Credits"], nil, "zzzCredits")
	
	Left:CreateHeader(Language["Scripting Help & Mentoring"])
	Left:CreateDoubleLine("Tukz", "Foof")
	Left:CreateDoubleLine("Eclipse", "nightcracker")
	Left:CreateDoubleLine("Elv", "Azilroka")
	Left:CreateDoubleLine("Smelly", "AlleyKat")
	Left:CreateDoubleLine("Zork", "Simpy")
	
	Left:CreateHeader("oUF")
	Left:CreateDoubleLine("Haste", "lightspark")
	Left:CreateDoubleLine("p3lim", "Rainrider")
	
	Left:CreateHeader("LibHealComm-4.0")
	Left:CreateDoubleLine("Shadowed103", "xbeeps")
	Left:CreateLine("Azilroka")
	
	Left:CreateHeader("AceSerializer")
	Left:CreateLine("Nevcairiel")
	
	Right:CreateHeader("LibStub")
	Right:CreateDoubleLine("Kaelten", "Cladhaire")
	Right:CreateDoubleLine("ckknight", "Mikk")
	Right:CreateDoubleLine("Ammo", "Nevcairiel")
	Right:CreateLine("joshborke")
	
	Right:CreateHeader("LibSharedMedia")
	Right:CreateDoubleLine("Elkano", "funkehdude")
	
	Right:CreateHeader("LibClassicDurations, LibClassicCasterino")
	Right:CreateLine("d87_")
	
	Right:CreateHeader("LibClassicMobHealth-1.0")
	Right:CreateLine("Pneumatus")
	
	Right:CreateHeader("LibDeflate")
	Right:CreateLine("yoursafety")
	
	Right:CreateHeader("vUI")
	Right:CreateLine("Hydra")
	
	-- Supporters
	local Left, Right = self:CreateWindow(Language["Supporters"], nil, "zzzSupporters")
	
	Left:CreateHeader(Language["Acknowledgements"])
	Left:CreateMessage("Thank you to the following people who have supported the development of this project! It has taken immense time and effort, and the support of these people helps make it possible.")
	
	Right:CreateSupportHeader(Language["Supporters"])
	Right:CreateLine("Innie")
end)