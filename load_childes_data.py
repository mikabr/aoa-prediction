import nltk
from nltk.corpus.reader import CHILDESCorpusReader
#from nltk.stem.snowball import SnowballStemmer

import snowballstemmer
import csv
import codecs
import re
import os
from collections import defaultdict

corpus_root = nltk.data.find('corpora/childes/data-xml/')

languages = ["cantonese", "danish", "english", "german", "hebrew", "italian",
             "mandarin", "norwegian", "russian", "spanish", "swedish", "turkish"]

def unicode_csv_reader(utf8_data, dialect=csv.excel, **kwargs):
    csv_reader = csv.reader(utf8_data, dialect=dialect, **kwargs)
    for row in csv_reader:
        yield [unicode(cell, 'utf-8') for cell in row]

# Takes a language, returns a CHIDLESCorpusReader for that language
def get_corpus_reader(language):
    return CHILDESCorpusReader(corpus_root, r'%s.*/.*\.xml' % language[:3].title())

# Takes a language, returns a list of all of the CDI items for that language
def get_cdi_items(language):
    cdi_items = codecs.open('data/cdi_items/%s_cdi_items.txt' % language, "r", "utf-8").read().split("\n")
    return [item.lower() for item in cdi_items if len(item)]

# Takes a language and a Stemmer object, returns the stemmed special cases for that langauge
def get_special_cases(language, stemmer):
    special_cases = defaultdict(set)

    language_file = 'data/special_cases/%s_special_cases.csv' % language

    if not os.path.isfile(language_file):
        return special_cases

    special_case_list = unicode_csv_reader(open(language_file))
    #special_case_list = csv.reader(codecs.open(language_file, "r", "utf-8"))

    for row in special_case_list:
        cdi_item, options = row[0], row[1:]
        if len(cdi_item) > 0:
            for option in options:
                if len(option) > 0:
                    special_cases[option].add(cdi_item)
                    special_cases[stemmer(option)].add(cdi_item)
    return special_cases

# Takes a language, returns a Stemmer object for that language
def get_stemmer(language):
    return lambda word: snowballstemmer.stemmer(language).stemWord(word)
    #return lambda word: nltk.SnowballStemmer(language, ignore_stopwords = True).stem(word)

# Takes a CDI item, generates a list of alternate forms of that item
# Returns a dictionary from alternate forms to the original item
def get_pattern_options(item):
    split_item = item.split("/")
    options = []
    for splitted in split_item:
        patterns = [r"^(.+)[*]$", # mommy*
                    r"^(.+)\s[(].*$", # chicken (animal)
                    r"^(.+)\s\1$"] # woof woof
        for pattern in patterns:
            match = re.search(pattern, splitted)
            if match:
                options += match.groups()
        if ' ' in splitted:
            spaces = splitted.split(" ")
            options += [''.join(spaces), '_'.join(spaces), '+'.join(spaces)]
    if not options:
        options = split_item
    return options

# Takes a Stemmer object, a list of items, and a dictionary of special cases
# Returns a dictionary from all original forms, alternate forms, and special cases to CDI items
def get_lang_map(stemmer, cdi_items, special_cases):

    lang_map = {item: {item} for item in cdi_items}
    lang_map.update(special_cases)

    pattern_map = {}
    for item in cdi_items:
        options = get_pattern_options(item)
        for option in options:
            pattern_map[option] = {item}

    stem_map = {stemmer(item): {item} for item in cdi_items}
    lang_map.update(stem_map)

    return lang_map

# Takes a CorpusReader object, a stemmer, and a dictionary from alternate forms to items
# Returns a FreqDist of all items in the lang_map for the corpus in the CorpusReader
def get_lang_freqs(corpus_reader, stemmer, lang_map):

    freqs = nltk.FreqDist()
    for corpus_file in corpus_reader.fileids():#[0:20]:
        corpus_participants = corpus_reader.participants(corpus_file)[0]
        #age = allEnglish.age(file, month=True)
        not_child = [value['id'] for key, value in corpus_participants.iteritems() if key != 'CHI']
        corpus_words = corpus_reader.words(corpus_file, speaker=not_child)
        corpus_stems = [stemmer(word.lower()) for word in corpus_words]
        freqs.update(nltk.FreqDist(corpus_stems))

    freq_sum = sum(freqs.values())
    cdi_freqs = defaultdict(float)
    for key, value in freqs.iteritems():
        if key in lang_map:
            items = lang_map[key]
            for item in items:
                cdi_freqs[item] += float(value)/len(items)
    norm_cdi_freqs = {key : value / freq_sum for key, value in cdi_freqs.iteritems()}

    return norm_cdi_freqs


def get_recall(language):
    lang_stemmer = get_stemmer(language)
    cdi_items = get_cdi_items(language)
    cdi_item_freqs = get_lang_freqs(get_corpus_reader(language), lang_stemmer,
                                    get_lang_map(lang_stemmer, cdi_items,
                                                 get_special_cases(language, lang_stemmer)))
    for miss in set(cdi_items) - set(cdi_item_freqs):
        if len(miss.split()) == 1:
            print miss
    print float(len(cdi_item_freqs)) / len(cdi_items)

language = "russian"
get_recall(language)
# lang_stemmer = get_stemmer(language)
# cdi_items = get_cdi_items(language)
# special_cases = get_special_cases(language, lang_stemmer)
# cdi_item_freqs = get_lang_freqs(get_corpus_reader(language), lang_stemmer,
#                                 get_lang_map(lang_stemmer, cdi_items, special_cases))


# languages = ["danish", "english", "german", "italian",
#              "norwegian", "russian", "spanish", "swedish", "turkish"]
# # "cantonese" "hebrew" "mandarin"
# for language in languages:
#     print language, get_recall(language)

# language = "russian"
# stemmer = get_stemmer(language)
# corpus_reader = get_corpus_reader(language)
# freqs = nltk.FreqDist()
# for corpus_file in corpus_reader.fileids():#[0:20]:
#     corpus_participants = corpus_reader.participants(corpus_file)[0]
#     not_child = [value['id'] for key, value in corpus_participants.iteritems() if key != 'CHI']
#     corpus_words = corpus_reader.words(corpus_file, speaker=not_child)
#     corpus_stems = [stemmer(word.lower()) for word in corpus_words]
#     freqs.update(nltk.FreqDist(corpus_words))
# words = sorted(freqs.keys())
# with codecs.open("russian_words.txt", 'w', 'utf-8') as rus:
#     for w in words:
#         rus.write(w)
#         rus.write('\n')