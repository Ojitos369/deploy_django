#!/bin/bash
#Django Deploy Docker

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) name="$2"; shift ;;
        --path) path="$2"; shift ;;
        --repo) repo="$2"; shift ;;
        --url) url="$2"; shift ;;
        --port) port="$2"; shift ;;
        --files_path) files_path="$2"; shift ;;
        --extra_files) extra_files="$2"; shift ;;
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

run_command "echo hola"

# ---------------------------------   REVISANDO VARIABLES   ---------------------------------
echo "---------------------------------   REVISANDO VARIABLES   ---------------------------------"
# Check mandatory parameters
if [[ -z "$name" || -z "$repo" ]]; then
    echo "Nombre y repo son obligatorios"
    exit 1
fi
if [[ -z "$port" ]]; then
    echo "Nombre y repo son obligatorios"
    exit 1
fi
# ~
# replace ' ' and '_' with '-' in name
name=$(echo $name | sed -e 's/ /-/g' -e 's/_/-/g')
userpath=$(echo ~)
path=${path:-"$userpath/Documents/progra/$name"}
url=${url:-""}
files_path=${files_path:-""}
files_path=$path/$files_path
extra_files=${extra_files:-""}

echo "name: $name"
echo "path: $path"
echo "repo: $repo"
echo "url: $url"
echo "files_path: $files_path"
echo "extra_files: $extra_files"

# ---------------------------------   HACIENDO PATH   ---------------------------------
echo "---------------------------------   HACIENDO PATH   ---------------------------------"
rm -rf $path
mkdir -p $path
cd $path
pwtd=$(pwd)
echo "pwtd: $pwtd"
echo "Creando app..."
pwd=$(pwd)
user=$(whoami)
echo "user: $user"

# ---------------------------------   CLONANDO REPO   ---------------------------------
echo "---------------------------------   CLONANDO REPO   ---------------------------------"
run_command "git clone $repo ."

# ---------------------------------   COPIANDO ARCHIVOS EXTRA   ---------------------------------
echo "---------------------------------   COPIANDO ARCHIVOS EXTRA   ---------------------------------"
echo "extra_files: $extra_files ."
if [[ -z "$extra_files" ]]; then
    echo "No hay archivos extra"
else
    run_command "ls -a $extra_files/"
    run_command "cp $extra_files/* $path"
    run_command "cp $extra_files/*. $path"
    run_command "cp $extra_files/.* $path"
    run_command "cp $extra_files/*.* $path"
fi

# ---------------------------------   LEVANTANDO DOCKER   ---------------------------------
echo "---------------------------------   LEVANTANDO DOCKER   ---------------------------------"
run_command "docker compose up -d"

# ---------------------------------   NGINX   ---------------------------------
echo "---------------------------------   NGINX   ---------------------------------"
file_to="$pwtd/$name.conf"
touch $file_to
echo "Adding to $file_to..."
# sudo touch /etc/nginx/sites-available/myapp.conf
echo "server {" >> $file_to
echo "    server_name "$url";" >> $file_to
echo "" >> $file_to
echo "    location /static/ {" >> $file_to
echo "        root "$files_path";" >> $file_to
echo "    }" >> $file_to
echo "    location /media/ {" >> $file_to
echo "        root "$files_path";" >> $file_to
echo "    }" >> $file_to
echo "" >> $file_to
echo "    location / {" >> $file_to
echo "        proxy_pass http://127.0.0.1:"$port";" >> $file_to
echo "        proxy_set_header Host ""$""host;" >> $file_to
echo "        proxy_set_header X-Real-IP ""$""remote_addr;" >> $file_to
echo "        proxy_set_header X-Forwarded-For ""$""proxy_add_x_forwarded_for;" >> $file_to
echo "        proxy_set_header X-Forwarded-Proto ""$""scheme;" >> $file_to
echo "    }" >> $file_to
echo "}" >> $file_to
echo "" >> $file_to

run_command "sudo mv $file_to /etc/nginx/sites-available/"
run_command "sudo rm -f /etc/nginx/sites-enabled/$name.conf"
run_command "sudo ln -s /etc/nginx/sites-available/$name.conf /etc/nginx/sites-enabled/$name.conf"

run_command "sudo service nginx restart"

echo "# alias recomendados:"
echo ""
echo "# Reinicio simple solo bajando cambios del git"
echo "alias sr""$name""dd='cd $pwd && git pull"
echo ""
echo "# Reinicio bajando cambios del git y rehaciendo el contenedor"
echo "alias r""$name""dd='cd $pwd && git pull && docker compose down && docker compose up -d"
echo ""
echo "# Reinicio rehaciendo la imagen y contenedor"
echo "alias fr""$name""dd='cd $pwd && docker compose down && docker image rm "$name"-web && docker compose up -d"
echo ""
echo "# Si quiere poner ssl (tener certbot instalado) (sudo snap install --classic certbot && sudo ln -s /snap/bin/certbot /usr/bin/certbot):"
echo "sudo certbot --nginx -d $url"

# ---------------------------------   VARIABLES   ---------------------------------

# --name - nombre de la app - obligatorio
# --repo - repositorio de github - obligatorio
# --port - puerto en el que correra el docker (el mismo que docker-compose.yml) - obligatorio
# --path - carpeta donde se guardara el proyecto
# --url - url del proyecto, sin https?://
# --files_path - ruta donde se encuentran las carpetas static y media (en base a la carpeta del proyecto "" si es en la misma)
# --extra_files - ruta de de archivos que se copiaran a la carpeta que no viene en el repo (como archivos .env .conf, etc)


# ---------------------------------   EJEMPLO   ---------------------------------
# ./ddd.sh --name "name" --repo "repo_url.git" --port "8001"
# ./ddd.sh --name "name" --repo "repo_url.git" --port "8001" --url "dns.dom"

# ./ddd.sh --name "me" --repo "git@github.com:Ojitos369/me.git" --port "8001" --url "me.ojitos369.com" --files_path "app"
