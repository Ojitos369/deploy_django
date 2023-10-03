#!/bin/bash

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --name) name="$2"; shift ;;
        --path) path="$2"; shift ;;
        --repo) repo="$2"; shift ;;
        --py) py="$2"; shift ;;
        --url) url="$2"; shift ;;
        --env) pwdenv="$2"; shift ;;
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
# ~
# replace ' ' and '_' with '-' in name
name=$(echo $name | sed -e 's/ /-/g' -e 's/_/-/g')
userpath="/home/$(whoami)"
path=${path:-"$userpath/Documents/progra/$name"}
py=${py:-"python3.11"}
url=${url:-""}


echo "name: $name"
echo "path: $path"
echo "repo: $repo"
echo "py: $py"
echo "url: $url"

# ---------------------------------   HACIENDO PATH   ---------------------------------
echo "---------------------------------   HACIENDO PATH   ---------------------------------"
rm -rf $path
mkdir -p $path
cd $path
pwdd=$(pwd)
echo "pwdd: $pwdd"
echo "Creando app..."
mkdir app
cd app
pwd=$(pwd)
echo "pwd: $pwd"
user=$(whoami)
echo "user: $user"

pwdenv=${pwdenv:-"$pwdd"}

# ---------------------------------   CLONANDO REPO   ---------------------------------
echo "---------------------------------   CLONANDO REPO   ---------------------------------"
run_command "git clone $repo ."

# ---------------------------------   ENTORNO VIRTUAL   ---------------------------------
echo "---------------------------------   ENTORNO VIRTUAL   ---------------------------------"
run_command "cd $pwdd"
run_command "$py -m venv venv"
# command="source venv/bin/activate && pip install -r requirements.txt && pip install gunicorn"
run_command "source $pwdd/venv/bin/activate"
run_command "pip install -r $pwd/requirements.txt"
run_command "pip install gunicorn"

# ---------------------------------   BASE FILES   ---------------------------------
echo "---------------------------------   BASE FILES   ---------------------------------"
# run_command "echo "logs" >> .gitignore"
# run_command "echo "run" >> .gitignore"
# run_command "echo "bin" >> .gitignore"
run_command "mkdir -p $pwdd/logs"
run_command "mkdir -p $pwdd/run"
run_command "mkdir -p $pwdd/bin"
run_command "touch $pwdd/bin/start.sh"
run_command "chmod +x $pwdd/bin/start.sh"

echo "Adding to bin/start.sh..."
file_to="$pwdd/bin/start.sh"

echo "#!/bin/bash" >> $file_to
echo "" >> $file_to
echo "NAME=\"$name\"" >> $file_to
echo "DJANGODIR=$pwd" >> $file_to
echo "SOCKFILE=$pwdd/run/gunicorn.sock" >> $file_to
echo "USER=$user" >> $file_to
echo "GROUP=sudo" >> $file_to
echo "NUM_WORKERS=2" >> $file_to
echo "DJANGO_SETTINGS_MODULE=app.settings" >> $file_to
echo "DJANGO_WSGI_MODULE=app.wsgi" >> $file_to
echo "" >> $file_to
echo "echo \"Starting ""$""NAME as `whoami`\"" >> $file_to
echo "" >> $file_to
echo "# Activar el entorno virtual" >> $file_to
echo "cd ""$""DJANGODIR" >> $file_to
echo "source $pwdd/venv/bin/activate " >> $file_to
echo "" >> $file_to
echo "# Variables de entorno" >> $file_to
echo "export PYTHONUNBUFFERED=1" >> $file_to
echo "export DJANGO_SETTINGS_MODULE=""$""DJANGO_SETTINGS_MODULE" >> $file_to
echo "export PYTHONPATH=""$""DJANGODIR:""$""PYTHONPATH" >> $file_to
echo "if [ ! -f $pwdenv/.env ]; then" >> $file_to
echo "    echo \"Creating .env file...\"" >> $file_to
echo "    touch $pwdenv/.env" >> $file_to
echo "fi" >> $file_to
echo "[ ! -f $pwdenv/.env ] || export ""$""(grep -v '^#' $pwdenv/.env | xargs)" >> $file_to
echo "cat $pwdenv/.env" >> $file_to
echo "" >> $file_to
echo "# Crear la carpeta run si no existe para guardar el socket linux" >> $file_to
echo "RUNDIR=""$""(dirname ""$""SOCKFILE)" >> $file_to
echo "test -d""$""RUNDIR || mkdir -p ""$""RUNDIR" >> $file_to
echo "" >> $file_to
echo "# Iniciar la aplicación django por medio de gunicorn" >> $file_to
echo "exec $pwdd/venv/bin/gunicorn ""$""{DJANGO_WSGI_MODULE}:application \\" >> $file_to
echo "--name ""$""NAME \\""" >> $file_to
echo "--workers ""$""NUM_WORKERS \\" >> $file_to
echo "--bind=unix:""$""SOCKFILE \\" >> $file_to
echo "--enable-stdio-inheritance \\" >> $file_to
echo "--reload \\" >> $file_to
echo "--capture-output \\" >> $file_to
echo "--log-level=debug \\" >> $file_to
echo "--log-file=-" >> $file_to


# ---------------------------------   SUPERVISOR CONF   ---------------------------------
echo "---------------------------------   SUPERVISOR CONF   ---------------------------------"
file_to="$pwdd/$name.conf"
touch $file_to
echo "Adding to $file_to..."
echo "[program:$name]" >> $file_to
echo "command = $pwdd/bin/start.sh ; Comando para iniciar la app" >> $file_to
echo "user = $user ; El usuario con el que vamos a correr la app" >> $file_to
echo "stdout_logfile = $pwdd/logs/gunicorn_supervisor.log ; Donde vamos a guardar los logs" >> $file_to
echo "redirect_stderr = true ; Guardar los errores en el log" >> $file_to
run_command "sudo mv $file_to /etc/supervisor/conf.d/"

run_command "sudo supervisorctl reread"

run_command "sudo supervisorctl update"

run_command "sudo supervisorctl status $name"
run_command "sudo supervisorctl stop $name"
run_command "sudo supervisorctl restart $name"
run_command "sudo supervisorctl start $name"

# ---------------------------------   NGINX   ---------------------------------
echo "---------------------------------   NGINX   ---------------------------------"
file_to="$pwdd/$name.conf"
touch $file_to
echo "Adding to $file_to..."
# sudo touch /etc/nginx/sites-available/myapp.conf
echo "upstream $name {" >> $file_to
echo "server unix:$pwdd/run/gunicorn.sock fail_timeout=0;" >> $file_to
echo "}" >> $file_to
echo "" >> $file_to
echo "server {" >> $file_to
echo "    server_name $url;" >> $file_to
echo "" >> $file_to
echo "client_max_body_size 4G;" >> $file_to
echo "" >> $file_to
echo "access_log $pwdd/logs/nginx-access.log;" >> $file_to
echo "error_log $pwdd/logs/nginx-error.log;" >> $file_to
echo "" >> $file_to
echo "location /static/ {" >> $file_to
echo "alias $pwd/static/;" >> $file_to
echo "}" >> $file_to
echo "" >> $file_to
echo "location /media/ {" >> $file_to
echo "alias $pwd/media/;" >> $file_to
echo "}" >> $file_to
echo "" >> $file_to
echo "location / {" >> $file_to
echo "# an HTTP header important enough to have its own Wikipedia entry:" >> $file_to
echo "# http://en.wikipedia.org/wiki/X-Forwarded-For" >> $file_to
echo "proxy_set_header X-Forwarded-For ""$""proxy_add_x_forwarded_for;" >> $file_to
echo "" >> $file_to
echo "# enable this if and only if you use HTTPS, this helps Rack" >> $file_to
echo "# set the proper protocol for doing redirects:" >> $file_to
echo "# proxy_set_header X-Forwarded-Proto https;" >> $file_to
echo "" >> $file_to
echo "# pass the Host: header from the client right along so redirects" >> $file_to
echo "# can be set properly within the Rack application" >> $file_to
echo "proxy_set_header Host ""$""http_host;" >> $file_to
echo "" >> $file_to
echo "# we don't want nginx trying to do something clever with" >> $file_to
echo "# redirects, we set the Host: header above already." >> $file_to
echo "proxy_redirect off;" >> $file_to
echo "" >> $file_to
echo '# set "proxy_buffering off" *only* for Rainbows! when doing' >> $file_to
echo "# Comet/long-poll stuff. It's also safe to set if you're" >> $file_to
echo "# using only serving fast clients with Unicorn + nginx." >> $file_to
echo "# Otherwise you _want_ nginx to buffer responses to slow" >> $file_to
echo "# clients, really." >> $file_to
echo "# proxy_buffering off;" >> $file_to
echo "" >> $file_to
echo "# Try to serve static files from nginx, no point in making an" >> $file_to
echo "# *application* server like Unicorn/Rainbows! serve static files." >> $file_to
echo "if (!-f ""$""request_filename) {" >> $file_to
echo "proxy_pass http://$name;" >> $file_to
echo "break;" >> $file_to
echo "}" >> $file_to
echo "}" >> $file_to
echo "" >> $file_to
echo "}" >> $file_to

run_command "sudo mv $file_to /etc/nginx/sites-available/"
run_command "sudo rm -f /etc/nginx/sites-enabled/$name.conf"
run_command "sudo ln -s /etc/nginx/sites-available/$name.conf /etc/nginx/sites-enabled/$name.conf"

run_command "sudo service nginx restart"
run_command "sudo supervisorctl restart $name"

echo "# alias recomendados:"
echo "# Restart (iniciales o identificador del proyecto) Django Deploy (ripdd)"
echo "# Simple Restart (iniciales o identificador del proyecto) Django Deploy (sripdd)"
echo "# Remplace xx por sus iniciales o identificador del proyecto"
echo "alias rxxdd='cd $pwd && git pull && source $pwdd/venv/bin/activate && pip install -r $pwd/requirements.txt && sudo supervisorctl restart $name'"
echo "alias srxxdd='sudo supervisorctl restart $name'"
echo ""
echo "# Ponga las variables de entorno en:"
echo "nvim $pwdd/bin/start.sh"
echo "# O en:"
echo "nvim $pwdenv/.env"
echo ""
echo "# Reinicie la app:"
echo "sudo supervisorctl restart $name"
echo "# Reinicie nginx:"
echo "sudo service nginx restart"
echo ""
echo "# Si quiere poner ssl (tener certbot instalado) (sudo snap install --classic certbot && sudo ln -s /snap/bin/certbot /usr/bin/certbot):"
echo "sudo certbot --nginx -d $url"

# ./ddp.sh --name "name" --repo "repo_url.git" --url "dns.dom"