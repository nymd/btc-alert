#!/bin/bash

# install - bc curl jq mpv

getBTC() {
  curl -s -H "X-CMC_PRO_API_KEY: YOUR_API_KEY_HERE" -H "Accept: application/json" -d "start=1&limit=5000&convert=USD" -G "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest" > /tmp/bc.tmp
  echo "$(cat /tmp/bc.tmp | jq -c '.data | .[] | select(.symbol == "BTC") | .quote.USD.price' | cut -d'.' -f1)"
}

OLD="$(getBTC)"
echo "$(date +%r) : ${OLD} (--)"
while true; do
  sleep 300
  
  NEW="$(getBTC)"
  DIFF="$(echo "${NEW} - ${OLD}" | bc)"
  echo "$(date +%r) : ${NEW} (${DIFF})"

  if [ ${DIFF} -ge 50 ]; then
    AUDIO=1
    for scrn in $(cd /tmp/.X11-unix && for x in X*; do echo "${x#X}"; done); do
		  mpv --really-quiet -fs-screen=${scrn} --fs $(if [ ${AUDIO} -eq 0 ]; then echo "--no-audio"; fi) --no-input-default-bindings bitcoin.mp4 &
		  AUDIO=0
    done
  fi

  OLD="${NEW}"
done
