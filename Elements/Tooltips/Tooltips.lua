local vUI, GUI, Language, Media, Settings = select(2, ...):get()

GUI:AddOptions(function(self)
	local Left, Right = self:CreateWindow(Language["Tooltips"])
	
	Left:CreateLine("Coming soon.")
end)