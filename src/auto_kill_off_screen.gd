extends VisibleOnScreenNotifier2D

func _on_screen_exited() -> void:
	var parent = get_parent()
	if parent:
		parent.queue_free()
