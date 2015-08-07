import nltk
from nltk.corpus.reader import CHILDESCorpusReader
from nltk.stem.snowball import SnowballStemmer

import csv
import codecs
import re
from collections import defaultdict

corpus_root = nltk.data.find('corpora/childes/data-xml/')

languages = ["english", "danish", "russian", "italian"]

def get_corpus_reader(language):
    return CHILDESCorpusReader(corpus_root, r'%s.*/.*\.xml' % language[:3].title())

def get_cdi_items(language):
    cdi_items = codecs.open('data/%s_cdi_items.txt' % language, "r", "utf-8").read().split("\n")
    return [item for item in cdi_items if len(item)]

def get_special_cases(language, stemmer):
    special_cases = defaultdict(set)
    special_case_list = csv.reader(codecs.open('data/%s_special_cases.csv' % language, "r", "utf-8"))
    for row in special_case_list:
        cdi_item, options = row[0], row[1:]
        if len(cdi_item) > 0:
            for option in options:
                if len(option) > 0:
                    special_cases[option].add(cdi_item)
                    special_cases[stemmer.stem(option)].add(cdi_item)
    return special_cases

def get_stemmer(language):
    return SnowballStemmer(language, ignore_stopwords = True)

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

def get_lang_map(stemmer, cdi_items, special_cases):

    lang_map = {item: {item} for item in cdi_items}
    lang_map.update(special_cases)

    pattern_map = {}
    for item in cdi_items:
        options = get_pattern_options(item)
        for option in options:
            pattern_map[option] = {item}

    stem_map = {stemmer.stem(item): {item} for item in cdi_items}
    lang_map.update(stem_map)

    return lang_map

def get_lang_freqs(corpus_reader, stemmer, lang_map):

    freqs = nltk.FreqDist()
    for corpus_file in corpus_reader.fileids()[0:1]:
        corpus_participants = corpus_reader.participants(corpus_file)[0]
        #age = allEnglish.age(file, month=True)
        not_child = [value['id'] for key, value in corpus_participants.iteritems() if key != 'CHI']
        corpus_words = corpus_reader.words(corpus_file, speaker=not_child)
        corpus_stems = [stemmer.stem(word) for word in corpus_words]
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

language = "english"
lang_stemmer = get_stemmer(language)
cdi_item_freqs = get_lang_freqs(get_corpus_reader(language), lang_stemmer,
                                get_lang_map(lang_stemmer, get_cdi_items(language),
                                             get_special_cases(language, lang_stemmer)))