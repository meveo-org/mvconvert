module mvconvert

import os
import json

struct ModuleData {
	mut: code                string
	description         string
	license             ?string
	current_version     string   @[json: currentVersion]
	is_in_draft         bool     @[json: isInDraft]
	auto_commit         bool     @[json: autoCommit]
	module_dependencies ?[]string @[json: moduleDependencies]
	module_files        ?[]string @[json: moduleFiles]
}

fn ensure_directory_exists(dir_path string) {
    if !os.exists(dir_path) {
        os.mkdir_all(dir_path) or {
            eprintln('Failed to create directory: $err')
            return
        }
    }
}

fn create_vmod_content(data ModuleData) string {
	mut deps := '['
	for dep in data.module_dependencies {
		deps += "'${dep}', "
	}
	if (data.module_dependencies or { []string{} }).len > 0 {
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

fn convert_module_config(module_json_path string, v_facet_path string) !string {
	// Read the module.json file
	module_json_bytes := os.read_file(module_json_path) or {
		return error('Failed to read module.json')
	}

	// Parse the JSON data
	mut module_data := json.decode(ModuleData, module_json_bytes) or {
		return error('Failed to decode JSON: $err')
	}
	module_data.code = module_data.code.replace('-', '').replace('_', '').to_lower()

	v_module_path := os.join_path(v_facet_path, module_data.code)
    // Ensure the directory exists
    ensure_directory_exists(v_module_path)

	v_mod_path := os.join_path(v_module_path,"v.mod")
	vmod_content := create_vmod_content(module_data)

	os.write_file(v_mod_path, vmod_content) or {
		return error('Failed to write v.mod file: $err')
	}

	return module_data.code
}

pub fn convert_module(meveo_module_path string, v_facet_path string) {
	module_json_path := os.join_path(meveo_module_path,'module.json')


	// Convert module.json to v.mod
	module_name := convert_module_config(module_json_path, v_facet_path) or {
		eprintln('Failed to convert module.json to v.mod: ${err}')
		return
	}
	
	v_module_path := os.join_path(v_facet_path, module_name)
	cet_dir := 'customEntityTemplates'
	cft_dir := 'customFieldTemplates'

	// convert custom entities
	result,entities := convert_entities(cet_dir, cft_dir, v_module_path,module_name) or {
        assert false, 'Function failed: $err'
		[]FileError{},[]CustomEntity{}
    }
    eprintln('convert_entities result: $result')

	// create configuration files
	config_file_path:=create_config_files(v_facet_path) or {
		eprintln('Failed to create configuration files: ${err}')
		return
	}
	//append config_file_path to .gitignore content if not already present
	gitignore_path := '.gitignore'
	mut gitignore_content := os.read_file(gitignore_path) or {
		eprintln('Failed to read .gitignore file: ${err}')
		return
	}

	if gitignore_content.index(config_file_path)  or { -1 } == -1 {
		gitignore_content += '\n' + config_file_path
		os.write_file(gitignore_path, gitignore_content) or {
			eprintln('Failed to write .gitignore file: ${err}')
			return
		}
	}

	

	// create db file
	create_db_file(entities,v_facet_path,module_name) or {
		eprintln('Failed to create db file: ${err}')
		return
	}

	// TODO: convert the Rest endpoints
	println('Conversion completed successfully!')
}
