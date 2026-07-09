local UILibrary = loadstring(game:HttpGetAsync("https://github.com/realheckersbrother/UnpackedHub/raw/refs/heads/main/UI.luau", true))()
local UI = UILibrary:start({
	size = Vector2.new(560, 740),
	name = "Unpacked Hub",
	accent = Color3.fromRGB(255, 200, 69),
	colors = {
		a = Color3.fromRGB(0, 0, 0),
		b = Color3.fromRGB(56, 56, 56),
		c = Color3.fromRGB(46, 46, 46),
		d = Color3.fromRGB(12, 12, 12),
		e = Color3.fromRGB(21, 21, 21),
		f = Color3.fromRGB(84, 84, 84),
		g = Color3.fromRGB(54, 54, 54),
	},
	tabs = {
		"Scripts",
  }
})

ui:createnotification({
  text = "Initializing...",
  lifetime = 3,
  priority = 0
})

ui:createsubsection({tab = "Scripts", name = "Scripts", length = 1, side = 1})

ui:createbutton({
  name = "Last Letter | Auto Typer"
  tab = "Scripts",
  subsection = "Scripts",
  flag = "LastLetterAutoTyper",
  confirmation = true
})

ui.flags.LastLetterAutoTyper.pressed:Connect(function()
	ui:createnotification({text = "Executed!", lifetime = 5, priority = 0})
  loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/realheckersbrother/UnpackedHub/refs/heads/main/Scripts/LastLetterAutoTyper.luau", true))()
end)
