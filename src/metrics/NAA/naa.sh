echo 'NAA script starded'

while read hash;
do
  echo "cd ../chromium"
  cd ../chromium

  echo "git checkout -f ${hash}"
  git checkout -f "${hash}"

  echo "git log -1 --pretty=format:'%an'"
  author=($(git log -1 --pretty=format:'%an'))

  # Get blame authors from file
  total_authors=$(<../PIC/authors/${hash}.out)
  
  # Remove this commit author
  total_authors=${total_authors//$author/}

  # Convert blame authors file to array
  total_authors=($total_authors)

  # Remove duplicates
  total_authors=$(printf "%s\n" "${total_authors[@]}" | sort -u)

  # Convert to array
  total_authors=($total_authors)

  # Get array length
  total_authors=${#total_authors[@]}

  echo "${hash}: $total_authors" >> "../NAA/naa.out"
done < hashes.txt

echo 'NAA script ended'