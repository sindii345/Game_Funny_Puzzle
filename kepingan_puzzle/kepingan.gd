extends TextureRect

func _get_drag_data(at_position):
	if texture == null:
		return null
		
	# Membuat bayangan transparan yang mengikuti mouse saat ditarik
	var preview = TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = size
	preview.modulate = Color(1, 1, 1, 0.7)
	
	var control = Control.new()
	preview.position = -0.5 * size
	control.add_child(preview)
	set_drag_preview(control)
	
	# Bawa data tekstur ini terbang ke papan atas
	return {"tekstur": texture, "node_sumber": self}
