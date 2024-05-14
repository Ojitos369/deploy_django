# Deploy para django

## Parametros
* name: Nombre el proyecto (sin espacios, utlizar -) (Requerido)  
* repo: Url del repositorio que se utilizara (git clone $repo) (Requerido)  
* path: Directorio donde se va a guardar el proyecto (Por defecto en ~/Documents/progra/$name)  
* py: Version de python para utilizar (Por defecto 3.11)  
* url: Url del sitio (sirve para verificacion ssl)  
* env: Ruta donde se guardara el archivo .env (Por defecto en $path)  
* req_path: Ruta donde se guardara el archivo requirements.txt (Por defecto en $path/app/)  
* req_file: Nombre del archivo requirements.txt (Por defecto "requirements.txt")  
* man_path: Ruta donde se guardara el archivo manage.py (Por defecto en $path/app/)  
* app_name: Nombre del proyecto de django (Por defecto "app")  
* conda: Si se usa conda (Por defecto false)  
* id: Iniciales o identificador del proyecto (Por defecto "xx" - si se usa conda es obligatorio)  

## Estructura
La estructura queda de la siguiente manera  

$path  
├── $name  
│   ├── $app_name  
│   │   ├── (En esta ruta se realiza un "git clone $repo .")  
│   │   ├── your_code...  
│   │   ├── requirements.txt  
│   │   ├── .git/  
│   ├── logs  
│   ├── run  
│   ├── bin  
│   │   ├── start.sh  
│   ├── venv  
  
> Se requiere que el requirements.txt este en la raiz del proyecto
> Para poder configurar el entorno correctamente


## Ejemplos  
```bash  
./ddp.sh --name "name" --repo "repo_url.git" --url "dns.dom"  
./ddp.sh --name "name" --repo "repo_url.git" --py "python3.12" --url "dns.dom" --conda "s" --id "app"  
./ddp.sh --name "name" --repo "repo_url.git" --py "python3.10" --url "dns.dom" --app_name "polls"  
./ddp.sh --name "name" --repo "repo_url.git" --py "python3.8" --url "dns.dom" --app_name "polls" --conda "s" --id "app"  
```

