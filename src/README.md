# README

## Deploy to Heroku

- Run `heroku login`
- Run `heroku create`

> If you need to add environment variables use config vars from Heroku.
> Add all of the declared vars in .env(do not forget the database password)

- Run `git push heroku master`
- Run `heroku run rails db:migrate`
- Look at your app using `heroku open`

> if you need to look at the production console, you could use `heroku run rails console`

> If you need to review your database you could use `heroku pg:psql`

_Any rails command could be used with heroku run_

## Deploy to AWS

### On AWS

1. Create an EC2 Instance.
2. Select OS, RAM, SSD capacity and open ports.
3. Copy the server ip

### Connect to the Server with the IP address

```bash
ssh ubuntu@<server ip>
```

### Install Ruby dependencies

```bash
# Add Node.js repository
$ curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
# Add Yarn repository
$ curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
$ echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
$ sudo add-apt-repository ppa:chris-lea/redis-server
# Refresh our packages list with the new repositories
$ sudo apt-get update
# Install dependencies for compiiling Ruby along with Node.js and Yarn
$ sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev dirmngr gnupg apt-transport-https ca-certificates redis-server redis-tools nodejs yarn
```

### Install Ruby using Rbenv

```bash
$ git clone https://github.com/rbenv/rbenv.git ~/.rbenv
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc
$ git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
$ echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
$ git clone https://github.com/rbenv/rbenv-vars.git ~/.rbenv/plugins/rbenv-vars
$ exec $SHELL
$ rbenv install 2.7.2
$ rbenv global 2.7.2
$ ruby -v
# ruby 2.7.2
# Install the latest Bundler, currently 2.x.
gem install bundler
# Make sure bundler is installed correctly, you should see a version number.
bundle -v
# Bundler version 2.x
source ~/.bashrc
```

### Install Postgres

```bash
$ sudo apt-get install postgresql postgresql-contrib libpq-dev
```

Change peer to md5 on pg_hba.conf

```bash
$ sudo nano /etc/postgresql/{version}/main/pg_hba.conf
```

```diff
...
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
- local   all             all                                     peer
+ local   all             all                                     md5
....
```

Restart postgres service

```bash
sudo service postgresql restart
```

Create postgres user

```bash
$ sudo -u postgres createuser <username>
```

Give the user a password

```bash
$ sudo -u postgres psql
```

```psql
psql=# alter user <username> with encrypted password '<password>';
psql=# alter user <username> with superuser;
psql=# \q
```

> If you want to just use psql
>
> ```
> CREATE USER <username> WITH ENCRYPTED PASSWORD '<password>';
> ALTER USER <username> WITH SUPERUSER;
> ```

### Install your app

```bash
$ cd ~
$ git clone <your repo url>
$ cd <repo directory>
```

Create the file `.env` and paste in it the content of your local file.

Create the file `config/master.key` and paste in it the content of your local file.

Install gems

```bash
$ bundle install
```

Create the database.

```bash
$ RAILS_ENV=production rails db:create
$ RAILS_ENV=production rails db:migrate
$ RAILS_ENV=production rails db:seed
$ sudo nano /config/environments/production.rb
```

Change `production.rb` to be like:

```diff
...
# Do not fallback to assets pipeline if a precompiled asset is missed.
- config.assets.compile = false
+ config.assets.compile = true
...
```

Precompile your assets

```bash
$ RAILS_ENV=production rails assets:precompile
```

### Install Passenger & Nginx

```bash
$ sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
$ sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main > /etc/apt/sources.list.d/passenger.list'
$ sudo apt-get update
$ sudo apt-get install -y nginx-extras libnginx-mod-http-passenger
$ if [ ! -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ]; then sudo ln -s /usr/share/nginx/modules-available/mod-http-passenger.load /etc/nginx/modules-enabled/50-mod-http-passenger.conf ; fi
$ sudo ls /etc/nginx/conf.d/mod-http-passenger.conf
```

Edit passenger config file

```bash
# If you want to use the Nano for editing
$ sudo nano /etc/nginx/conf.d/mod-http-passenger.conf
```

Change the passenger ruby instruction

```diff
- passenger_ruby /usr/bin/passenger_free_ruby;
+ passenger_ruby /home/ubuntu/.rbenv/shims/ruby;
```

Restart nginx

```bash
sudo service nginx start
```

Change the default server

```bash
sudo nano /etc/nginx/sites-enabled/default
```

Comment out all the lines in the file using `#` then update the file accordingly

```diff
...
+ server {
+   listen 80;
+   listen [::]:80;
+
+   server_name _;
+   root /path/to/your/app/public;
+
+   passenger_enabled on;
+   passenger_app_env production;
+   location ~ ^/(assets|packs) {
+     expires max;
+      gzip_static on;
+    }
+ }
```

Reload nginx service

```bash
$ sudo service nginx reload
```

Access your server ip from the browser, look at your deployed repo!
