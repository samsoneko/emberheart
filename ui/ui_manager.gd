extends CanvasLayer

@onready var menus = {
	"genetic_menu" : $GeneticMenu,
	"player_menu" : $PlayerMenu,
	"dialogue" : $DialogueManager,
	"dungeon_menu" : $DungeonMenu,
	"item_menu" : $ItemsMenu,
	"mission_menu" : $MissionsMenu,
	"settings_menu" : $SettingsMenu,
	"notebook_menu" : $NotebookMenu,
	"team_menu" : $TeamMenu,
	"spirit_menu" : $SpiritMenu,
	"dungeon_floor_proceed_menu" : $DungeonFloorProceedMenu,
}

@onready var dungeon_hud = $DungeonHUD

var open_ui = "none"
var previous_ui = "none"

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.register_ui(self)
	if Global.show_dungeon_hud && open_ui == "none":
		dungeon_hud.open()

func _input(event):
	if event.is_action_pressed("menu") && open_ui == "none":
		go_to_menu("player_menu")
	elif event.is_action_pressed("cancel") && open_ui != "none":
		return_from_menu(open_ui)
	elif open_ui != "none":
		if event.is_action_pressed("ui_up") || event.is_action_pressed("ui_down") || event.is_action_pressed("ui_left") || event.is_action_pressed("ui_right"):
			AudioManager.ui_select.play()
		elif event.is_action_pressed("ui_accept"):
			AudioManager.ui_click.play()

func interaction_registered(menu):
	if open_ui == "none":
		go_to_menu(menu)
		if Global.show_dungeon_hud:
			dungeon_hud.close()

func go_to_menu(menu):
	if open_ui == "none":
		menus[menu].open()
		AudioManager.ui_enter_menu.play()
		open_ui = menu
		if Global.show_dungeon_hud:
			dungeon_hud.close()
	else:
		menus[open_ui].close()
		menus[menu].open()
		AudioManager.ui_enter_menu.play()
		previous_ui = open_ui
		open_ui = menu

func return_from_menu(menu):
	if menus[menu].ready_to_close():
		menus[menu].close()
		if previous_ui != "none":
			menus[previous_ui].open()
			AudioManager.ui_exit_menu.play()
			open_ui = previous_ui
			previous_ui = "none"
		else:
			open_ui = "none"
			if Global.show_dungeon_hud:
				dungeon_hud.open()
			AudioManager.ui_exit_menu.play()
	else:
		menus[menu].close_layer()
		AudioManager.ui_exit_menu.play()

func close_ui():
	if open_ui != "none":
		menus[open_ui].close()
		AudioManager.ui_exit_menu.play()
		open_ui = "none"
		if Global.show_dungeon_hud:
			dungeon_hud.open()

func update_ui():
	for menu in menus:
		menus[menu].update_ui()
	if Global.show_dungeon_hud:
		dungeon_hud.open()
	else: dungeon_hud.close()
