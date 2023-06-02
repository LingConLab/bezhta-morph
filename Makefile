.DEFAULT_GOAL := bezhta.analyzer.hfst
# join .lexd files into one
bezhta.lexd: bezhta.num.lexd bezhta.pron.lexd bezhta.case.lexd
	cat $^ > $@

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