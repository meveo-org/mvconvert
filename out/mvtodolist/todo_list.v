module mvtodolist

@[table: 'todolist']
pub struct TodoList {
    uuid string @[primary;  sql_type: 'character varying(255)'; default: 'uuid_generate_v4()' ]
    todoitems []TodoItem @[fkey:todolist]
    creationdate string @[sql_type: 'timestamp without time zone'; default: 'CURRENT_TIMESTAMP']
    active ?bool 
    name string @[sql_type: 'character varying(255)']
}
