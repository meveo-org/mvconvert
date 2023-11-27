module mvtodolist

import time

@[table: 'todolist']
pub struct TodoList {
    uuid string @[primary; sql_type: 'uuid']
    todoitems []TodoItem @[fkey:todolist]
    creationdate ?time.Time @[sql_type: 'TIMESTAMP']
    active ?bool 
    name string 
}
