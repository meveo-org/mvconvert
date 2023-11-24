module mvconvert

import os
import json

struct CustomField {
    code                        string
    description                 string
    field_type                   string [json: 'fieldType']
    account_level                ?string [json: 'accountLevel']
    applies_to                   string [json: 'appliesTo']
    default_value                ?string [json: 'defaultValue']
    use_inherited_as_default_value  bool   [json: 'useInheritedAsDefaultValue']
    storage_type                 string [json: 'storageType']
    value_required               bool   [json: 'valueRequired']
    versionable                 bool   [json: 'versionable']
    trigger_end_period_event       ?bool   [json: 'triggerEndPeriodEvent']
    allow_edit                   bool   [json: 'allowEdit']
    hide_on_new                   bool   [json: 'hideOnNew']
    max_value                    ?int    [json: 'maxValue']
    content_types                ?[]string
    file_extensions              ?[]string
    save_on_explorer              bool   [json: 'saveOnExplorer']
    gui_position                 ?string [json: 'guiPosition']
    identifier                  bool   [json: 'identifier']
    applicable_on_el              ?string [json: 'applicableOnEl']
    storages                    []string
    samples                     ?[]string
    summary                     bool   [json: 'summary']
    audited                     bool   [json: 'audited']
    persisted                   bool   [json: 'persisted']
    filter                      bool   [json: 'filter']
    unique                      bool   [json: 'unique']
}

struct SqlStorageConfiguration {
	store_as_table bool [json: 'storeAsTable']
}

struct CustomEntity {
    code string
    name string
    description string
    category_code ?string [json: 'customEntityCategoryCode']
    mut: fields []CustomField
    available_storages []string [json: "availableStorages" ]
    sql_storage_configuration SqlStorageConfiguration [json: "sqlStorageConfiguration" ]
    samples []string
    audited  bool
    module_name ?string
}

struct FileError {
    file_path string
    error string
}

// Parses a JSON file and returns a CustomEntity
fn parse_custom_entity(cetFilePath string, cft_dir string, module_name string) !CustomEntity {
    entity_json := os.read_file(cetFilePath) or { return err }
    mut entity := json.decode(CustomEntity, entity_json) or { return err  }

    // Now, read the fields
    fields_dir := os.join_path(cft_dir,'CE_$entity.code') 
    cft_json_files := os.ls(fields_dir) or { return err }
    mut fields := []CustomField{}
    for cft_json_file in cft_json_files {
        eprintln('Reading cft field $cft_json_file')
        field_json := os.read_file(os.join_path(fields_dir, cft_json_file)) or { return err }
        field := json.decode(CustomField, field_json) or { return error('Failed to decode field $cft_json_file : $err.msg()') }
        fields << field
    }
    entity.module_name = module_name
    entity.fields = fields
    return entity
}

// Generates a structure field definition with sql annotations for a given meveo custom field
fn generate_sql_field(field CustomField) string {
    mut field_type:='string'
    mut field_annotation:=''
    mut includes := []string{}
    match field.field_type {
        'SECRET' {
            field_type = 'string'
        }
        'STRING' {
            field_type = 'string'
        }
        'LIST' {
            field_type = 'string'
        }
        'LONG_TEXT' {
            field_type = 'string'
        }
        'INTEGER' {
            field_type = 'int'
        }
        'DATE' {
            field_type = 'time.Time'
            includes << 'time'
        }
        'LONG' {
            field_type = 'int64'
        }
        'DOUBLE' {
            field_type = 'float64'
        }
        'BOOLEAN' {
            field_type = 'bool'
        }
        'ENTITY' {
            field_type = 'string'
        }
        'CHILD_ENTITY' {
            field_type = 'string'
        }
        'BINARY' {
            field_type = 'string'
        }
        else {
            field_type = 'string'
        }
    }
    if !field.value_required {
        field_type = '?'+field_type
    }
    return '    $field.code $field_type $field_annotation\n'
}

// Generates a Vlang file containing structure with sql annotations for a given meveo custom entity
fn generate_vlang_file(entity CustomEntity, v_file_path string) ! {
    mut file_content := ''
    module_name := entity.module_name or { '' }
    if module_name.len > 0 {
        file_content = 'module $module_name\n\n'
    }  
    table_name := entity.code.replace('-', '_').replace(' ', '_').to_lower()   
    file_content += '@[table: \'$table_name\']\n'
    file_content += 'struct ${entity.code} {\n'
    file_content += '        uuid string\n'
    for field in entity.fields {
        // Assuming all fields are string for simplicity, you might need to adjust this
        file_content += generate_sql_field(field)
    }
    file_content += '}\n'

    os.write_file(v_file_path, file_content) or { return err }
}

fn convert_entities(cet_dir string, cft_dir string, target_dir string,module_name string) ![]FileError {

	files := os.ls(cet_dir) or { return error('Failed to list directory: $cet_dir') }
    mut errors := []FileError{}
    eprintln('files in  $cet_dir: $files')
	for cet_json_filename in files {
		if cet_json_filename.ends_with('.json') {
            eprintln('Reading cet file $cet_json_filename')
            cet_file_path := os.join_path(cet_dir, cet_json_filename)
            custom_entity := parse_custom_entity(cet_file_path, cft_dir, module_name) or {
				errors << FileError{cet_file_path, err.msg()}
				continue
            }
    
            v_base_filename := camel_to_snake(custom_entity.code)
			v_file_name := os.join_path(target_dir,  v_base_filename)+".v"
            generate_vlang_file(custom_entity, v_file_name) or {
                errors << FileError{v_file_name, err.msg()}
            }
		}
	}
    return errors
}
