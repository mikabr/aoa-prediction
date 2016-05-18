import os
import nltk
from childes import CHILDESCorpusReader
from collections import defaultdict
from unicode_csv import *
#import feather

# Takes a language, returns a CHIDLESCorpusReader for that language
def get_corpus_reader(language):
    return CHILDESCorpusReader(corpus_root, r'%s.*/.*\.xml' % language[:3].title())

# Given a language, reads all CHILDES corpora in that language, computes
# word-level statistics (unigram counts, average sentence lengths, counts in
# sentence-final position, counts as sole constituent of an utterance)
def get_lang_data(language):
    corpus_reader = get_corpus_reader(language)

    word_counts = defaultdict(float)
    sent_lengths = defaultdict(list)
    final_counts = defaultdict(float)
    solo_counts = defaultdict(float)

    for corpus_file in corpus_reader.fileids():#[0:2]:
        print "Getting data for %s" % corpus_file

        corpus_participants = corpus_reader.participants(corpus_file)[0]
        not_child = [value['id'] for key, value in corpus_participants.iteritems() if key != 'CHI']

        corpus_sents = corpus_reader.sents(corpus_file, speaker = not_child, replace = True)
        for sent in corpus_sents:
            for w in xrange(len(sent)):
                word = sent[w]
                word_counts[word] += 1
                sent_lengths[word].append(len(sent))
                if len(sent) == 1:
                    solo_counts[word] += 1
                if w == len(sent) - 1:
                    final_counts[word] += 1

    mean_sent_lengths = {word: float(sum(word_sent_lengths)) / len(word_sent_lengths)
                         for word, word_sent_lengths in sent_lengths.iteritems()}

    all_words = word_counts.keys() + mean_sent_lengths.keys() + final_counts.keys() + solo_counts.keys()
    word_data = {word: {"word_count": word_counts[word],
                        "mean_sent_length": mean_sent_lengths[word],
                        "final_count": final_counts[word],
                        "solo_count": solo_counts[word]} for word in all_words}

    with open("data/childes_%s.csv" % language.lower(), "w") as data_file:
        data_writer = UnicodeWriter(data_file)
        data_writer.writerow(["word", "word_count", "mean_sent_length", "final_count", "solo_count"])
        for word, data in word_data.iteritems():
            data_writer.writerow([word,
                                  str(data["word_count"]),
                                  str(data["mean_sent_length"]),
                                  str(data["final_count"]),
                                  str(data["solo_count"])])


corpus_root = nltk.data.find('corpora/childes/data-xml/')
languages = ["English"]
# languages = ["Croatian", "Danish", "English", "French", "Italian",
#              "Norwegian", "Russian", "Spanish", "Swedish", "Turkish"]
for language in languages:
    get_lang_data(language)
