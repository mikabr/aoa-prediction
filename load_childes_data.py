import nltk
from nltk.corpus.reader import CHILDESCorpusReader

corpus_root = nltk.data.find('corpora/childes/data-xml/')

allEnglish = CHILDESCorpusReader(corpus_root, r'Eng-.*/.*\.xml')

words = []
for corpus_file in allEnglish.fileids():
    corpus_participants = allEnglish.participants(corpus_file)
    for this_corpus_participants in corpus_participants:
        #child = [value for key, value in this_corpus_participants.iteritems() if key == 'CHI']
        #age = allEnglish.age(file, month=True)
        not_child = [value['id'] for key, value in this_corpus_participants.iteritems() if key != 'CHI']
        corpus_words = allEnglish.words(corpus_file, speaker=not_child)
        words += corpus_words
freqs = nltk.FreqDist(words)
print freqs