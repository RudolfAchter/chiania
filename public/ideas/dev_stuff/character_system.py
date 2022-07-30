
#Entity can be player or Monster

class chianiaEntity:
    species = "none"
    location = "none"
    body_parts = []
    def __init__(self, name, location):
        self.name = name
        self.location = location
    def go(direction):
        print(f"moving {direction}")
    

# a player character
class chianiaChar(chianiaEntity):
    def hunt():
        print(f"hunting")
    def get_json(self):
        body_parts=[]
        for part in self.body_parts:
            body_parts.append({
                "slot_type" : part.slot_type,
                "slot_count" : part.slot_count,
                "slot_free" : part.slot_free,
                "equipped" : part.equipped
            })
        out= {
            "species" : self.species,
            "location" : self.location,
            "body_parts" : body_parts
            }
        return out


class bodyPart:
    slot_type = ""
    slot_count = 0
    slot_free = 0
    equipped = []    
    def __init__(self, slot_type, count):
        self.slot_type=slot_type
        self.slot_count=count
        self.slot_free=count
        
# a player human
class chianiaCharHuman(chianiaChar):
    species = "human"
    location = "kingdom_street"
    body_parts = [
        bodyPart("head",1),
        bodyPart("arm",2),
        bodyPart("hand",2),
        bodyPart("torso",1),
        bodyPart("leg",2),
        bodyPart("foot",2),
        bodyPart("mount",1),
        bodyPart("familar",1)
    ]
    def __init__(self, name, location):
        self.name = name
        self.location = location

# iskai would be a type of cat / lion / tiger based character
# special woul be his tail which could equip a special weapon for it
class chianiaCharIskai(chianiaChar):
    species = "iska"
    location = "kingdom_street"
    body_parts = [
        bodyPart("head",1),
        bodyPart("arm",2),
        bodyPart("hand",2),
        bodyPart("torso",1),
        bodyPart("iskai_tail",1),
        bodyPart("leg",2),
        bodyPart("foot",2),
        bodyPart("mount",1)
    ]
    def __init__(self, name, location):
        self.name = name
        self.location = location