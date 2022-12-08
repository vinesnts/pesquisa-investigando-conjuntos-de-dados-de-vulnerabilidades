import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import trim_mean

from projects import projects

def categorize(values):
  naa_qtds = {0: 0, 1: 0, 2: 0, 3: 0}
  for i in values:
    if i == 0:
      naa_qtds[i] += 1
    elif i == 1:
      naa_qtds[i] += 1
    elif i == 2:
      naa_qtds[i] += 1
    elif i >= 3:
      naa_qtds[3] += 1
  return naa_qtds

def quantities(values):
  naa_qtds = {}
  for i in values:
    if i not in naa_qtds:
      naa_qtds[i] = 0
    naa_qtds[i] += 1
  return naa_qtds

cores = ['red', 'blue', 'green', 'orange']

for project in projects:
  naa = project['naa'][['naa']]

  print(f"Média: {np.mean(np.array(naa))}")
  print(f"Mediana: {np.median(np.array(naa))}")
  print(f"Máx.: {np.max(np.array(naa))}")
  print(f"Mín.: {np.min(np.array(naa))}")
  print(f"Média aparada.: {trim_mean(np.array(naa), 0.1)}")

  fig, ax = plt.subplots(1,1)
  ax.set_title(f"Métrica NAA - Projeto {project['name']}")

  naa_qtds = categorize(naa['naa'])
  print(naa_qtds)
  ax.pie(naa_qtds.values(), labels=[naa_qtds[i] for i in naa_qtds.keys()], colors=['#3388ff', '#FFBABA', '#FF7B7B', '#FF5252'])
  ax.legend([i if i < 3 else '3 ou mais' for i in naa_qtds.keys()], loc='lower right')
  plt.savefig(f'naa-{project["name"]}.png')
  plt.close()