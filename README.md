# Deploy para django

## Parametros
* name: Nombre el proyecto (sin espacios, utlizar -) (Requerido)  
* path: Directorio donde se va a guardar el proyecto (Por defecto en ~/Documents/progra/$name)  
* repo: Url del repositorio que se utilizara (git clone $repo) (Requerido)  
* py: Version de python para utilizar (Por defecto 3.11)  
* url: Url del sitio (sirve para verificacion ssl)  
* env: Ruta donde se guardara el archivo .env (Por defecto en $path)  


## Estructura
La estructura queda de la siguiente manera
$path  
├── $name  
│   ├── app  
│   │   ├── (En esta ruta se realiza un "git clone $repo .")  
│   │   ├── your_code...  
│   │   ├── requirements.txt  
│   │   ├── .git/  
│   ├── logs  
│   ├── run  
│   ├── bin  
│   │   ├── start.sh  
│   ├── venv  
  
> Se requiere que el requirementes este en la raiz del proyecto
> Para poder configurar el entorno correctamente


## Ejemplo
```bash
./ddp.sh --name "name" --repo "repo_url.git" --url "dns.dom"
```

