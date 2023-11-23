module mvconvert

import os
import json

struct ModuleData {
	code                string
	description         string
	license             string
	current_version     string   [json: currentVersion]
	is_in_draft         bool     [json: isInDraft]
	auto_commit         bool     [json: autoCommit]
	module_dependencies []string [json: moduleDependencies]
	module_files        []string [json: moduleFiles]
}

fn create_vmod_content(data ModuleData) string {
	mut deps := '['
	for dep in data.module_dependencies {
		deps += "'${dep}', "
	}
	if data.module_dependencies.len > 0 {
		deps = deps[..deps.len - 2] // remove trailing comma and space
	}
	deps += ']'

	return '
Module {
    name: "${data.code}"
    description: "${data.description}"
    version: "${data.current_version}"
    license: "${data.license}"
    dependencies: ${deps}
}'
}

fn convert_module_config(module_json_path string, v_mod_path string) {
	// Read the module.json file
	module_json_bytes := os.read_file(module_json_path) or {
		println('Failed to read module.json')
		return
	}

	// Parse the JSON data
	module_data := json.decode(ModuleData, module_json_bytes) or {
		eprintln('Failed to decode JSON: ${err}')
		return
	}

	vmod_content := create_vmod_content(module_data)

	os.write_file(v_mod_path, vmod_content) or {
		eprintln('Failed to write v.mod file: ${err}')
		return
	}
}

pub fn convert_module(meveo_module_path string, v_module_path string) {
	module_json_path := meveo_module_path + '/module.json'
	v_mod_path := v_module_path + '/v.mod'

	// Convert module.json to v.mod
	convert_module_config(module_json_path, v_mod_path)

	// TODO: convert the custom entities

	// TODO: convert the Rest endpoints
	println('Conversion completed successfully!')
}
