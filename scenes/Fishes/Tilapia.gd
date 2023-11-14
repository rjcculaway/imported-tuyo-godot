extends Node2D
class_name Tilapia

func _enter_tree():
	add_to_group("fishes", true)

func get_word(word_bank: Resource):
	var word = word_bank.get_medium_word()
	%Typeable.word = word
