module mvtodolist

@[table: 'todoitem']
struct TodoItem {
        uuid string
    status ?string 
    value ?string 
}
