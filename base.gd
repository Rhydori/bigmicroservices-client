extends Control


func _on_send_pressed() -> void:
	Session.send_data(%Text.text)
