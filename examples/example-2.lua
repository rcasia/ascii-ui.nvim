local ui = require("ascii-ui")
local Layout = ui.layout
local Select = ui.components.Select
local Slider = ui.components.Slider

ui.mount(Layout(
	Select({
		title = "Project",
		options = {
			"Gradle - Groovy",
			"Gradle - Kotlin",
			"Maven",
		},
	}),
	Select({
		title = "Language",
		options = {
			"Java",
			"Kotlin",
			"Groovy",
		},
	}),
	Select({
		title = "Spring Boot",
		options = {
			"3.5.0 (SNAPSHOT)",
			"3.4.3",
			"3.3.10",
		},
	}),
	Slider({ value = 50 })
))
