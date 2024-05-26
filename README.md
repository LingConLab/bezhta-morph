# Bezhta morphology
The current work is dedicated to building a morphological analyzer for [Bezhta](https://en.wikipedia.org/wiki/Bezhta_language) language (< Tsezic < Avar-Andic-Tsezic < Nakh-Dagestan; Glottolog: bezh1248). This repository contains a prototype for a Bezhta morphological analyzer. It is a part of a larger project by the students of the [School of Linguistics](https://ling.hse.ru/en/) and the [Linguistic Convergence Laboratory](https://ilcl.hse.ru/en/) at the NRU HSE that aims to provide digital tools for endangered languages. 

The project is distributed under the [GNU General Public License v3.0](https://github.com/LingConLab/bezhta-morph/blob/main/LICENSE.txt). 

## Sources
### Grammar & dictionary
The parser follows (Comri et al., 2015) and (Madieva, 1965) descriptions of Bezhta Proper with the lexicon gathered from (Khalilov, 2015) dictionary. The digitized version of the dictionary is available at [bezhta_dict](https://github.com/zadushevno/bezhta_dict).
### Texts
For evaluation, I use Bezhta translation of The Gospel of Luke and The Book of Proverbs, a text from Madieva's grammar (1964) and two annotated texts. 
The texts are available in the [corpora directory](https://github.com/LingConLab/bezhta-morph/tree/main/coverage/corpus)

## Usage
The project requires [lexd](https://github.com/apertium/lexd) and [hfst](https://github.com/hfst/hfst). You can get them by the following command: 
```bash
curl -sS https://apertium.projectjj.com/apt/install-nightly.sh | sudo bash
apt install lexd
apt install hfst
```
### Making the analyzer
```bash
make
```
Analyze a word:
```bash
echo 'соралила' | hfst-lookup bezhta.analyzer.hfst
```

### Making the transliterator
Transliterator allows to transliterate Bezhta words from Cyrillic to Latin script. 
```bash
make cy2lat.transliterator.disam.hfst
```
Transliterate a word: 
```bash
echo 'соралила' | hfst-lookup cy2lat.transliterator.disam.hfst
```

Build transliterated analyzer: 
```bash
make bezhta.tr.analyzer.hfst
```

Look up a word in Latin script: 
```bash
echo 'soralila' | hfst-lookup bezhta.tr.analyzer.hfst
```

### Making the segmenter
The segmenter identifies the morpheme boundaries in the input word. 
```bash
make bezhta.segm.hfst
```
Segmenting a word:
```bash
echo 'нисойо' | hfst-lookup bezhta.segm.hfst
```
Result: 
```
 нисойо        нисо>йо
```
### Evaluating coverage
Analyzer:
```bash
make bezhta.analyzer.hfstol
mv bezhta.analyzer.hfstol coverage
cd coverage
make check-coverage
```
Additionally, `make-check-unrecog` can be used to get a list of unrecognized tokens. Note that all text files should start with `text-`

Current performance: ~75% naive coverage

Transliterator:
```bash
make bezhta.tr.analyzer.hfst
mv bezhta.tr.analyzer.hfst transliterator
make check-coverage
```
Note: some symbols may be recognized incorrectly, I recommend using [`transliterator_coverage.ipynb`](https://github.com/LingConLab/bezhta-morph/blob/main/transliterator/transliterator_coverage.ipynb) instead. 
### Evaluating accuracy
```bash
make bezhta.analyzer.hfstol
mv bezhta.analyzer.hfstol accuracy
cd accuracy
```

To analyze texts with the parser, use 
```bash
hfst-proc bezhta.analyzer.hfstol text-annotated-1.txt > FILENAME-1.txt
hfst-proc bezhta.analyzer.hfstol text-annotated-1.txt > FILENAME-2.txt
```

Then compute accuracy:
```bash
python3 accuracy.py FILENAME-1.txt text-1-gold.txt
python3 accuracy.py FILENAME-2.txt text-2-gold.txt
```

### Making the guesser
```bash
cd guesser
make bezhta.guesser.hfst
```
Guessing a token:
```bash
echo 'войъис' bezhta.guesser.hfst
```
For evaluation, see [`guesser_evaluation.ipynb`](https://github.com/LingConLab/bezhta-morph/blob/main/guesser/guesser_evaluation.ipynb)
