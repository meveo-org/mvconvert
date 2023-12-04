import mvconvert
import os

fn main() {
	// Convert the module.json file to a v.mod file if he v.mod file does not exist
	if os.exists("module.json") && os.exists("facets") {
		mvconvert.convert_module(".", os.join_path('facets','v'))
	} else {
		println("cannot detect module.json and facets directory, skipping conversion")}
}