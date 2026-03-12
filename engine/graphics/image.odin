#+feature using-stmt
package graphics
import os "core:os"
import im "core:image"
import db "../database"



Image :: struct {
	url: db.URL,
	using image: im.Image }

// Get an image from the database by URL. If no such image exists, load it from file and add to the database. //
import_or_retreive_image :: proc(database: ^db.Database, url: db.URL) {
	
}


