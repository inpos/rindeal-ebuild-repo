#!/usr/bin/env python3
##
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
##

# -----------------------------------------------------------------------------

# travis-ci supports only basic colours
def colorize(color, s): return "{}{}\033[0m".format(color, s)

def bold(s): return colorize("\033[1m", s)

def black(s):   return colorize("\033[30m", s)
def red(s):     return colorize("\033[31m", s)
def green(s):   return colorize("\033[32m", s)
def yellow(s):  return colorize("\033[33m", s)
def blue(s):    return colorize("\033[34m", s)
def magenta(s): return colorize("\033[35m", s)
def cyan(s):    return colorize("\033[36m", s)
def light_grey(s): return colorize("\033[37m", s)
def white(s):   return colorize("\033[97m", s)

def bg_black(s):   return colorize("\033[40m", s)
def bg_red(s):     return colorize("\033[41m", s)
def bg_green(s):   return colorize("\033[42m", s)
def bg_yellow(s):  return colorize("\033[43m", s)
def bg_blue(s):    return colorize("\033[44m", s)
def bg_magenta(s): return colorize("\033[45m", s)
def bg_cyan(s):    return colorize("\033[46m", s)
def bg_light_grey(s): return colorize("\033[47m", s)
def bg_white(s):   return colorize("\033[107m", s)

# -----------------------------------------------------------------------------

import fileinput
import re
import collections
import copy
import os

# -----------------------------------------------------------------------------

class _MyDict(collections.OrderedDict):
	@staticmethod
	def _sort_key(key_val):
		key, val = key_val
		return key

	def sort(self):
		for x in self.values():
			x.sort()
		self.__init__(sorted(self.items(), key=self._sort_key))


class MsgList(list):
	pass

class MsgCode:
	name = None # type: str
	msgs = None # type: MsgList

	def __init__(self, name):
		self.name = name
		self.msgs = MsgList()

	def sort(self):
		self.msgs.sort()

class MsgCodeList(_MyDict):
	def __getitem__(self, key):
		if key not in self:
			self[key] = MsgCode(key)
		return super().__getitem__(key)

class File:
	name     = None # type: str
	msgcodes = None # type: MsgCodeList

	def __init__(self, name):
		self.name = name
		self.msgcodes = MsgCodeList()

	def sort(self):
		self.msgcodes.sort()

class FileList(_MyDict):
	def __getitem__(self, key):
		if key not in self:
			self[key] = File(key)
		return super().__getitem__(key)

class Pkg:
	id       = None # type: str
	msgcodes = None # type: MsgCodeList
	files    = None # type: FileList
	msgs     = None # type: MsgList

	def __init__(self, id):
		self.id = id
		self.msgcodes = MsgCodeList()
		self.msgs = MsgList()
		self.files = FileList()

	def sort(self):
		self.files.sort()
		self.msgcodes.sort()
		self.msgs.sort()

class PkgList(_MyDict): # TODO
	def __getitem__(self, key):
		if key not in self:
			self[key] = Pkg(key)
		return super().__getitem__(key)

# -----------------------------------------------------------------------------

PAT1 = re.compile(
	"""
	^
	(?P<msgcode>
		[a-zA-Z.]+
	)
	\ +          # followed by some spaces
	(?P<msg>
		.+
	)
	""",
	re.VERBOSE
)
PAT2 = re.compile(
	"""
	^
	## package id
	(?P<pkgid>
		[a-zA-Z-]+     # category
		/
		[a-zA-Z0-9_-]+ # pkg name
	)
	## optional file
	(?:
		/
		(?P<file>
			[^ :]+
		)
	)?
	## optional message
	(?:
		:?  # optionally followed by semicolon
		\ + # and some spaces
		(?P<msg>
			.+
		)
	)?
	""",
	re.VERBOSE
)

PKGS = PkgList()
OTHER_MSGCODES = MsgCodeList()
INVALID_LINES = []

def process_line(line):

	m = re.match(PAT1, line)
	if m is not None:
		msgcode = m.group(1)
		msg     = m.group(2)

		m = re.match(PAT2, msg)
		if m is not None:
			pkgid, filename, msg = m.group('pkgid', 'file', 'msg')

			if filename is not None and msg is not None:
				(PKGS[pkgid]
					.files[filename]
					.msgcodes[msgcode]
					.msgs
					.append(msg)
				)
			if filename is not None and msg is None:
				(PKGS[pkgid]
					.files[filename]
					.msgcodes[msgcode]
				)
			if filename is None and msg is not None:
				(PKGS[pkgid]
					.msgcodes[msgcode]
					.msgs
					.append(msg)
				)
			if filename is None and msg is None:
				(PKGS[pkgid]
					.msgcodes[msgcode]
				)

		else:
			(OTHER_MSGCODES[msgcode]
				.msgs
				.append(msg)
			)
	else:
		INVALID_LINES.append(line)

INDENT_PREFIX = "  "

def truncate(line, width=129, placeholder="..."):
	if len(line) > width:
		# make space for placeholder
		tr_line_len = width - len(placeholder)
		return line[:tr_line_len] + placeholder
	else:
		return line

def print_indented_line(line, indent_lvl=0):
	line = "{}{}".format(INDENT_PREFIX*indent_lvl, line)
	line = truncate(line)
	print(line)

def print_msgs(msgs, indent_lvl=0):
	for msg in msgs:
		print_indented_line(msg, indent_lvl)

def print_msgcodes(msgcodes, indent_lvl=0):
	for msgcode in msgcodes.values():
		print_indented_line(
			cyan(msgcode.name) + ":",
			indent_lvl
		)
		if msgcode.msgs:
			print_msgs(msgcode.msgs, indent_lvl + 1)

def print_files(files, indent_lvl=0):
	for f in files.values():
		print_indented_line(
			blue(f.name) + ":",
			indent_lvl
		)
		if f.msgcodes:
			print_msgcodes(f.msgcodes, indent_lvl + 1)

def print_pkgs(pkgs, indent_lvl=0):
	for pkg in pkgs.values():
		print_indented_line(
			yellow(bg_black(pkg.id)) + ":",
			indent_lvl
		)
		if pkg.msgcodes:
			print_msgcodes(pkg.msgcodes, indent_lvl + 1)
		if pkg.files:
			print_files(pkg.files, indent_lvl + 1)
		if pkg.msgs:
			print_msgs(pkg.msgs, indent_lvl + 1)

def print_results(pkgs):
	print()
	print(yellow("Repoman results".center(80, ' ')))
	print(green("="*80))
	print()

	if pkgs:
		print_pkgs(pkgs, 0)
	if OTHER_MSGCODES:
		print()
		print(yellow(bg_black("Other messages")) + ":")
		print_msgcodes(OTHER_MSGCODES, 1)

RAW_INPUT = []

with fileinput.input() as stdin:
	for line in stdin:
		# skip repoman's own header
		if stdin.filelineno() < 4:
			continue
		# skip lines announcing the number of reports
		if line.startswith('NumberOf'):
			continue
		# any empty line after it marks the end of a useful
		if len(line) <= 2:
			break

		RAW_INPUT.append(line)

		line = line.rstrip()
		process_line(line)

PKGS.sort()

print_results(PKGS)

class travis_ci_fold:

	_tag = ""
	_desc = ""
	_started = 0

	def __init__(self, tag, description=""):
		self._tag = tag
		self._desc = description

	def start(self):
		if self._started:
			raise Exception("travis fold already started")
		print("travis_fold:start:{}\033[33;1m{}\033[0m".format(self._tag, self._desc))
		self._started = 1

	def end(self):
		if not self._started:
			raise Exception("travis fold not started yet")
		print("\ntravis_fold:end:{}\r".format(self._tag))

	def __enter__(self):
		self.start()
		return self

	def __exit__(self, type, value, traceback):
		self.end()

if 'TRAVIS' in os.environ:
	with travis_ci_fold("repoman.results.raw"):
		for line in RAW_INPUT:
			print(line, end='')
