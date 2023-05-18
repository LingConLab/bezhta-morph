bezhta.num.analyzer.hfst: bezhta.num.generator.hfst
	hfst-invert bezhta.num.generator.hfst -o bezhta.num.analyzer.hfst

bezhta.num.generator.hfst: bezhta.num.lexd
	lexd bezhta.num.lexd | hfst-txt2fst -o bezhta.num.generator.hfst