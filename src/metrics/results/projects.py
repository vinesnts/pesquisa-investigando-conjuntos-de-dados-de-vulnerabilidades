import pandas as pd

naa_chrome = pd.read_csv('../chromium/NAA/naa.csv', header=None, names=['hash', 'naa'])
naa_linux = pd.read_csv('../linux/NAA/naa.csv', header=None, names=['hash', 'naa'])
naa_ffmpeg = pd.read_csv('../ffmpeg/NAA/naa.csv', header=None, names=['hash', 'naa'])
naa_imagemagick = pd.read_csv('../ImageMagick/NAA/naa.csv', header=None, names=['hash', 'naa'])

pic_chrome = pd.read_csv('../chromium/PIC/pic.csv', header=None, names=['hash', 'pic'])
pic_linux = pd.read_csv('../linux/PIC/pic.csv', header=None, names=['hash', 'pic'])
pic_ffmpeg = pd.read_csv('../ffmpeg/PIC/pic.csv', header=None, names=['hash', 'pic'])
pic_imagemagick = pd.read_csv('../ImageMagick/PIC/pic.csv', header=None, names=['hash', 'pic'])

nea_chrome = pd.read_csv('../chromium/NEA/is-nea.csv', header=None, names=['hash', 'nea'])
nea_linux = pd.read_csv('../linux/NEA/is-nea.csv', header=None, names=['hash', 'nea'])
nea_ffmpeg = pd.read_csv('../ffmpeg/NEA/is-nea.csv', header=None, names=['hash', 'nea'])
nea_imagemagick = pd.read_csv('../ImageMagick/NEA/is-nea.csv', header=None, names=['hash', 'nea'])

projects = [{
    'name': 'Chrome',
    'naa': naa_chrome,
    'pic': pic_chrome,
    'nea': nea_chrome,
  }, {
    'name': 'Linux',
    'naa': naa_linux,
    'pic': pic_linux,
    'nea': nea_linux,
  }, {
    'name': 'FFmpeg',
    'naa': naa_ffmpeg,
    'pic': pic_ffmpeg,
    'nea': nea_ffmpeg,
  }, {
    'name': 'ImageMagick',
    'naa': naa_imagemagick,
    'pic': pic_imagemagick,
    'nea': nea_imagemagick,
  }
]