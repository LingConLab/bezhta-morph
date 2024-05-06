.DEFAULT_GOAL := bezhta.analyzer.hfstol

# join .lexd files into one
bezhta.lexd: $(wildcard bezhta_*.lexd)
	cat bezhta_*.lexd > bezhta.lexd

bezhta.twol.hfst: bezhta.twol
	hfst-twolc $< -o $@
	
var.transliterator.hfst: variants
	hfst-strings2fst -j variants -o var.hfst
	hfst-repeat -f 1 var.hfst -o var.transliterator.hfst
	rm var.hfst

# generate generator
bezhta.generator.hfst: bezhta.lexd bezhta.twol.hfst
	lexd $< | hfst-txt2fst -o bezhta_.generator.hfst
	hfst-compose-intersect bezhta_.generator.hfst bezhta.twol.hfst -o $@
	rm bezhta_.generator.hfst
	rm bezhta.twol.hfst

# test generator
test.pass.txt: tests.csv
	awk -F, '$$3 == "pass" {print $$1 ":" $$2}' $^ | sort -u > $@
check: bezhta.generator.hfst test.pass.txt
	bash compare.sh $< test.pass.txt

# generate analizer
bezhta.analyzer.hfst: bezhta.generator.hfst
	hfst-invert $< -o $@

bezhta.analyzer.hfstol: bezhta.analyzer.hfst
	hfst-fst2fst -O -i $< -o $@

# clean all .hfst files
test clean: check
	rm *.hfst

