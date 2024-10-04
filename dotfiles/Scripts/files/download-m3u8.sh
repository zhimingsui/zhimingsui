#!/bin/bash

m3u8_url=$1
code=$2

url_path="${m3u8_url%/*}/"

target_path="$HOME/Videos/$code"
m3u8_file_name=${code}.m3u8
m3u8_file_path="${target_path}/${m3u8_file_name}"

if [ ! -d $target_path ]; then
    mkdir -p $target_path
fi

if [ ! -f ${m3u8_file_path} ]; then
    if [[ $m3u8_url == http* ]]; then
        $(curl ${m3u8_url} | sed "/\.ts/s@^@${url_path}@" >"${m3u8_file_path}")
    else
        cp $m3u8_url $m3u8_file_path
    fi
fi

docker run --rm -it \
    -v ${target_path}:/config \
    linuxserver/ffmpeg \
    -protocol_whitelist https,file,tcp,tls \
    -i /config/${m3u8_file_name} \
    -c copy \
    /config/${code}.mp4

