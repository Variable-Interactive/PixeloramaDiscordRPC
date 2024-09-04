extends Node

var api: Node
var Discord_RPC

var status :StringName = ""
var is_animating :bool = false

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
		var discord_working: bool = Discord_RPC.get_is_discord_working()
		print("Discord working: " + str(discord_working))
		if not discord_working:
			api.dialog.show_error(
				str(
					"Error setting up Discord. Possible reasons are:\n",
					"1. Discord may not running.\n",
					"2. No Internet connection.\n",
					"3. You are using Flathub version of Discord\n",
					"4. You are using Flathub version of Pixelorama\n"
				)
			)
		Discord_RPC.large_image = "pixelorama_large"
		Discord_RPC.large_image_text = api.general.get_pixelorama_version()
		Discord_RPC.small_image = "project"
		Discord_RPC.start_timestamp = int(Time.get_unix_time_from_system())
		Discord_RPC.refresh()

		api.signals.signal_project_switched(project_changed)
		api.signals.signal_current_cel_texture_changed(drawing_status)
		api.general.get_global().animation_timeline.animation_started.connect(animation_started)
		api.general.get_global().animation_timeline.animation_finished.connect(animation_finished)


func  update_discord_rpc() -> void:
	if Discord_RPC:
		if is_animating:
			Discord_RPC.state = "Playing Animation..."
		else:
			Discord_RPC.state = status
		Discord_RPC.refresh()
		var layers = api.project.current_project.layers
		var layer_name = layers[api.project.current_project.current_layer].name
		var frame = api.project.current_project.current_frame
		status = "Layer (%s), Frame: %s" % [layer_name, str(frame + 1)]
		Discord_RPC.run_callbacks()


func _exit_tree() -> void:
	api.signals.signal_project_switched(project_changed, true)
	api.signals.signal_current_cel_texture_changed(drawing_status, true)
	api.general.get_global().animation_timeline.animation_started.disconnect(animation_started)
	api.general.get_global().animation_timeline.animation_finished.disconnect(animation_finished)
	api.dialog.show_error("Restart for the changes to take effect")


func project_changed():
	if Discord_RPC:
		var project_name = api.project.current_project.name
		Discord_RPC.details = tr("Editing Project: " + project_name)
		Discord_RPC.small_image_text = project_name
		Discord_RPC.refresh()


func drawing_status():
	status = "Drawing..."


func animation_started(farward: bool):
	is_animating = true


func animation_finished():
	is_animating = false
