echo 'NEA script starded'

while read hash;
do
  echo "cd ../chromium"
  cd ../chromium

  echo "git checkout ${hash}"
  git checkout "${hash}"
  
  echo "git diff-tree --no-commit-id --name-only -r ${hash}"
  git diff-tree --no-commit-id --name-only -r "${hash}" > "../NEA/modified-files/${hash}.out"

  echo "git log -1 --pretty=format:'%an'"
  author=($(git log -1 --pretty=format:'%an'))

  echo 'git log -n2 | grep -o -E -e "[0-9a-f]{40}"'
  commits=($(git log -n2 | grep -o -E -e "[0-9a-f]{40}"))

  echo "git checkout ${commits[1]}"
  git checkout ${commits[1]}

  echo "Running git blame on commit files"
  modified_lines=()
  while read file;
  do
    echo "git blame "${file}" | grep ${author}"
    blame=$(git blame "${file}" | grep -o -E -e "${author}")
    if [ -n "$blame" ];
    then
      modified_lines+=1;
    fi

  done < ../NEA/modified-files/${hash}.out

  echo "Setting NEA status"
  if [ -n "$modified_lines" ];
  then
    echo "${hash}: Não" >> "../NEA/is-nea.out" 
  else
    echo "${hash}: Sim" >> "../NEA/is-nea.out" 
  fi
done < hashes.txt

echo 'NEA script ended'