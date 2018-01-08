#!/usr/bin/env bash

#set -e

ProjectName="MYAPP"

FILE_PROJECT="projectname"

CK='\u2714'
ER='\u274c'

alias cls='printf "\033c"'

export DEV_UID=$(id -u)
export DEV_GID=$(id -g)

app_start()
{
    export ProjectName=$(cat projectname)
    docker-compose -f docker-compose.yml down &&
    docker-compose -f docker-compose.yml up
}


app_install()
{

    mkdir ~/nodecache && chmod 777 ~/nodecache

    if [ -f "$FILE_PROJECT" ];
    then
       app_console npm install
    else
       app_create
    fi
}

app_create()
{
    echo -n "Project name ($ProjectName)? "
    read answer
    if [ $answer ]; then
      ProjectName="$answer"
    fi

    echo "$ProjectName" > projectname
    echo "$ProjectName"/node_modules >> .gitignore

    mkdir $ProjectName && docker-compose -f docker-compose.tasks.yml run --rm --user $(id -u):$(id -g) node ng new $ProjectName
}

app_console()
{
    export ProjectName=$(cat projectname)
    docker-compose -f docker-compose.ng.yml run --rm --user $(id -u):$(id -g) node $@
}

app_ng()
{
    export ProjectName=$(cat projectname)
    docker-compose -f docker-compose.ng.yml run --rm --user $(id -u):$(id -g) node ng $@
}

app_docker_images_build()
{
   docker-compose -f docker-compose.build.yml build $@
}

case "$1" in
"install")
    app_install
    ;;
"start")
    app_start
    ;;
"build")
    app_docker_images_build ${@:2}
    ;;
"console")
    app_console ${@:2}
    ;;
"ng")
    app_ng ${@:2}
    ;;
*)
    echo -e "\n\n\n$ER [APP] No se especifico un comando valido\n"
    ;;
esac