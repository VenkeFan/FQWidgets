#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re

re_chinese = re.compile(u'"[\u4e00-\u9fa5]+"')

def absPath():
	return os.path.abspath('.')

def hasChinese(str):
	str = unicode(str, 'utf-8') #str.decode('utf-8')
	if re_chinese.search(str):
		return True
	else:
		return False

def readFile(filePath):
	with open(filePath, 'r') as f:
		for i, line in enumerate(f.readlines()):
			if hasChinese(line):
				print("%s - %d: %s" %(filePath, i + 1, line))

def getAllFilePaths(rootPath):
	dirs = [x for x in os.listdir(rootPath)]
	for d in dirs:
		filePath = os.path.join(rootPath, d)
		if os.path.isdir(filePath):
			# print('-----------> dir:' + filePath);
			getAllFilePaths(filePath)
		elif os.path.splitext(filePath)[1] == '.m':
			# print(filePath)
			readFile(filePath)

if __name__ == '__main__':
	getAllFilePaths(absPath());