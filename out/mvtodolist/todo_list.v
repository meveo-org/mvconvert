module mvtodolist

@[table: 'todolist']
pub struct TodoList {
    uuid string @[primary]
    todoitems []TodoItem @[fkey:todolist]
    creationdate string @[default: 'CURRENT_TIMESTAMP';sql_type: 'TIMESTAMP']
    active ?bool 
    name string 
}
