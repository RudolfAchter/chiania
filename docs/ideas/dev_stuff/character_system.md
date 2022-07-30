# Character Species System

## Usage of class inheritance

I don't know how classes work now but here some ideas that could make life easier. We want support different species so character types could make great use of Class inheritance in python.

Code Examples would be:

- <https://github.com/RudolfAchter/chiania/blob/main/docs/ideas/dev_stuff/code/character_system.py>
- <https://github.com/RudolfAchter/chiania/blob/main/docs/ideas/dev_stuff/code/character_system.test.py>

```mermaid
classDiagram

    chianiaEntity <|-- chianiaChar
    chianiaEntity <|-- chianiaEnemy
    chianiaChar <|-- chianiaCharHuman
    chianiaChar <|-- chianiaCharIskai
    chianiaChar <|-- chianiaCharDwarf
    chianiaChar <|-- chianiaCharMarmot

    class chianiaEntity{
        +String species
        +String location
        +List body_parts
        +__init__(name, location)
        go()
    }

    class chianiaChar{
        +hunt()
        +attack()
        +go()
        +investigate()
        +get_json()
    }

    class chianiaCharHuman{
        +String species
        +String location
        +List body_parts
    }

    class chianiaCharIskai{
        +String species
        +String location
        +List body_parts
    }

    class chianiaCharDwarf{
        +String species
        +String location
        +List body_parts
    }

    class chianiaCharMarmot{
        +String species
        +String location
        +List body_parts
    }


    class chianiaEnemy{
        +attack()
        +get_json()
    }

```