#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

. ./99.shell_lib/liblog.sh

# Constants
BOLD='\033[1m'
RESET='\033[0m'

print_welcome() {
    app_name=$(get_version_value "appname" /app/version.txt)
    app_version=$(get_version_value "version" /app/version.txt)
    last_build_counter=$(get_version_value "build_counter" /app/version.txt)
    last_build_time=$(get_version_value "last_build_timestamp" /app/version.txt)
    info ""
    # java_opts
    info "=============== ${BOLD}Server Start ${RESET} ===================="
    info "Current server version is ${BOLD}${app_name}-${app_version}-${last_build_time}-${last_build_counter}${RESET}"
    info ""
}

replace_value(){
    key="$1"
    value="$2"
    file_path="$3"
    # Check if the file exists
    if [ ! -f "$file_path" ]; then
        info "file '$file_path' is not exist"
        return 1
    fi

        #   Escape the / to \/
    # value=${value//\//\#}

    # Use sed to replace key=value
    sed -i "s~^$key=.*~$key=$value~g" "$file_path"
    sed -i "s~^$key: .*~$key: $value~g" "$file_path"
}

# update_config_value "config_name" "config_value" "file_path"
update_config_value() {
    key="$1"
    value="$2"
    file_path="$3"
    # is_force="$4"
    if [[ -n "${value}" ]]; then
        info "Key is $key . the value will be changed to $value in file $file_path"
        replace_value "$@"
    fi
}

check_previous_command() {
    if [ $? -ne 0 ]; then
        echo "上一条命令执行失败，脚本退出"
        exit 1
    else
        echo "上一条命令执行成功，继续执行脚本"
    fi
}


#To retrieve the valuese of the variables in the equation. For example version=0.01-Release-20230403 
# and then value of '0.01-Release-20230403' will be retrieved.
get_version_value(){
   local variable_name=$1
   local filename=$2
   local pattern="${variable_name}=([^[:space:]]+)"

   # awk cannot deal with key1=value1=value2
   #   local result=$(grep -Eo $pattern "$filename" | awk -F '=' '{print $2}')

   # Use cut command instead.
   local result=$(grep -Eo $pattern "$filename" | cut -d '=' -f 2-)
   echo "$result"
}

# ck_empty "var_name"
# Return false, if var_name is empty.
ck_not_empty(){
    local variable_name=$1
    if [ -z "$variable_name" ]; then
        echo "false"
    else 
        echo "true"
    fi
}

# Return true, if the directory is empty.
# ck_empty_directory "<directory_path>"
ck_empty_directory(){
    local directory_path=$1
    if [[ $(ls -A $directory_path) ]]; then
        echo "false"
    else
        # This is an empty directory 
        echo "true"
    fi
}