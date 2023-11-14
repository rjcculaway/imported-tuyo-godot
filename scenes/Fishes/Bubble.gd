extends Node2D


func _enter_tree():
	add_to_group("bubbles", true)

func get_word(word_bank: Resource):
	var word = word_bank.get_short_word()
	$Typeable.word = word