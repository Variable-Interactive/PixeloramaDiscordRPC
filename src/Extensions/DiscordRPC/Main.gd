extends Node

var api: Node
var item_id: int
var Discord_RPC

# This script acts as a setup for the extension
func _enter_tree() -> void:
	## NOTE: use get_node_or_null("/root/ExtensionsApi") to access api.
	api = get_node_or_null("/root/ExtensionsApi")
	var menu_type = api.menu.HELP

	item_id = api.menu.add_menu_item(menu_type, "Show Message", self)
	# the 3rd argument (in this case "self") will try to call "menu_item_clicked"
	# (if it is present)


func menu_item_clicked():
	# Do some stuff
	api.dialog.show_error("You Tickled Me :)")


func _exit_tree() -> void:  # Extension is being uninstalled or disabled
	# remember to remove things that you added using this extension
	api.menu.remove_menu_item(api.menu.HELP, item_id)


func _ready() -> void:
	## Load the class
	GDExtensionManager.load_extension("res://addons/discord-rpc-gd/bin/discord-rpc-gd.gdextension")
	if ClassDB.class_exists("DiscordRPC"):
		print("Initializing RPC")
		Discord_RPC = ClassDB.instantiate("DiscordRPC")

		## Set Discord parameters
		Discord_RPC.app_id = 1280532011810820156 # TODO Change with an official one -
		print("Discord working: " + str(Discord_RPC.get_is_discord_working()))
		Discord_RPC.details = tr("Just using Pixelorama")
		Discord_RPC.large_image = "pixelorama_large" # NOTE This is linked to the app_id (read the discord API Docs).
		Discord_RPC.small_image = "pixelorama_small" # NOTE This is linked to the app_id (read the discord API Docs).
		Discord_RPC.start_timestamp = int(Time.get_unix_time_from_system())
		Discord_RPC.refresh()


func  _process(_delta) -> void:
	if Discord_RPC:
		Discord_RPC.run_callbacks()
