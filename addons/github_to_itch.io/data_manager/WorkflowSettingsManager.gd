class_name WorkflowSettingsManager

const SHOW_WELCOME = "github_to_itch.io/config/show_welcome"

const GITHUB_TO_ITCH_ENABLED: String = "github_to_itch.io/config/github_to_itch_io/enabled"
const GITHUB_TO_ITCH_USER: String = "github_to_itch.io/config/github_to_itch_io/itch_username"
const GITHUB_TO_ITCH_PROJECT: String = "github_to_itch.io/config/github_to_itch_io/itch_project_name"

const DISCORD_ENABLED: String = "github_to_itch.io/config/discord/enabled"

const LINT_CHECK_ENABLED: String = "github_to_itch.io/config/linting_check/enabled"
const LINT_CHECK_FOLDER: String = "github_to_itch.io/config/linting_check/folder"

const FORMAT_CHECK_ENABLED: String = "github_to_itch.io/config/format_check/enabled"
const FORMAT_CHECK_FOLDER: String = "github_to_itch.io/config/format_check/folder"


static func _init_setting(name: String, init_value, type: int, hint: int = PROPERTY_USAGE_NONE):
	if not ProjectSettings.has_setting(name):
		ProjectSettings.set_setting(name, init_value)
		ProjectSettings.add_property_info({name = name, type = type, hint = hint})


static func init():
	_init_setting(SHOW_WELCOME, true, TYPE_BOOL)

	_init_setting(GITHUB_TO_ITCH_ENABLED, false, TYPE_BOOL)
	_init_setting(GITHUB_TO_ITCH_USER, "", TYPE_STRING)
	_init_setting(GITHUB_TO_ITCH_PROJECT, "", TYPE_STRING)

	_init_setting(DISCORD_ENABLED, false, TYPE_BOOL)

	_init_setting(LINT_CHECK_ENABLED, false, TYPE_BOOL)
	_init_setting(LINT_CHECK_FOLDER, "res://scripts", TYPE_STRING, PROPERTY_HINT_DIR)

	_init_setting(FORMAT_CHECK_ENABLED, false, TYPE_BOOL)
	_init_setting(FORMAT_CHECK_FOLDER, "res://scripts", TYPE_STRING, PROPERTY_HINT_DIR)


static var _check_result: bool


static func _check_setting(setting: String):
	if not ProjectSettings.has_setting(setting):
		_check_result = false


static func check():
	_check_result = true
	_check_setting(GITHUB_TO_ITCH_ENABLED)
	_check_setting(GITHUB_TO_ITCH_USER)
	_check_setting(GITHUB_TO_ITCH_PROJECT)

	_check_setting(DISCORD_ENABLED)

	_check_setting(LINT_CHECK_ENABLED)
	_check_setting(LINT_CHECK_FOLDER)

	_check_setting(FORMAT_CHECK_ENABLED)
	_check_setting(FORMAT_CHECK_FOLDER)
	return _check_result
