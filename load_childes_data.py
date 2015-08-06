import nltk
from nltk.corpus.reader import CHILDESCorpusReader
from nltk.stem.snowball import SnowballStemmer

import codecs

corpus_root = nltk.data.find('corpora/childes/data-xml/')
corpus_readers = {"english": CHILDESCorpusReader(corpus_root, r'Eng.*/.*\.xml'),
                  "danish": CHILDESCorpusReader(corpus_root, r'Dan.*/.*\.xml')}


languages = ["english", "danish"]

def get_corpus_reader(language):
    return corpus_readers[language]

def get_cdi_items(language):
    return codecs.open('data/%s_cdi_items.txt' % language, "r", "utf-8").read().split("\n")

def get_stemmer(language):
    return SnowballStemmer(language)

def lang_freqs(corpus_reader, stemmer, cdi_items):

    freqs = nltk.FreqDist()
    for corpus_file in corpus_reader.fileids():
        corpus_participants = corpus_reader.participants(corpus_file)[0]
        #age = allEnglish.age(file, month=True)
        not_child = [value['id'] for key, value in corpus_participants.iteritems() if key != 'CHI']
        corpus_words = corpus_reader.words(corpus_file, speaker=not_child)
        corpus_stems = [stemmer.stem(word) for word in corpus_words]
        freqs.update(nltk.FreqDist(corpus_stems))

    freq_sum = sum(freqs.values())
    cdi_freqs = {key : float(value) / freq_sum for key,value in freqs.iteritems() if key in cdi_items}

    return cdi_freqs

language = "danish"
cdi_item_freqs = lang_freqs(get_corpus_reader(language), get_stemmer(language), get_cdi_items(language))

