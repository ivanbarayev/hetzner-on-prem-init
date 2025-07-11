## Hetzner cloud or baremetal server installation script

#### Only for debian based distros !

### Installation

```shell
bash <(curl -s https://raw.githubusercontent.com/ivanbarayev/hetzner-on-prem-init/master/install.sh)
```
---

```shell
To open Postgres to remote connection

# Step 1
sudo nano /etc/postgresql/$VERSION/main/postgresql.conf   #change $VERSION number with installed version

# Find the CONNECTIONS AND AUTHENTICATION section and the line #listen_addresses = 'localhost' in the configuration file.
# Change the line value to listen_addresses = '*'
# Don't forget to uncomment line

# Step 2
sudo nano /etc/postgresql/$VERSION/main/pg_hba.conf   #change $VERSION number with installed version
# Find the IPv4 local connections line. Specify the desired network. For example, like this:
# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256

# And change it to ;
# IPv4 local connections:
host    all             all             0.0.0.0/0            md5

# You can use other authentication methods. 

systemctl restart postgresql
```
For a complete list, see the [PostgreSQL documentation](https://www.postgresql.org/docs/current/index.html)

```shell
# For change or set ROOT password
sudo su - postgres psql
\password postgres
\q
```