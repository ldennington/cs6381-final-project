import pandas as pd
import json
import os

# Create csv directory if it does not exist
if not os.path.exists('./csv'):
   os.makedirs('./csv')

files = [
  'cmd-out/1-pods-10000-read',
  'cmd-out/1-pods-100000-read',
  'cmd-out/1-pods-500000-read',
  'cmd-out/1-pods-10000-write',
  'cmd-out/1-pods-100000-write',
  'cmd-out/1-pods-500000-write',
  'cmd-out/3-pods-10000-read',
  'cmd-out/3-pods-100000-read',
  'cmd-out/3-pods-500000-read',
  'cmd-out/3-pods-10000-write',
  'cmd-out/3-pods-100000-write',
  'cmd-out/3-pods-500000-write',
  'cmd-out/5-pods-10000-read',
  'cmd-out/5-pods-100000-read',
  'cmd-out/5-pods-500000-read',
  'cmd-out/5-pods-10000-write',
  'cmd-out/5-pods-100000-write',
  'cmd-out/5-pods-500000-write',
]

for file in files:
  data = []
  with open(file) as f:
    for line in f:
      data.append(json.loads(line))

  df = pd.DataFrame (data)
  df.to_csv (f'csv/{os.path.basename(file)}.csv', index = None, mode='a')
