extends MenuPanel

var code_1 = [0, 0, 0, 0]
var code_2 = [0, 0, 0, 0]

# spirit variables
var spirit_candidate_1
var spirit_candidate_2
var spirit_preview
var spirit_result

# UI Elements
var spirit_card_resource = preload("res://ui/elements/spirit_card/spirit_card.tscn")

func update_ui():
	for spirit_card in $Panel/HSplitContainer/ScrollContainer/CandidateList.get_children():
		spirit_card.queue_free()
	for spirit in PlayerData.spirits:
		var spirit_card = spirit_card_resource.instantiate()
		spirit_card.spirit_selected.connect(spirit_selected)
		spirit_card.setup(spirit, SpiritCard.States.LISTITEM)
		$Panel/HSplitContainer/ScrollContainer/CandidateList.add_child(spirit_card)
	$Panel/HSplitContainer/ScrollContainer/CandidateList.get_child(0).grab_focus()

func spirit_selected(item):
	match item.state:
		SpiritCard.States.LISTITEM:
			candidate_selected(item)
		SpiritCard.States.PLACEHOLDER:
			candidate_unselected(item)
		SpiritCard.States.RESULT:
			spirit_created(item)

func _on_Fusion_clicked():
	if spirit_candidate_1 != null && spirit_candidate_2 != null:
		var new_dna = build_new_dna(spirit_candidate_1.spirit.dna, spirit_candidate_2.spirit.dna, spirit_candidate_1.spirit.dna_level, spirit_candidate_2.spirit.dna_level)
		print("Created new spirit")
		# Setup spirit in PlayerData
		var spirit = Spirit.new()
		spirit.setup_with_details(new_dna[0], new_dna[1])
		PlayerData.add_spirit(spirit)
		# Setup monster card in UI
		spirit_result = spirit_card_resource.instantiate()
		spirit_result.setup(spirit, SpiritCard.States.RESULT)
		$Panel/HSplitContainer/VBoxContainer/ResultSlot.add_child(spirit_result)
		spirit_result.spirit_selected.connect(spirit_selected)
		# Removing the old instances in the ui and in the PlayerData
		spirit_preview.queue_free()
		PlayerData.remove_spirit(spirit_candidate_1.spirit)
		PlayerData.remove_spirit(spirit_candidate_2.spirit)
		spirit_candidate_1.queue_free()
		spirit_candidate_2.queue_free()

func candidate_selected(spirit_card):
	if spirit_candidate_1 == null:
		print("Assigned candidate to slot 1")
		spirit_candidate_1 = spirit_card
		spirit_candidate_1.reparent($Panel/HSplitContainer/VBoxContainer/PH1Slot)
		spirit_candidate_1.set_state(SpiritCard.States.PLACEHOLDER)
	elif spirit_candidate_2 == null:
		print("Assigned candidate to slot 2")
		spirit_candidate_2 = spirit_card
		spirit_candidate_2.reparent($Panel/HSplitContainer/VBoxContainer/PH2Slot)
		spirit_candidate_2.set_state(SpiritCard.States.PLACEHOLDER)
	if spirit_candidate_1 != null && spirit_candidate_2 != null && spirit_preview == null:
		print("Generate preview")
		spirit_preview = spirit_card_resource.instantiate()
		$Panel/HSplitContainer/VBoxContainer/ResultSlot.add_child(spirit_preview)
		var preview_dna = build_new_dna(spirit_candidate_1.spirit.dna, spirit_candidate_2.spirit.dna, spirit_candidate_1.spirit.dna_level, spirit_candidate_2.spirit.dna_level)
		spirit_preview.setup_preview(preview_dna[0], preview_dna[1], SpiritCard.States.PREVIEW)

func candidate_unselected(spirit_card):
	if spirit_card == spirit_candidate_1:
		print("Removed candidate from slot 1")
		spirit_candidate_1 = null
	elif spirit_card == spirit_candidate_2:
		print("Removed candidate from slot 1")
		spirit_candidate_2 = null
	spirit_card.reparent($Panel/HSplitContainer/ScrollContainer/CandidateList)
	spirit_card.set_state(SpiritCard.States.LISTITEM)
	if spirit_preview != null:
		spirit_preview.queue_free()
		spirit_preview = null

func spirit_created(spirit_card):
	spirit_card.reparent($Panel/HSplitContainer/ScrollContainer/CandidateList)
	$Panel/HSplitContainer/ScrollContainer/CandidateList.queue_redraw()
	spirit_card.set_state(SpiritCard.States.LISTITEM)

func build_new_dna(dna_1, dna_2, level_1, level_2):
	var new_dna : Array[int] = [0, 0, 0, 0]
	var new_level : Array[int] = [0, 0, 0, 0]
	for i in 4:
		if level_1[i] > level_2[i]:
			new_dna[i] = dna_1[i]
			new_level[i] = level_1[i]
		elif level_2[i] > level_1[i]:
			new_dna[i] = dna_2[i]
			new_level[i] = level_2[i]
		else:
			match posmod((dna_1[i] - dna_2[i]), 3):
				1: # gene 1 has won
					new_dna[i] = dna_1[i]
					new_level[i] = level_1[i]
				0: # both are equal
					new_dna[i] = dna_1[i]
					new_level[i] = level_1[i] + 1
				_: # gene 2 has won
					new_dna[i] = dna_2[i]
					new_level[i] = level_2[i]
	return [new_dna, new_level]
