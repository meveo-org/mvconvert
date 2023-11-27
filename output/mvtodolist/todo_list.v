module mvtodolist

import time

@[table: 'todolist']
struct TodoList {
    uuid string [primary; sql_type: 'uuid']
    active ?bool 
    creationdate ?time.Time [sql_type: 'TIMESTAMP']
    name string 
    todoitems ?[]TodoItem [fkey:todolist]
}
