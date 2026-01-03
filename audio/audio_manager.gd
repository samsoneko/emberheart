extends Node

@onready var osts = {
	"ost_lagoon" : $ost_lagoon,
	"ost_deeper_woods" : $ost_deeper_woods
}

@onready var ui_select = $ui_select
@onready var ui_enter_menu = $ui_enter_menu
@onready var ui_exit_menu = $ui_exit_menu
@onready var ui_click = $ui_click

func start_ost(ost_name):
	if osts.has(ost_name):
		osts[ost_name].play()

func stop_ost(ost_name):
	if osts.has(ost_name):
		if osts[ost_name].playing:
			osts[ost_name].stop()
