class_name WorkflowTemplate

var _template_path: String
var _export_path: String


func _init(template_path: String, export_path: String) -> void:
	_template_path = template_path
	_export_path = export_path


func save():
	var workflow_directory = _export_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(workflow_directory):
		DirAccess.make_dir_recursive_absolute(workflow_directory)

	var file = FileAccess.open(_export_path, FileAccess.WRITE)
	file.store_string(_generate_workflow_string())


func get_export_specific_data() -> Dictionary[String,String]:
	var version_info = GlobalTemplateData.get_version_info()
	var godot_path = version_info.version

	if version_info.status != "stable":
		godot_path += "/" + version_info.status

	return {
		PROJECT_NAME = GlobalTemplateData.get_project_name(),
		GODOT_VERSION = version_info.version,
		GODOT_STATUS = version_info.status,
		GODOT_PATH = godot_path,
	}


func get_yml_section_data(yml_string: String) -> Dictionary:
	var res = {}
	var lines:PackedStringArray = yml_string.split("\n")
	var last_begin = 0
	var begin_line = ""
	
	var subsections = []
	var sub_begin = 0
	for line_id in len(lines):
		var line:String = lines[line_id].replace("\t","  ")
		if line.strip_edges().is_empty():
			continue
		if line.begins_with(" ") or line.begins_with("{"):
			if line.begins_with("{"):
				continue

			if len(subsections) > 0:
				subsections[len(subsections)-1]["end"] = line_id -1

			if !line.substr(1).begins_with(" "):
				var name = line.strip_edges()
				if ":" in name:
					name = name.split(":")[0].strip_edges()
				subsections.append({"name":name,"begin":line_id,"end":0})
			continue
		if !begin_line.is_empty():
			if len(subsections) > 0:
				subsections[len(subsections)-1]["end"] = line_id - 1
			res.set(begin_line, {"begin": last_begin, "end": line_id, "sub":subsections })
			subsections = []
		last_begin = line_id
		begin_line = line
	res.set(begin_line, {"begin": last_begin, "end": len(lines), "sub":subsections})
	return res

func generate_sections(text:String,section_data)->PackedStringArray:
	var sections = []
	for data in section_data["sub"]:
		sections.append(generate_section(text,data["begin"] + 1,data["end"]))
	return PackedStringArray(sections)

func generate_section(text: String, start: int, end: int):
	var lines = text.split("\n")
	var res = []
	for i in range(start, end):
		res.append(lines[i])
	return "\n".join(res)


func _extend(original: String, cwd: String) -> Dictionary[String,String]:
	var work_value = original.substr(8)
	var path = work_value.split("\n")[0].strip_edges()
	var file := FileAccess.open(cwd.path_join(path), FileAccess.READ)
	var file_template = file.get_as_text() #The files that was Extended from

	var orginal_sections = get_yml_section_data(original) # The sections of the Extension
	var template = get_yml_section_data(file_template) # The sections of the base
	
	#region get Merge Sequence
	var filterComments = func(arr:Array):
		return arr.filter(func(item:String): return !item.strip_edges().begins_with('#'));

	var mod:Array = filterComments.call(orginal_sections.keys())

	var sequence:Array = filterComments.call(template.keys()).duplicate();
	var seen = sequence.duplicate();

	# Insert elements from modifier that are not yet in result
	for item in mod:
		if seen.has(item):
			continue

		# Find the next element from modifier that *is* in result
		var next:String = ""
		for element in mod.slice(mod.find(item) + 1):
			if seen.has(element):
				next = element
				break

		if next:
			var index = sequence.find(next);
			sequence.insert(index, item);  # insert before next
		else:
			sequence.append(item);  # append at end if no next found
		seen.append(item)
	#endregion

	var sections:Array[String] = []
	for key in sequence:
		if orginal_sections.has(key):
			if template.has(key):
				var sub_keys:Array[String] = []
				for sub_key in template[key]["sub"]:
					sub_keys.append(sub_key["name"])
					
				for sub_key in orginal_sections[key]["sub"]:
					if !sub_keys.has(sub_key["name"]):
						sub_keys.append(sub_key["name"])
				
				var sub_sections:Array[String] = [key]
				for sub_key in sub_keys:
					var o = orginal_sections[key]["sub"].find_custom(func(data):return data["name"] == sub_key)
					if o != -1:
						sub_sections.append(generate_section(original,orginal_sections[key]["sub"][o]["begin"],orginal_sections[key]["sub"][o]["end"]+1))
						continue
					var t = template[key]["sub"].find_custom(func(data):return data["name"] == sub_key)
					if t != -1:
						sub_sections.append(generate_section(file_template,template[key]["sub"][t]["begin"],template[key]["sub"][t]["end"]+1))
				sections.append("\n".join(sub_sections))
			else:
				sections.append(generate_section(original,orginal_sections[key]["begin"],orginal_sections[key]["end"]))
		else:
			sections.append(generate_section(file_template,template[key]["begin"],template[key]["end"]))

	return {
		"content": "\n\n".join(sections), "cwd": cwd.path_join(path).get_base_dir()
	}

func _format_result(orginal:String):
	var original_lines:PackedStringArray = orginal.split("\n")
	var trimed_lines:Array[String] = []
	for line in original_lines:
		line = line.strip_edges(false,true)
		trimed_lines.append(line)
	var trimed_text = "\n".join(trimed_lines)
	while "\n\n\n" in trimed_text:
		trimed_text = trimed_text.replace("\n\n\n","\n\n")
	return trimed_text

func _generate_workflow_string() -> String:
	var file := FileAccess.open(_template_path, FileAccess.READ)
	var workflow_template = file.get_as_text()

	var cwd = _template_path.get_base_dir()
	while workflow_template.begins_with("#extends"):
		var obj = _extend(workflow_template, cwd)
		workflow_template = obj["content"]
		cwd = obj["cwd"]

	var specific_data: Dictionary = get_export_specific_data()
	var resulting_file = workflow_template.replace("\t", "    ").format(specific_data)
	return _format_result(resulting_file)
