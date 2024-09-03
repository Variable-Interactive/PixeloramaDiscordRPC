extends Node

var api: Node
var Discord_RPC


# This script acts as a setup for the extension
func _enter_tree() -> void:
	api = get_node_or_null("/root/ExtensionsApi")
	if not $DependencyManager.is_integrated():
		$DependencyManager.extract_deps()
	if $DependencyManager.is_integrated():
		start_discord_rpc()


func start_discord_rpc() -> void:
	## Load the class
	GDExtensionManager.load_extension("res://addons/discord-rpc-gd/bin/discord-rpc-gd.gdextension")
	if ClassDB.class_exists("DiscordRPC"):
		print("Initializing RPC")
		Discord_RPC = ClassDB.instantiate("DiscordRPC")

		## Set Discord parameters
		Discord_RPC.app_id = 1280532011810820156 # TODO Change with an official one -
		print("Discord working: " + str(Discord_RPC.get_is_discord_working()))
		if not Discord_RPC.get_is_discord_working():
			api.dialog.show_error("Error setting up Discord. Either discord is not running or you may using a flathub version")
		Discord_RPC.large_image = "pixelorama_large" # NOTE This is linked to the app_id (read the discord API Docs).
		Discord_RPC.large_image_text = "" # NOTE This is linked to the app_id (read the discord API Docs).
		Discord_RPC.small_image = "project" # NOTE This is linked to the app_id (read the discord API Docs).
		Discord_RPC.start_timestamp = int(Time.get_unix_time_from_system())
		Discord_RPC.refresh()
		api.signals.signal_project_switched(project_changed)


func _exit_tree() -> void:
	api.dialog.show_error("Restart for the changes to take effect")


func project_changed():
	if Discord_RPC:
		var project_name = api.project.current_project.name
		Discord_RPC.details = tr("Editing Project: " + project_name)
		Discord_RPC.small_image_text = project_name
		Discord_RPC.refresh()


func  update_discord_rpc() -> void:
	if Discord_RPC:
		Discord_RPC.run_callbacks()
