module mvtodolist

@[table: 'todoitem']
pub struct TodoItem {
    uuid string @[primary]
    value ?string 
    status ?string 
    todolist string 
}
