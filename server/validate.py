#!/usr/bin/env python3

import sys
import base64
import json

level = sys.argv[1]
score = sys.argv[2]
verification = sys.argv[3]

def cost(palette):
    cost = 0
    count = 0
    for item in palette:
        cost += len(item["text"])
        count += 1

    if count > 0:
        cost += 1
    if count > 2:
        cost += 1
    if count > 4:
        cost += 1
    return cost


level_json = open("default_levels.json","r").read()
levels = json.loads(level_json)
raw_text = base64.b64decode(levels[str(level)].encode("ascii")).decode("utf8")

raw_palette = base64.b64decode(verification.encode("ascii")).decode("utf8")
palette = []
for i, item in enumerate(raw_palette.split('\n')):
    encoding = item[0]
    text = item[1:].replace('↲', '\n')
    palette.append({ 'text': text, 'id': i, 'rle': True if encoding == '1' else False })

def parse(text, span):
    result = []
    if type(text) is list:
        for item in text:
            if type(item) is dict:
                result.append(item)
            else:
                result.append(parse(item, span))
    if type(text) is str:
        # interesting things happen here
        idx = text.find(span["text"])
        while idx != -1:
            if idx > 0:
                result.append(text[0:idx])
            result.append({ "id": span["id"], "text": span["text"],  "rle": span["rle"], "count": 1 })
            text = text[idx + len(span["text"]):]
            idx = text.find(span["text"])
        result.append(text)
    return result

def flatten(arr, result = []):
    for item in arr:
        if type(item) is list:
            flatten(item, result)
        else:
            result.append(item)
    return result

def collapse(arr):
    i = 0
    while i < len(arr):
        if type(arr[i]) is dict and arr[i]["rle"] and arr[i]["count"] > 0:
            j = i + 1
            while j < len(arr):
                if type(arr[j]) is dict or not arr[j]["rle"] or arr[j]["id"] != arr[i]["id"]:
                    break
                arr[j]["count"] = 0
                arr[i]["count"] += 1
                j += 1
            i = j - 1
        i += 1
    return list(filter(lambda d: type(d) is str or d["count"] > 0, arr))

parsed = [ raw_text ]
for span in palette:
    parsed = parse(parsed, span)

output = ""
for item in collapse(flatten(parsed)):
    if type(item) is str:
        output += item
    if type(item) is dict:
        if item["rle"]:
            output += "%02d" % item["count"]
        else:
            output += "•"

verified_score = len(output) + cost(palette)
sys.exit(0 if str(verified_score) == score else 1)
