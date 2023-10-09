import matplotlib.pyplot as plt
import pandas as pd
d = {}

# ticks pid tickets
with open('data.txt', encoding='utf-8') as data:
    procs = {}
    for i in range(50):
        procs[f'proc{i}'] = [0]
    for i in data:
        for j in range(50):
            procs[f'proc{j}'].append(
                procs[f'proc{j}'][len(procs[f'proc{j}'])-1])
        for j in range(50):
            if f' {j} ' in i:
                procs[f'proc{j}'][len(procs[f'proc{j}'])-1] += 1
                break
# df = pd.DataFrame([proc1, proc2],
#                   columns=['proc1', 'proc2'])
df = pd.DataFrame.from_dict(
    procs)
df.plot()
plt.savefig('myfile.jpg')
plt.show()
