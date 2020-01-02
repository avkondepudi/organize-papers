organize-papers
====

A shell script to build a network of directories from a YAML file that contains the categorizations of your papers and creates a HTML interface hosted by GitHub Pages. Can be used for other entities as well.

If you don't want to use GitHub Pages, use the shell script found under the "old" branch.

An example can be found [here](https://github.com/avkondepudi/glowing-disco).

### dependencies

Needs tree.
```bash
brew install tree
```

### usage/info

Make a new GitHub repository and create a YAML file with the specific categories of papers you want. Copy and paste the shell script found here into the directory containing the YAML file and run the script. Then, host the GitHub repository using GitHub pages.

flags:
```
-d | --dir [FILEDIR] (default: current dir or .)
-i | --input [YAML INPUTFILE] (default: ./papers.yml)
-m | --main [MAINFILE] (default: ./index.html)
```

Mulitple links can be added for each paper.

A custom title and summary can be added to the main file (README). Map the title to the key "title" and the summary to the key "info" at the top of the YAML file.

