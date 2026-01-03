extends Resource
class_name Spirit

@export var id : int
@export var dna : Array[int] = [0, 0, 0, 0]
@export var dna_level : Array[int] = [1, 1, 1, 1]

@export var name : String

var body_texture : Texture
var head_texture : Texture
var legs_texture : Texture
var back_texture : Texture
var sprite_dir = "res://entities/spirits/sprites/"

func random_spirit_setup():
	for i in range(4):
		dna[i] = randi_range(0, 2)
	id = calculate_id()
	name = "Spirit " + str(id)
	load_icon()

func setup_with_details(setup_dna, setup_dna_level):
	dna = setup_dna
	dna_level = setup_dna_level
	id = calculate_id()
	name = "Spirit " + str(id)
	load_icon()

func load_icon():
	match dna[0]:
		0:
			body_texture = load(sprite_dir + "fire_body.png")
		1:
			body_texture = load(sprite_dir + "water_body.png")
		2:
			body_texture = load(sprite_dir + "plant_body.png")
	match dna[1]:
		0:
			head_texture = load(sprite_dir + "fire_head.png")
		1:
			head_texture = load(sprite_dir + "water_head.png")
		2:
			head_texture = load(sprite_dir + "plant_head.png")
	match dna[2]:
		0:
			legs_texture = load(sprite_dir + "fire_legs.png")
		1:
			legs_texture = load(sprite_dir + "water_legs.png")
		2:
			legs_texture = load(sprite_dir + "plant_legs.png")
	match dna[3]:
		0:
			back_texture = load(sprite_dir + "fire_back.png")
		1:
			back_texture = load(sprite_dir + "water_back.png")
		2:
			back_texture = load(sprite_dir + "plant_back.png")

func calculate_id():
	return 1*dna[3] + 3*dna[2] + 9*dna[1] + 27*dna[0]
