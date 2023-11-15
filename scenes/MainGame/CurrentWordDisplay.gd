extends Label

func _on_current_word_changed(new_word: String) -> void:
	text = new_word
	return