organize-papers
====

A poorly-written shell script to build a network of directories from a YAML file that contains the categorizations of your papers.

Needs tree.
```bash
brew install tree
```

An example can be found [here](https://github.com/avkondepudi/glowing-disco).

### usage/info

flags:
```
-d | --dir [FILEDIR] (default: current dir or .)
-i | --input [YAML INPUTFILE] (default: ./papers.yml)
-m | --main [MAINFILE] (default: ./README.txt)
```

Mulitple links can be added for each paper. <> refers to links that are pdfs; [] are non-pdfs.

A custom title and summary can be added to the main file (README). Map the title to the key "title" and the summary to the key "info" at the top of the YAML file.

