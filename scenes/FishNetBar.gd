extends ProgressBar

func change_value(new_value):
	value = new_value

func _on_fish_net_power_changed(new_fish_net_power):
	var tween = create_tween()
	tween.tween_property(self, "value", new_fish_net_power, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(change_value.bind(new_fish_net_power))
