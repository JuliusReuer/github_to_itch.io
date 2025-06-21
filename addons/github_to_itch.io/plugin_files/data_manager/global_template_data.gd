class_name GlobalTemplateData


static func get_version_info() -> Dictionary:
	var info = Engine.get_version_info()
	var version = str(info.major) + "." + str(info.minor)
	if info.patch != 0:
		version += "." + str(info.patch)

	return {version = version, status = info.status}


static func get_project_name() -> String:
	return ProjectSettings.get("application/config/name")


static func get_exports() -> Array[Dictionary]:
	var res: Array[Dictionary] = []
	var config := ConfigFile.new()
	config.load("res://export_presets.cfg")
	var needs_saving = false

	for section in config.get_sections():
		if config.has_section_key(section, "exclude_filter"):
			# Set addon to be excluded
			var exclude_filter: String = config.get_value(section, "exclude_filter", "")
			var parts = exclude_filter.split(",", false)
			if not "addons/github_to_itch.io/*" in parts:
				parts.append("addons/github_to_itch.io/*")
				exclude_filter = ",".join(parts)
				config.set_value(section, "exclude_filter", exclude_filter)
				needs_saving = true

		if config.get_value(section, "runnable", false):
			(
				res
				. append(
					{
						name = config.get_value(section, "name"),
						platform = config.get_value(section, "platform"),
						export_path = config.get_value(section, "export_path"),
					}
				)
			)

	if needs_saving:
		config.save("res://export_presets.cfg")

	return res
