extends Node2D

class_name Goldfish

func _enter_tree():
	add_to_group("fishes", true)

func get_word(word_bank: Resource):
	var word = word_bank.get_short_word()
	$Fish.word = word