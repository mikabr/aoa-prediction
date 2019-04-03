unlink("aoapred_si_cache/", recursive = TRUE)
rmarkdown::render("aoapred_si.Rmd")

# in aoapred.Rmd yaml, set class_option: manuscript
unlink("aoapred_cache/", recursive = TRUE)
rmarkdown::render("aoapred.Rmd")
staplr::select_pages(1:25, "aoapred.pdf", "OPMI-Braginsky-FNL.pdf")
file.copy("aoapred.tex", "OPMI-Braginsky-FNL.tex")

# click "Compile PDF" on aoapred.tex (somehow different than running pdflatex???)
# in aoapred.tex yaml, change to \documentclass[OpenMind]{stjour}
# click "Compile PDF" on aoapred.tex
# again click "Compile PDF" on aoapred.tex
staplr::select_pages(18:30, "aoapred.pdf", "OPMI-Braginsky-FNL-SI.pdf")

unlink("submission", recursive = TRUE)
dir.create("submission")
pkg <- c("colophon.pdf", "CrossMark.pdf", "openaccess3.pdf", "OPMI_logo.jpg",
         "stjour.cls")
file.copy(pkg, "submission")
file.copy(list.files(pattern = "OPMI-Braginsky"), "submission")
file.copy("figures", "submission", recursive = TRUE)
