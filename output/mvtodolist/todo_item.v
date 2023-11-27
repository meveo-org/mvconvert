module mvtodolist

@[table: 'todoitem']
struct TodoItem {
    uuid string [primary; sql_type: 'uuid']
    status ?string 
    todolist ?TodoList 
    value ?string 
}
