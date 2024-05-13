.DEFAULT_GOAL := bezhta.analyzer.hfstol

# join .lexd files into one
bezhta.lexd: $(wildcard bezhta_*.lexd)
	cat bezhta_*.lexd > bezhta.lexd

bezhta.twol.hfst: bezhta.twol
	hfst-twolc $< -o $@
# orthography variants: palochka, я/йа, аа/ā etc	
var.transliterator.hfst: variants
	hfst-strings2fst -j variants -o var.hfst
	hfst-repeat -f 1 var.hfst -o var.transliterator.hfst
	rm var.hfst
	
lat2cy.transliterator.hfst: cy2lat.transliterator.hfst
	hfst-invert $< -o $@
cy2lat.transliterator.hfst: cy2lat.hfst
	hfst-repeat -f 1 $< -o $@
cy2lat.hfst: cyr2lat
	hfst-strings2fst -j cyr2lat -o $@
tr.regexp.hfst: transliterator.regexp
	hfst-regexp2fst -o $@ < $<
	
# generate generator
bezhta.generator.hfst: bezhta.lexd bezhta.twol.hfst var.transliterator.hfst
	lexd $< | hfst-txt2fst -o bezhta_.generator.hfst
	hfst-compose-intersect bezhta_.generator.hfst bezhta.twol.hfst -o bezhta__.generator.hfst 
	hfst-compose bezhta__.generator.hfst var.transliterator.hfst -o $@
	rm bezhta_.generator.hfst
	rm bezhta__.generator.hfst
	rm bezhta.twol.hfst
	rm var.transliterator.hfst
	
# build transliterator
bezhta.tr.analyzer.hfst: bezhta.tr.generator.hfst
	hfst-invert $< -o $@
bezhta.tr.generator.hfst: bezhta.generator.hfst cy2lat.transliterator.hfst
	hfst-compose $^ -o $@
	rm cy2lat.hfst
	rm cy2lat.transliterator.hfst

# test generator
test.pass.txt: tests.csv
	awk -F, '$$3 == "pass" {print $$1 ":" $$2}' $^ | sort -u > $@
check: bezhta.generator.hfst test.pass.txt
	bash compare.sh $< test.pass.txt

# generate analyzer
bezhta.analyzer.hfst: bezhta.generator.hfst
	hfst-invert $< -o $@

bezhta.analyzer.hfstol: bezhta.analyzer.hfst
	hfst-fst2fst -O -i $< -o $@

# clean all .hfst files
test clean: check
	rm *.hfst
	rm *.mchar
	rm *.res
