from pprint import pprint

class chianiaItem:
  item_type = ""
  name = ""
  attributes = {}
  modifiers = {}
  def __init__(self, item_type, name, attributes):
    self.item_type = item_type
    self.name = name
    self.attributes = attributes
    

item = chianiaItem("Sword","Swort 01",{
    "Slash" : 2,
    "Pierce": 1
})

pprint(vars(item))

