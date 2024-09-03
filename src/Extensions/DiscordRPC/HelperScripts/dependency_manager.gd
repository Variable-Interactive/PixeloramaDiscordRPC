extends Node

var to_path = "user://extensions/DiscordRPCFiles/"

var libraries = [
	"linux/libdiscord_game_sdk.so",
	"linux/libdiscord_game_sdk_binding.so",
	"linux/libdiscord_game_sdk_binding_debug.so",
	"macos/libdiscord_game_sdk.dylib",
	"macos/libdiscord_game_sdk_binding.dylib",
	"macos/libdiscord_game_sdk_binding_debug.dylib",
	"windows/discord_game_sdk.dll",
	"windows/discord_game_sdk_binding.dll",
	"windows/~discord_game_sdk_binding_debug.dll",
	"windows/discord_game_sdk_binding_debug.dll",
	"windows/discord_game_sdk_x86.dll",
]

func is_integrated():
	for path in libraries:
		if not FileAccess.file_exists(to_path.path_join(path)):
			return false
	return true


func extract_deps():
	var zip_reader := ZIPReader.new()
	var err := zip_reader.open("res://addons/discord-rpc-gd/bin/bin.zip")
	if err == OK:
		for path in libraries:
			var content = zip_reader.read_file(path)
			DirAccess.make_dir_recursive_absolute(to_path.path_join(path).get_base_dir())
			var file = FileAccess.open(to_path.path_join(path), FileAccess.WRITE)
			file.store_buffer(content)
			file.close()
