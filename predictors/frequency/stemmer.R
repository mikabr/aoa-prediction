library(SnowballC)
library(rPython)
library(stringr)

# Gets stems for a list of words in a given language.
# Uses Snowball if it is available, otherwise uses a special case stemmer
# So far: Croatian (uses Steven Koch's implementation of the Zagreb Stemer)
get_word_stems <- function(words, language) {
  
  language <- tolower(language)
  
  if(language %in% getStemLanguages()) {
    wordStem(words, language)
    
  }else if(language == "croatian") {
    stemmer <- read_lines("croatian_stemmer/croatian.py")
    python.exec(stemmer)
    python.exec("stemmer = CroatianStemmer()")
    
    word_list <- sprintf("['%s']", paste(words, collapse = "','"))
    python.exec(sprintf("words = %s", word_list))
    python.exec("stem = [stemmer.stem(word) for word in words]")
    python.get("stem")
    
  } else stop("provided language not in list of stemmable languages")
}