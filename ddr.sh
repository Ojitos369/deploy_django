#!/bin/bash
#Django Deploy Remove

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) name="$2"; shift ;;
        --path) path="$2"; shift ;;
        --url) url="$2"; shift ;;
        --conda) conda="$2"; shift ;;
        --id) id="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# ---------------------------------   MAKING COMMAND FUNCTION   ---------------------------------
echo "---------------------------------   MAKING COMMAND FUNCTION   ---------------------------------"
run_command() {
    command=$1
    echo -e "Ejecutando:\n$command\n..."
    $command
}

run_command "echo Iniciando"

# ---------------------------------   REVISANDO VARIABLES   ---------------------------------
echo "---------------------------------   REVISANDO VARIABLES   ---------------------------------"
# Check mandatory parameters
if [[ -z "$name" ]]; then
    echo "Nombre es obligatorio"
    exit 1
fi
# ~
# replace ' ' and '_' with '-' in name
name=$(echo $name | sed -e 's/ /-/g' -e 's/_/-/g')
userpath=$(echo ~)
path=${path:-"$userpath/Documents/progra/$name"}
url=${url:-""}
                  
echo "name: $name"
echo "path: $path"


my_list=("y" "s" "1")
conda_valid=false
for i in ${my_list[@]}; do
    # check if i in conda case insensitive
    if [[ "${conda,,}" == *"${i,,}"* ]]; then
        conda_valid=true
        break
    fi
done
conda=$conda_valid
if [ "$conda" == "true" ]; then
    if [ -z "$id" ]; then
        echo "El id es obligatorio si se usa conda"
        exit 1
    fi
fi

# ---------------------------------   ELIMINANDO PATH   ---------------------------------
echo "---------------------------------   ELIMINANDO PATH   ---------------------------------"
run_command "sudo supervisorctl status $name"
run_command "sudo supervisorctl stop $name"
run_command "sudo supervisorctl status $name"
run_command "sudo rm -f /etc/nginx/sites-available/$name.conf"
run_command "sudo rm -f /etc/nginx/sites-enabled/$name.conf"
run_command "sudo rm -f /etc/supervisor/conf.d/$name.conf"
run_command "sudo supervisorctl reread"
run_command "sudo supervisorctl update"

run_command "rm -rf $path"

if [ "$conda" == "true" ]; then
    run_command "conda deactivate"
    run_command "conda env remove -n $id"
fi

# delete certificated certbot if url is not empty
if [[ ! -z "$url" ]]; then
    run_command "sudo certbot delete --cert-name $url"
fi

echo "# Elimine los alias de reset si es que existen"

# ---------------------------------   VARIABLES   ---------------------------------
# --name - nombre de la app - obligatorio

# --path - ruta donde se aloja el projecto - defecto "~/Documents/progra/$name"
# --url - url del dominio - defecto ""

# ---------------------------------   EJEMPLO   ---------------------------------
# ./ddr.sh --name "app_name" --url "dns.dom"
# ./ddr.sh --name "app_name" --path "~/Documents/progra/app_name" --url "dns.dom"

# para obtener el nombre de la app
# sudo supervisorctl
# para obtener el url
# sudo certbot certificates

