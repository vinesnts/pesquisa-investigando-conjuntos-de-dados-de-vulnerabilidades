import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from projects import projects

def quantities(values):
  qtds = {}
  for v in values:
    try:
      v = int(v//10*10)
      if v not in qtds:
        qtds[v] = 0
      qtds[v] += 1
    except:
      pass
  return qtds

fig, ax = plt.subplots()
ax.set_title(f"Métrica PIC")
ax.set_xlabel('PIC (%)')
ax.set_ylabel('Qtd. de CVE')
ax.set_ylim([0,700])
ax.set_xlim([-10,110])

i = -3
for project in projects:
  pic = project['pic'][['pic']]
  qtds = quantities(pic['pic'])
  x = np.array(list(qtds.keys())) + i
  rect = ax.bar(x, list(qtds.values()), width=2, label=project['name'])
  ax.bar_label(rect)
  i += 2

ax.legend()
fig.tight_layout()
fig.set_figwidth(10)
fig.savefig('pic.png', dpi=150)
plt.close()