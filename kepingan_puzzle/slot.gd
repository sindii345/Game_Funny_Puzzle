extends TextureRect

# Kolom ini akan muncul di Inspector untuk diisi kunci jawaban gambar
@export var gambar_jawaban: Texture2D

func _can_drop_data(at_position, data):
	# Izinkan drop selama yang ditarik punya tekstur dan slot ini masih kosong
	if typeof(data) == TYPE_DICTIONARY and data.has("tekstur") and texture == null:
		return true
	return false

func _drop_data(at_position, data):
	# 1. Langsung tempelkan kepingannya, entah itu benar atau salah
	self.texture = data["tekstur"]
	data["node_sumber"].texture = null
	
	# 2. Panggil fungsi di game_play untuk menambah jumlah kepingan terpasang
	get_tree().current_scene.kepingan_berhasil_dipasang()

# Fungsi ini akan dipanggil oleh game_play.gd saat SEMUA slot sudah penuh
func apakah_kepingan_benar() -> bool:
	if texture != null:
		# Mengecek apakah gambar yang sedang menempel sama dengan kunci jawaban
		return texture == gambar_jawaban
	return false
