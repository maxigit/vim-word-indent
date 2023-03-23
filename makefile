doc/word-indent.txt: README.md
	md2vim -desc 'Indent using previous line as word as tabstops' $< $@
