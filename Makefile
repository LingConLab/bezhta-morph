.DEFAULT_GOAL := bezhta.analyzer.hfst
# join .lexd files into one
bezhta.lexd: $(wildcard bezhta.*.lexd)
	cat bezhta.*.lexd > bezhta.lexd

bezhta.twol.hfst: bezhta.twol
	hfst-twolc $< -o $@

# generate generator
bezhta.generator.hfst: bezhta.lexd bezhta.twol.hfst
	lexd $< | hfst-txt2fst -o bezhta_.generator.hfst
	hfst-compose-intersect bezhta_.generator.hfst bezhta.twol.hfst -o $@
	rm bezhta_.generator.hfst
	rm bezhta.twol.hfst

#анализатор
bezhta.analyzer.hfst: bezhta.generator.hfst
	hfst-invert $< -o $@

test.pass.txt: tests.csv
	awk -F, '$$3 == "pass" {print $$1 ":" $$2}' $^ | sort -u > $@
check: bezhta.generator.hfst test.pass.txt
	bash compare.sh $< test.pass.txt
clean: check
	rm test.*
	
