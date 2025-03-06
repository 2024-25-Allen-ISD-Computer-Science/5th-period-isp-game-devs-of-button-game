extends Button


func _ready():
	$"../../VBoxContainer/music slider".value = db_to_linear(AudioServer.get_bus_volume_db(0))

#exit settings
func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu/title_screen.tscn")


func _on_h_slider_mouse_exited() -> void:
	release_focus()




func _on_confirm_settings_pressed() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db($"../../VBoxContainer/music slider".value))
