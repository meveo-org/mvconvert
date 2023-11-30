module mvconvert

import os
import json

struct CustomField {
    code                        string
    description                 string
    field_type                   string @[json: 'fieldType']
    account_level                ?string @[json: 'accountLevel']
    applies_to                   string @[json: 'appliesTo']
    default_value                ?string @[json: 'defaultValue']
    use_inherited_as_default_value  bool   @[json: 'useInheritedAsDefaultValue']
    storage_type                 string @[json: 'storageType']
    value_required               bool   @[json: 'valueRequired']
    versionable                 bool   @[json: 'versionable']
    trigger_end_period_event       ?bool   @[json: 'triggerEndPeriodEvent']
    entity_class                  ?string @[json: 'entityClazz']
    allow_edit                   bool   @[json: 'allowEdit']
    hide_on_new                   bool   @[json: 'hideOnNew']
    max_value                    ?int    @[json: 'maxValue']
    content_types                ?[]string
    file_extensions              ?[]string
    save_on_explorer              bool   @[json: 'saveOnExplorer']
    gui_position                 ?string @[json: 'guiPosition']
    identifier                  bool   @[json: 'identifier']
    applicable_on_el              ?string @[json: 'applicableOnEl']
    storages                    []string
    samples                     ?[]string
    summary                     bool   @[json: 'summary']
    audited                     bool   @[json: 'audited']
    persisted                   bool   @[json: 'persisted']
    filter                      bool   @[json: 'filter']
    unique                      bool   @[json: 'unique']
}

struct SqlStorageConfiguration {
	store_as_table bool @[json: 'storeAsTable']
}

struct CustomEntity {
    code string
    name string
    description string
    category_code ?string @[json: 'customEntityCategoryCode']
    mut: fields []CustomField
    available_storages []string @[json: "availableStorages" ]
    sql_storage_configuration SqlStorageConfiguration @[json: "sqlStorageConfiguration" ]
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
// return the field definition and necessary includes
fn generate_sql_field(field CustomField) (string, string) {
    mut field_type:='string'
    mut sql_type:='varchar'
    mut field_annotation:=''
    mut field_annotations := []string{}
    mut include := ''
    match field.field_type {
        'SECRET' {
            field_type = 'string'
            sql_type =''
        }
        'STRING' {
            field_type = 'string'
            max_value := field.max_value or {255}
            sql_type ='character varying('+max_value.str()+')'
        }
        'LIST' {
            field_type = 'string'
            sql_type =''
        }
        'LONG_TEXT' {
            field_type = 'string'
            sql_type ='text'
        }
        'INTEGER' {
            field_type = 'int'
            sql_type =''
        }
        'DATE' {
            field_type = 'string'
            sql_type ='timestamp without time zone'
            if field.default_value or {''} == 'now()' {
                field_annotations << 'default: \'CURRENT_TIMESTAMP\''
            }
            //include = 'time'
        }
        'LONG' {
            field_type = 'i64'
            sql_type ='bigint'
        }
        'DOUBLE' {
            field_type = 'float64'
            sql_type =''
        }
        'BOOLEAN' {
            field_type = 'bool'
            sql_type =''
        }
        'ENTITY' {
            field_class := field.entity_class or { '' }
            target_entity := field_class.split(' ')[2]
            if field.storage_type == 'LIST' {
                field_type = '[]'
                field_annotations << 'fkey:'+field.applies_to.trim_left('CE_').to_lower()
            } else {
                return '    ${field.code.to_lower()} string',include
            }
            field_type += target_entity
            sql_type =''
        }
        'CHILD_ENTITY' {
            field_type = 'string'
            sql_type =''
        }
        'BINARY' {
            field_type = 'string'
            sql_type =''
        }
        else {
            field_type = 'string'
            sql_type =''
        }
    }
    print('field_type: $field_type')
    
    // see https://github.com/vlang/v/issues/20013 and https://github.com/vlang/v/issues/20014 
    if (!field.value_required) && (field_type != 'time.Time') && (field.field_type != 'ENTITY'){
        field_type = '?'+field_type
    }

    /*
        [primary] sets the field as the primary key
        [unique] sets the field as unique
        [unique: 'foo'] adds the field to a unique group
        [skip] or [sql: '-'] field will be skipped
        [sql: type] where type is a V type such as int or f64
        [sql: serial] lets the DB backend choose a column type for a auto-increment field
        [sql: 'name'] sets a custom column name for the field
        [sql_type: 'SQL TYPE'] sets the sql type which is used in sql
        [default: 'raw_sql] inserts raw_sql verbatim in a "DEFAULT" clause whencreate a new table, allowing for values like CURRENT_TIME- [fkey: 'parent_id'] sets foreign key for an field which holds an array
    */
    if sql_type.len > 0 { 
        field_annotations <<'sql_type: \'$sql_type\'' 
    } 
    if field.unique {
        field_annotations << ' unique'
    }
    if !field.persisted {
        field_annotations << ' skip'
    }
    default_value := field.default_value or {''}
    if default_value.len > 0 {
        field_annotations << ' default: \''+default_value+'\''
    }

    if field_annotations.len>0 {
        field_annotation= '@['+field_annotations.join(';')+']'
    }

    return '    ${field.code.to_lower()} $field_type $field_annotation',include
}

// Generates a Vlang file containing structure with sql annotations for a given meveo custom entity
fn generate_vlang_file(entity CustomEntity, v_file_path string) ! {
    mut file_content := ''
    module_name := entity.module_name or { '' }
    if module_name.len > 0 {
        file_content = 'module $module_name\n\n'
    }  
    mut includes := ''
    mut fields_declaration := []string{}
    for field in entity.fields {
        mut field_declaration := ''
        mut include := '' 
        field_declaration,include = generate_sql_field(field)
        fields_declaration << field_declaration
        //FIXME test if include not already present
        if include.len >0 {
            includes += 'import '+include+'\n'
        }
    }
    table_name := entity.code.replace('-', '_').replace(' ', '_').to_lower()  
    if includes.len>0 {
        file_content += includes+'\n'
    }
    file_content += '@[table: \'$table_name\']\n'
    file_content += 'pub struct ${entity.code} {\n'
    file_content += '    uuid string @[primary;  sql_type: \'character varying(255)\'; default:\'uuid_generate_v4()\']\n'
    for field_declaration in fields_declaration {
        file_content += field_declaration+'\n'
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
