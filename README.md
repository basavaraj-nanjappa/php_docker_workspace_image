## After cloning, please unzip the compressed files

### How to use
1. You build it first, see it through then go to `Step#3`, if you don't want to see build part, go straight to `Step#2`
    - PS: I am not too sure it will build yet (because I guess it requires certain sqllibdir, which only comes or found when you install the DB2 Server)
    - `docker-compose -f docker-compose-ogfin_php_ws.yml build --progress=plain`
2. Try running the docker-compose, which should build the image and starts the container
    - `docker-compose -f docker-compose-ogfin_php_ws.yml up -d`
- The container will be running with tty mode, hence you can get inside the container
    - `docker-compose exec -it ogfin_php_ws-1 bash`
    - Once you are inside the container, try coding to connect to DB2 remote server, run a Lumen/Laravel based php application, Try GraphQL, Use it like your workstation
- // TBD