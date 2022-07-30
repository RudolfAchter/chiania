number=10
print(f"{number:02}")


for i in range(1,10):
    print(i)

"""" 
Wood_Club_list = ['Wood Club 01', 'Wood Club 02', 'Wood Club 03', 'Wood Club 04', 'Wood Club 05',
                  'Wood Club 06', 'Wood Club 07', 'Wood Club 08', 'Wood Club 09', 'Wood Club 10',
                  'Orange Nuclei Wood Club 01']
"""

Wood_Club_List = []
for i in range(1,11):
    Wood_Club_List.append(f"Wood Club {i:02}")
for i in range(1,2):
    Wood_Club_List.append(f"Orange Nuclei Wood Club {i:02}")
print(Wood_Club_List)


Enhanced_Tree_Root_List = []
for i in range(1,105):
    Enhanced_Tree_Root_List.append(f"Enhanced Tree Root {i:}")
print(Enhanced_Tree_Root_List)

