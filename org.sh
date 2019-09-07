#!/bin/bash

global() {
if [[ ! -x "$(command -v tree)" ]]; then echo "install tree"; exit 1; fi

IFILE="papers.yml"
USERNAME="$(git config user.name)"
REPONAME=$(pwd); REPONAME="${REPONAME##*\/}"
BRANCH="$(git branch | grep \* | cut -d ' ' -f2)"

FILEDIR="."
MFILE="README.txt"

resetvars
}

resetvars() {
	NAME=""; LINKS=""; YEAR=""
}

addtitle() {
local filename="$1"
local title="$2"

if [[ -z "$title" ]]; then title="$(echo ${filename##*\/} | sed -e "s/\.md//g")"; fi
if [[ -d "${filename%\/*}" && "${filename}" =~ ^\. ]]; then rm -rf "${filename%\.*}"; fi

cat << EOF > "${filename}"
${title}
====

EOF
}

addinfo() {
if [[ ! -z "$NAME" ]]; then
	if [[ ! -f "${RELPATH}.md" ]]; then addtitle "${RELPATH}.md"; fi
	LINKS="$(echo "$LINKS" | sed -e 's/\^/ /g' -e 's/ //g')"
	echo "* ${NAME} ${LINKS} (${YEAR})" >> "${RELPATH}.md"
	resetvars
fi
}

getpath() {
if [[ -z "$VALUE" ]]; then
	local line="$1"
	if [[ $LEVEL -eq 1 ]]; then RELPATH="$FILEDIR"; fi
	local num="${RELPATH//[^\/]}"; num=${#num}
	local SUB_RELPATH

	if [[ $num -gt $LEVEL ]]; then
		for ((i=0;i<$(($num-$LEVEL));i++)); do RELPATH=${RELPATH%\/*}; done
		RELPATH=${RELPATH%\/*}
		SUB_RELPATH=${line#*-}; SUB_RELPATH=${SUB_RELPATH%:*}; RELPATH="${RELPATH}/${SUB_RELPATH:1}"
	elif [[ $num -lt $LEVEL ]]; then 
		SUB_RELPATH=${line#*-}; SUB_RELPATH=${SUB_RELPATH%:*}; RELPATH="${RELPATH}/${SUB_RELPATH:1}"
	else
		RELPATH=${RELPATH%\/*}
		SUB_RELPATH=${line#*-}; SUB_RELPATH=${SUB_RELPATH%:*}; RELPATH="${RELPATH}/${SUB_RELPATH:1}"
	fi

	if [[ $RELPATH =~ \/$ ]]; then RELPATH=${RELPATH%\/*}; fi
	if [[ ! -d $RELPATH && $RELPATH == *"."* ]]; then mkdir $RELPATH; fi

	if [[ $LEVEL -eq 1 ]]; then rm -rf "$RELPATH"; mkdir "$RELPATH"; fi
fi
}

getinfo() {
local line="$1"
VALUE="${line#*:}"; VALUE="${VALUE:1}"
KEY="${line%%:*}"; KEY=$(echo $KEY | sed -e "s/-//g" -e "s/ //g")
if [[ "$line" == *"  - "* ]]; then 
	LEVEL="${line%%-*}"; LEVEL=${#LEVEL}; LEVEL=$((LEVEL/2))
fi
}

buildfiles() {
rm README.* &> /dev/null 
if [[ ! -f $MFILE ]]; then touch $MFILE; fi
while IFS= read -r line || [ -n "$line" ]; do

	if [[ "$line" == *"  - "* && ! -z "$VALUE" ]]; then addinfo; fi
	getinfo "$line"
	getpath "$line"

	case $KEY in
		name) NAME="$VALUE";;
		link)
			nlink="$VALUE"
			for prefix in "https*:\/\/" "www\."; do nlink=$(echo "$nlink" | sed -e "s/${prefix}//g" ); done
			for suffix in "com" "org" "edu" "gov" ".github.io" ".io" ".ai"; do nlink=${nlink%\.${suffix}*}; done
			if [[ "$VALUE" =~ [pP][dD][fF] ]]; then LINKS="${LINKS}^<[${nlink}](${VALUE})>"
			else LINKS="${LINKS}^\[[${nlink}](${VALUE})\]"
			fi
			;;
		year) YEAR="$VALUE";;
		title) addtitle $MFILE $VALUE;;
		info)
			if [[ ! -f $MFILE ]]; then addtitle $MFILE; fi
			printf "${VALUE}\n\n" >> $MFILE
			;;
		papers)
			if [[ ! -f $MFILE ]]; then addtitle $MFILE; fi
			LEVEL=1
			;;
	esac

done < "$IFILE"
addinfo
}

addnum() {
local val=$1
local index=$2

local regex="s/([0-9][0-9]*)/(${val})/${index}"
tr '\n' '^' < $MFILE | sed -e "${regex}" | tr '^' '\n' > tREADME
cp tREADME $MFILE
}

buildmainacc() {
local INDEX=$2
DIR="$1"; local SUM=0; local NFILES=0
for item in "$DIR"/*; do
    if [[ -d "$item" ]]; then
        ((++INDEX))
        sed -i ".bak" "$((INDEX+OFFSET)) s+ ${item##*\/}+ ${item##*\/} (0)+g" $MFILE
        string=$(buildmainacc $item $INDEX); array=($string)
        ((SUM+=${array[0]})); ((NFILES+=${array[1]}+1)); INDEX=${array[2]}
    fi
    if [[ "$item" =~ .*\.md ]]; then
    	((++INDEX))

        replacement_text="$(echo ${item##*\/} | sed -e "s/\.md//g") (0) \| (https:\/\/github.com\/${USERNAME}\/${REPONAME}\/blob\/${BRANCH}\/${item:2})"
        sed -i ".bak" "$((INDEX+OFFSET)) s+ ${item##*\/}+ ${replacement_text}+g" $MFILE

        local NPAPERS=0
        while read line; do
            if [[ "$line" == *"*"* ]]; then ((++NPAPERS)); fi
        done < "$item"

        ((SUM+=NPAPERS)); ((++NFILES))
        addnum $NPAPERS $INDEX
    fi
done
((INDEX-=NFILES))
if [[ $DIR != "." ]]; then addnum $SUM $INDEX; fi
((INDEX+=NFILES))
echo $SUM $NFILES $INDEX
}

buildmain() {
OFFSET=$(wc -l < $MFILE | tr -d '[:space:]'); ((++OFFSET))
tree -I "README.*" -P "*.md" >> $MFILE
buildmainacc . 0 &> /dev/null
rm "${MFILE}.bak"; rm tREADME
}

main() {
global

for ((i=1;i<=$#;i++)); do
	case ${@:$i:1} in
		-d | --dir) FILEDIR=${@:$((i+1)):1};;
		-i | --input) IFILE=${@:$((i+1)):1};;
		-m | --main) MFILE=${@:$((i+1)):1};;
	esac
done

buildfiles
buildmain
}

main $@
