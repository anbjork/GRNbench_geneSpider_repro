
with open('gene_spider_methods_ls.txt', 'r') as file:
    lines = file.readlines()

methods = [
    line[::-1].split(sep = ' ')[0][::-1].split(sep = '.')[0]
    for line in lines]

methods = methods[4:]

import json
with open('gene_spider_methods.json', 'w', encoding='utf-8') as f:
    json.dump(methods, f, ensure_ascii=False, indent=4)


