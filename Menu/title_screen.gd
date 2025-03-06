extends Control

#start game
func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://WorldScenes/ButtonRoom.tscn")


#exit game
func buttonPressed() -> void:
	get_tree().quit()

#Settings
func _on_open_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu/Settings.tscn")
