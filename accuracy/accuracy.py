#!/usr/bin/python3
# coding=utf-8
# -*- encoding: utf-8 -*-

import sys
import re

tst = open(sys.argv[1])
ref = open(sys.argv[2])
reading = True

def parse_line(s): 
	entry = ('', [])

	line = ''.join(s[1:-1])
	row = line.split('/')
	entry = (row[0], row[1:])
	
	return entry;

missing_analyses = 0.0
incorr_analyses = 0.0
corr_analyses = 0.0
unknown_words = 0.0

missing = {}
incorrect = {}
n = 0
recogn_pos = {}
unrecogn_pos = {}

while reading: 
	tst_line = tst.readline().strip()
	ref_line = ref.readline().strip()
	n += 1

	if tst_line == '' and ref_line == '':
		reading = False
		break
	tst_entry = parse_line(tst_line)
	ref_entry = parse_line(ref_line)

	gold = ref_entry[1][0]
	if gold in tst_entry[1]:
		corr_analyses += 1.0
		pos_tag = re.findall(r'<(n|v|adj|adv|dem|cop|num|inter|conj|pron|part|cvb|refl)>', gold)[0]
		if pos_tag not in recogn_pos:
			recogn_pos[pos_tag] = 0
		recogn_pos[pos_tag] += 1
	elif '*' in tst_entry[1][0]:
		missing_analyses += 1.0
		pos_tag = re.findall(r'<(n|v|adj|adv|dem|cop|num|inter|conj|pron|part|cvb|refl)>', gold)[0]
		if pos_tag not in unrecogn_pos:
			unrecogn_pos[pos_tag] = 0
		unrecogn_pos[pos_tag] += 1
		if tst_entry[0] not in missing:
			missing[tst_entry[0]] = []
		missing[tst_entry[0]].append(gold)
	else:
		incorr_analyses += 1.0
		if tst_entry[0] not in incorrect:
			incorrect[tst_entry[0]] = []
		incorrect[tst_entry[0]].append('/'.join(tst_entry[1]))
		pos_tag = re.findall(r'<(n|v|adj|adv|dem|cop|num|inter|conj|pron|part|cvb|refl)>', gold)[0]
		if pos_tag not in recogn_pos:
			recogn_pos[pos_tag] = 0
		recogn_pos[pos_tag] += 1


print(f'Missing analyses: {missing_analyses}\n')

for w in missing: #{
	sys.stdout.write('^' + w + '/')
	for a in missing[w]: 
		sys.stdout.write(a)
		if a != missing[w][-1]: 
			sys.stdout.write('/')
	sys.stdout.write('$\n')

print(f'\nIncorrect analyses: {incorr_analyses}\n')

for w in incorrect: 
	sys.stdout.write('^' + w + '/')
	for a in incorrect[w]: 
		sys.stdout.write(a)
		if a != incorrect[w][-1]: 
			sys.stdout.write('/')
	sys.stdout.write('$\n')


accuracy = (corr_analyses / n) * 100.0
accuracy_only_known = (corr_analyses / (n - missing_analyses)) * 100.0
coverage = ((n - missing_analyses) / n) * 100.0

print('\nRecognised by POS:')
for key, value in recogn_pos.items():
	print(key, value)
print('\nUnrecognised by POS:')
for key, value in unrecogn_pos.items():
	print(key, value)

print('\nCoverage: ' + str(coverage))
print('Accuracy: ' + str(accuracy))
print('Accuracy on known words only: ' + str(accuracy_only_known))
