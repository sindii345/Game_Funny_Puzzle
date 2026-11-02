extends Node

var level_terbuka: int = 1 # Hanya level 1 yang terbuka di awal
var level_pilihan: int = 1 # Menyimpan level yang diklik pemain

# Menyimpan skor bintang untuk level 1, 2, dan 3
var bintang_level: Dictionary = {
	1: 0,
	2: 0,
	3: 0
}
