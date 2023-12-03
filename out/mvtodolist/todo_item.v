module mvtodolist

@[table: 'todoitem']
pub struct TodoItem {
    uuid string @[primary;  sql_type: 'character varying(255)'; default: 'uuid_generate_v4()' ]
    value ?string @[sql_type: 'character varying(255)']
    status ?string @[ default: '\'NOT_STARTED\'']
    todolist string
}
