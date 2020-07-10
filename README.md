# IRIS_Containers_Task

##### Shashank D
##### 181CO248
##### 9108787430, shashankindiamanoj@gmail.com


###### Steps:

##### 1. Dockerizing the given rails app.
  * Dockerfile:
  ```
  FROM ruby:2.5.1-stretch

  RUN mkdir /railsapp

  WORKDIR /railsapp
  COPY Gemfile /railsapp/Gemfile
  COPY Gemfile.lock /railsapp/Gemfile.lock
  RUN bundle install
  COPY . /railsapp
  RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
      && apt install -y nodejs

  COPY entrypoint.sh /usr/bin/
  RUN chmod +x /usr/bin/entrypoint.sh
  ENTRYPOINT [ "entrypoint.sh" ]
  EXPOSE 3000

  CMD ["rails", "server", "-b", "0.0.0.0"]
  ```
  * Tried building the image `sudo docker build -f Dockerfile -t railsappimg`
  * Checked using `sudo docker run -p 8080:3000 railsappimg`
##### 2. Setting up MySQL container and linking
  * Used __docker-compose__ to set-up the app
  * No port allocation for mysql on host.
  * `docker-compose.yml`
  ```
  version: "3.8"
  services: 
    web1:
        build: .
        command: bash -c "rm -f tmp/pids/server.pid && bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rails s -p 3000 -b '0.0.0.0'"
        depends_on: 
            - db
        volumes:
            - .:/railsapp
        ports: 
            - "8080:3000"
        links:
            - db
        environment: 
            - CONT="web1"
        env_file: 
            - '.env.web'
        restart: always
     db:
        image: library/mysql:5.7
        volumes: 
            - ../databasebackup/data:/var/lib/mysql
        env_file: 
            - '.env.db'
        restart: always
        expose:
            - '3306'
  ```
  
  * Change `config/database.yml` to:
  ```
    default: &default
    adapter: mysql2
    encoding: utf8
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    host: db
    username: <%= ENV["DB_USER"] %>
    password: <%= ENV["DB_PWD"] %>
  ```
  _environment variables are defined in .env.db and .env.web_
  
 * Tested the setup using `sudo docker-compose up`
 
 ##### 3. Nginx Reverse Proxy
 * Used pre-built nginx image
 * Changed the config file to match the requirements.
 * No port allocation on host for rails app, only accessible from nginx proxy.
 * Modified `docker-compose.yml` to use nginx reverse proxy service
 ```
  version: "3.8"
  services: 
    web1:
        build: .
        command: bash -c "rm -f tmp/pids/server.pid && bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rails s -p 3000 -b '0.0.0.0'"
        depends_on: 
            - db
        volumes:
            - .:/railsapp
        expose: 
            - "3000"
        links:
            - db
        environment: 
            - CONT="web1"
        env_file: 
            - '.env.web'
        restart: always
     db:
        image: library/mysql:5.7
        volumes: 
            - ../databasebackup/data:/var/lib/mysql
        env_file: 
            - '.env.db'
        restart: always
        expose:
            - '3306'
      
      rev_proxy:
        image: nginx:latest 
        depends_on: 
            - web1
            - db
        ports:
            - 8080:8080
        links:
            - web1
        volumes: 
            - ../revprx/nginx.conf:/etc/nginx/nginx.conf
        restart: always
  ```
  * Any http requests to `localhost` will be passed to `web1` service(rails app)
  * Set up proper http headers to abide same-origin
  * `nginx.conf`:
  ```
  user www-data;
  worker_processes auto;
  pid /run/nginx.pid;
  include /etc/nginx/modules-enabled/*.conf;

  http {
      server {
          listen 8080;
          server_name localhost 127.0.0.1;
          location / {
              proxy_pass  http://web1:3000;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Host $http_host;
              proxy_set_header X-NginX-Proxy true;
          }
      }
  }
  ```
  
  ##### 4. Launching more rail apps and loadbalancing.
  * Added two more web services from `docker-compose`
  * Final `docker-compose.yml`
  ```
  version: "3.8"
services: 
    web1:
        build: .
        command: bash -c "rm -f tmp/pids/server.pid && bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rails s -p 3000 -b '0.0.0.0'"
        depends_on: 
            - db
        volumes:
            - .:/railsapp
        expose: 
            - "3000"
        links:
            - db
        environment: 
            - CONT="web1"
        env_file: 
            - '.env.web'
        restart: always
       
    web2:
        build: .
        command: bash -c "rm -f tmp/pids/server.pid && bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rails s -p 3000 -b '0.0.0.0'"
        depends_on: 
            - db
            - web1
        volumes:
            - .:/railsapp
        expose: 
            - "3000"
        links:
            - db
        environment: 
            - CONT="web2"
        env_file: 
            - '.env.web'
        restart: always

    web3:
        build: .
        command: bash -c "rm -f tmp/pids/server.pid && bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rails s -p 3000 -b '0.0.0.0'"
        depends_on: 
            - db
            - web1
            - web2
        volumes:
            - .:/railsapp
        environment: 
            - CONT="web3"
        expose: 
            - "3000"
        links:
            - db
        env_file: 
            - '.env.web'
        restart: always
              
          
    db:
        image: library/mysql:5.7
        volumes: 
            - ../databasebackup/data:/var/lib/mysql
        env_file: 
            - '.env.db'
        restart: always
        expose:
            - '3306'
    
    rev_proxy:
        image: nginx:latest 
        depends_on: 
            - web1
            - web2
            - web3
            - db
        ports:
            - 8080:8080
        links:
            - web1
            - web2
            - web3
        volumes: 
            - ../revprx/nginx.conf:/etc/nginx/nginx.conf
        restart: always
```

* Used the default Round-Robin Load balancing.
* `nginx.conf`:
```
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

http {          
    upstream railapps {
        server web1:3000 weight=1;
        server web2:3000 weight=1;
        server web3:3000 weight=1;
    }
    server {
        listen 8080;
        server_name localhost 127.0.0.1;

        location / {
            proxy_pass  http://railapps;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_set_header X-NginX-Proxy true;
        }
    }
}
```
##### 5. Data Persistance
* Used `volume` mounts for both mysql container and nginx container.
* In `docker-compose.yml`
```
[...]
   volumes: 
               - ../databasebackup/data:/var/lib/mysql
[...]
   volumes: 
               - ../revprx/nginx.conf:/etc/nginx/nginx.conf
```

##### 6. Docker-Compose
* All services are properly linked, so can start all of them with `docker-compose up`

##### 7. Rate Limiting
* Limited the client to have 3 request per second with maximum of 20 in queue(bursts)
* Modified nginx.conf
```
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

http {
    limit_req_zone $binary_remote_addr zone=one:10m rate=3r/s;
            
    upstream railapps {
        server web1:3000 weight=1;
        server web2:3000 weight=1;
        server web3:3000 weight=1;
    }
    server {
        listen 8080;
        server_name localhost 127.0.0.1;

        location / {
            proxy_pass  http://railapps;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_set_header X-NginX-Proxy true;

            limit_req zone=one burst=20 nodelay;
        }
    }
}
```
#### 8. Scheduled Database Dump
* Used crontab in the host.
* Accessed the mysql client in the container using `docker-compose exec` and executed a shell script to dump the database to host machine everyday
```
0 0 * * * cd /home/sha68/irissys2/Shopping-App-IRIS && sudo docker-compose exec db mysql sh -c 'echo "[client]\n host=\"$MYSQL_PORT_3306_TCP_ADDR\"\n user=root\n password=\"$MYSQL_ENV_MYSQL_ROOT_PASSWORD\"" > my.cnf && exec mysqldump --defaults-file=my.cnf --all-databases' > '/home/sha68/irissys2/databasebackup/dump'
```





 
  
