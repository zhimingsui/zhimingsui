#!/bin/bash

# ========================================
# 定义常量和辅助函数
# ========================================

# set -x

template_filename="template.env"
min_tcp_port=1024
max_tcp_port=49151
tcp_port_range=$((max_tcp_port - min_tcp_port))

declare -A reserved_system_ports
declare -A allocated_ports

# 去除字符串首尾的空白字符
trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}" # remove leading whitespace characters
  var="${var%"${var##*[![:space:]]}"}" # remove trailing whitespace characters
  echo -n "$var"
}
# 获取系统占用的TCP端口
fetch_system_ports() {
  while IFS= read -r line; do
    port=$(awk -v min="$min_tcp_port" -v max="$max_tcp_port" '
      $5 ~ /:[0-9]+$/ && int(substr($5, index($5, ":")+1)) >= min && int(substr($5, index($5, ":")+1)) <= max {
        print substr($5, index($5, ":")+1)
      }' <<<"$line")

    [[ -n "$port" ]] && reserved_system_ports["$port"]="SYSTEM"
  done < <(ss -t state established '( sport = :* )')
}

# 计算唯一端口
calculate_unique_port() {
  local hash="$1"
  local offset=0
  local port=$(((hash + offset) % (tcp_port_range + 1) + min_tcp_port))

  while [[ -n "${reserved_system_ports[$port]}" || -n "${allocated_ports[$port]}" ]]; do
    ((offset++))
    port=$(((hash + offset) % (tcp_port_range + 1) + min_tcp_port))
  done

  echo "$port"
}

# 更新端口配置（考虑以 '!' 开头的值）
update_port_configuration() {
  local service_name="$1"
  local config_content="$2"

  while IFS='=' read -r key value; do
    # 跳过空白键和空行
    if [[ -z "$key" ]]; then
      continue
      # 跳过以 '#' 开头的键值对
    fi

    # 移除键两侧的空白字符
    key=$(trim "$key")

    if [[ ${key:0:1} == '#' ]]; then
      continue
    fi

    # echo "DEBUG: Checking key: $key" >&2

    if [[ ${key:0:1} == '!' ]]; then
      # 移除键首字符的 !
      local key_without_bang="${key:1}"
      allocated_ports["$value"]="$service_name.$key_without_bang"
      echo "$key_without_bang=$value"

    # 检查是否符合 TCP_PORT_8080 或 UDP_PORT_8080 的格式
    elif [[ $key =~ ^(TCP|UDP)_PORT_([0-9]+)$ ]]; then
      # echo "DEBUG: Matched key format: $key" >&2

      local protocol="${BASH_REMATCH[1]}"
      local desired_port="${BASH_REMATCH[2]}"

      local sum=0

      local new_key="${service_name}.${key}"
      local len=${#new_key}
      for ((i = 0; i < len; i++)); do
        sum=$((sum + ($(printf "%d" "'${new_key:$i:1}") * (i + 1))))
      done

      local unique_port=$(calculate_unique_port "$sum")
      allocated_ports["$unique_port"]="$service_name.$unique_port"
      echo "$key=$unique_port"
    else
      # 对于不符合指定格式的键，保持原样输出
      echo "$key=$value"
    fi

  done <<<"$config_content"
}

# 处理服务目录
process_service_folder() {
  local service_folder="$1"
  local template_file_path="$(realpath "$service_folder/$template_filename")"
  local service_name=$(basename "$service_folder")

  if [[ ! -d "$service_folder" || ! -f "$template_file_path" || ! -r "$template_file_path" ]]; then
    echo "警告: 服务目录 '$service_folder' 不存在，或 '$template_filename' 无法读取。" >&2
    return
  fi

  local env_file_path="$service_folder/.env"
  local updated_config=$(update_port_configuration "$service_name" "$(tr -d '\r' <"$template_file_path")")

  {
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
      printf "%s=%s\n" "$key" "${value:-}"
    done <<<"$updated_config"
  } >|"$env_file_path"
}

# 初始化程序
fetch_system_ports

usage() {
  echo "Usage: $(basename "$0") [-h] [SERVICE_FOLDER...]"
  echo ""
  echo "Options:"
  echo "  -h, --help     显示此帮助信息并退出"
  echo ""
  echo "参数:"
  echo "  SERVICE_FOLDER  需要处理的服务目录路径，可以提供多个"
}

while getopts ":h" opt; do
  case $opt in
  h)
    usage
    exit 0
    ;;
  \?)
    echo "错误: 不合法的选项 -$OPTARG" >&2
    usage >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

# 主程序：处理传入的服务目录参数
for folder in "$@"; do
  process_service_folder "$folder"
done
