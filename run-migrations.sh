red="\e[31m"
green="\e[32m"
reset="\e[0m"

. ./.env

for flag in $@; do
    case $flag in
        --no-drop)
            DROP=nope
        ;;
        --no-ddl)
            DDL=nope
        ;;
    esac
done

if [ -n $DROP]; then
    echo -e "${green}Dropando o public schema${reset}"
    DROP_COMMAND="DROP SCHEMA public CASCADE;CREATE SCHEMA public;"
    PGPASSWORD=$PGPASSWORD psql -h $HOST -d $DB_DATABASE -U $DB_USERNAME -p $PORT -c "$DROP_COMMAND"
fi

for MIGRATION in migrations/*; do
    # if [[ $DDL = 'nope' && ${MIGRATION##*/} = *00-ddl* ]]; then
    #     echo -e "${red}Ignorado$reset: $MIGRATION"
    #     echo Motivo: scripts de ddl desativados
    #     continue
    # fi

    echo "${green}Executando${reset}: ${MIGRATION}";
    PGPASSWORD=$PGPASSWORD psql -v ON_ERROR_STOP=1 -h $HOST -d $DB_DATABASE -U $DB_USERNAME -p $PORT -f "$MIGRATION"
    if [ $? -ne 0 ]; then
        echo "${red}Encerrando devido a erro${reset}";
        break;
    else
        echo "${green}Sucesso!${reset}";
    fi
done;
