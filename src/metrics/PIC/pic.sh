echo 'PIC script starded'

while read hash;
do
  echo "cd ../chromium"
  cd ../chromium

  echo "git checkout ${hash}"
  git checkout "${hash}"
  
  echo "git diff-tree --no-commit-id --name-only -r ${hash}"
  git diff-tree --no-commit-id --name-only -r "${hash}" > "../PIC/modified-files/${hash}.out"

  if [ ! -f "../PIC/lines/${hash}.out" ];
  then

    while read file;
    do
      echo "git log -1 -p -U0 -- "${file}" | grep -o -E '^\@{2}\s\-[0-9]+\,*[0-9]*'"
      lines=$(git log -1 -p -U0 -- "${file}" | grep -o -E '^\@{2}\s\-[0-9]+\,*[0-9]*')
      
      # Replace "@@ -" with nothing
      lines=${lines//@@ -/}

      # Convert $lines to array
      lines=($lines)

      each_line=($file)
      for line in "${lines[@]}";
      do
        value=${line#*:}
        value=${value//,/ }
        value=($value)

        loop=${value[1]}
        if [ "$loop" != 0 ];
        then
          each_line+=(${value[0]})
        fi

        if [ $loop ];
        then
          while [ $loop -ge 2 ];
          do
            value[0]=$((${value[0]}+1))
            each_line+=(${value[0]})
            loop=$(($loop-1))
          done
        fi
      done
      
      echo ${each_line[@]} >> "../PIC/lines/${hash}.out"
    done < ../PIC/modified-files/${hash}.out
  fi

  echo "git log -1 --pretty=format:'%an'"
  author=($(git log -1 --pretty=format:'%an'))

  echo 'git log -n2 | grep -o -E -e "[0-9a-f]{40}"'
  commits=($(git log -n2 | grep -o -E -e "[0-9a-f]{40}"))

  echo "git checkout ${commits[1]}"
  git checkout ${commits[1]}

  echo "Running git blame on commit files"
  while read file;
  do
    file=($file)
    command=("git blame "${file[0]}"")

    if [ ${file[1]} ];
    then
      command+=(" | grep ")
      i=1
      len=$((${#file[@]} - 1))
      while [ "$len" -ge "$i" ];
      do
        command+=(" -e \" ${file[$i]})\"")
        i=$(($i+1))
      done
    fi

    command+=(" | grep -o -E -e \"[a-zA-Z0-9._-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+\" -e \"initial.commit\"")

    echo ${command[@]}
    eval ${command[@]} >> "../PIC/authors/${hash}.out"

  done < ../PIC/lines/${hash}.out

  total_authors=$(<../PIC/authors/${hash}.out)
  other_authors=${total_authors//$author/}

  total_authors=($total_authors)
  total_authors=${#total_authors[@]}
  echo "Total authors: ${total_authors}"

  other_authors=($other_authors)
  other_authors=${#other_authors[@]}
  echo "Other authors: ${other_authors}"

  pic=$(bc <<< "scale=2; $other_authors / $total_authors * 100")
  echo "${hash}: $pic" >> "../PIC/pic.out"
done < hashes.txt

echo 'PIC script ended'