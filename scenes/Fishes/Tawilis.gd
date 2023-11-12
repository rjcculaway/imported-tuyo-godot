extends Node2D
class_name Tawilis

func _enter_tree():
	add_to_group("fishes", true)

func get_word(word_bank: Resource):
	var word = word_bank.get_long_word()
	$Typeable.word = word
