# clean all .hfst files
clean:
	rm *.hfst
	rm bezhta.guess.lexd

bezhta.guess.lexd: guess_bezhta_*.lexd 
	cat $^ > bezhta.guess.lexd

bezhta.twol.hfst: bezhta.twol
	hfst-twolc $< -o $@

bezhta.guess.hfst: bezhta.guess.lexd
	lexd $< | hfst-txt2fst -o $@

bezhta.guesser.hfst: bezhta.guess.hfst bezhta.twol.hfst
	hfst-compose-intersect $^ | hfst-invert -o guess.analyzer.hfst

	hfst-summarize -v guess.analyzer.hfst \
	| grep -A1 'sigma set:' \
	| tail -1 \
	| sed 's/, /\n/g' \
	| grep -E '<Type.+>'\
	| sed 's/<Type\(.\+\)>/&\t[GUESS_CATEGORY=\1]/'\
	| hfst-substitute -F - -o target.subst.hfst guess.analyzer.hfst
	hfst-guessify -v  target.subst.hfst > bezhta.guesser.hfst
	rm target.subst.hfst
	rm guess.analyzer.hfst
	rm bezhta.guess.hfst

bezhta.guesser.hfstol: bezhta.guesser.hfst
	hfst-fst2fst -O -i $< -o $@