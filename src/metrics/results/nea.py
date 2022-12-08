import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

from projects import projects

for project in projects:
  nea = project['nea'][['nea']]

  ax = nea.value_counts().plot.pie(autopct='%1.2f%%', legend=True, labels=None)
  ax.get_yaxis().set_visible(False)
  ax.set_title(f"Métrica NEA - Projeto {project['name']}")
  print(nea.isna().sum())
  plt.savefig(f'nea-{project["name"]}.png')
  plt.close()