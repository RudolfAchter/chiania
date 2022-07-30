from pprint import pprint
import json
import jsonpickle
import inspect
import character_system



character = character_system.chianiaCharHuman("rudi","kingdom_street")
print(json.dumps(character.get_json(), indent=4))



character = character_system.chianiaCharHuman("Iskai Test 01","kingdom_street")
print(json.dumps(character.get_json(), indent=4))
