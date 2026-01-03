extends Control
class_name SpiritCard

var spirit : Spirit

enum States {LISTITEM, PLACEHOLDER, PREVIEW, RESULT}
var state = States.LISTITEM

signal spirit_selected(spirit)

func setup(spirit_reference, st):
	spirit = spirit_reference
	$Panel/Name.text = spirit_reference.name
	$Panel/BodyIcon.texture = spirit_reference.body_texture
	$Panel/HeadIcon.texture = spirit_reference.head_texture
	$Panel/LegsIcon.texture = spirit_reference.legs_texture
	$Panel/BackIcon.texture = spirit_reference.back_texture
	for i in 4:
		set_gene(spirit_reference.dna[i], i)
	for j in 4:
		set_level(spirit_reference.dna_level[j], j)
	set_state(st)

func setup_preview(dna, dna_level, st):
	for i in 4:
		set_gene(dna[i], i)
	for j in 4:
		set_level(dna_level[j], j)
	$Panel/BodyIcon.texture = load("res://entities/monsters/sprites/unknown.png")
	$Panel/Name.text = "?"
	set_state(st)

func set_state(st):
	state = st
	if state == States.LISTITEM:
		$Panel/Button.text = ">"
	elif state == States.PLACEHOLDER:
		$Panel/Button.text = "X"
	elif state == States.PREVIEW:
		$Panel/Button.text = ""
	elif state == States.RESULT:
		$Panel/Button.text = "<"
	position = Vector2.ZERO

func _on_item_clicked():
	spirit_selected.emit(self)

func set_gene(gene : int, index : int):
	if gene == 0:
		get_node("Panel/GeneDisplay/Gene" + str(index+1)).texture = load("res://ui/elements/ui_icons_8x8/icon_sword.tres")
	elif gene == 1:
		get_node("Panel/GeneDisplay/Gene" + str(index+1)).texture = load("res://ui/elements/ui_icons_8x8/icon_shield.tres")
	elif gene == 2:
		get_node("Panel/GeneDisplay/Gene" + str(index+1)).texture = load("res://ui/elements/ui_icons_8x8/icon_magic.tres")

func set_level(level : int, index : int):
	get_node("Panel/LevelDisplay/Level" + str(index+1)).texture = load("res://ui/elements/level_" + str(level) + ".png")
