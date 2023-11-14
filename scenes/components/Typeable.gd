class_name Typeable
extends Node2D

signal typed_word_same()

var word: String :
	set (value):
		word = value
		$TypeableWord.text = word;
	get:
		return word

func highlight_word(end: int):
	var fish_word_label: RichTextLabel = $TypeableWord
	fish_word_label.remove_paragraph(0)
	fish_word_label.push_color(Color.YELLOW)
	fish_word_label.append_text(word.substr(0, end))
	fish_word_label.pop()
	fish_word_label.append_text(word.substr(end, -1))

func reset_text():
	var fish_word_label: RichTextLabel = $TypeableWord
	fish_word_label.remove_paragraph(0)
	fish_word_label.append_text(word)

func _on_current_word_changed(current_word: String):
	if current_word == word:
		typed_word_same.emit()

	if word.begins_with(current_word):
		highlight_word(current_word.length())
	else:
		reset_text()
	return
