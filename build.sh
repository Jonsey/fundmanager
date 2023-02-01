docker run \
  -it --rm -v "$(pwd):/code" \
  -w "/code" -e "HOME=/tmp" \
  -u $UID:$GID -p 8000:8000 \
  elm-trade-manager:0.18 \
