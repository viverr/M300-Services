# Code Erklärung
In diesem README wird die Funktion der Vagrant erklärt.

## Inhaltsverzeichis
1. [Die Repository Struktur](##Repository-Struktur)
2. [Funktionen der Files](##Funktionen-der-Files)
3. [Vagrant](##Vagrant)
4. [db.sh](##db.sh)
5. [Funktion der Code Teile - Vagrant](##Funktion-der-Code-Teile-[Vagrant])
6. [Funktion der Code Teile - DB.SH](##Funktion-der-Code-Teile-[DB.SH])
7. [Probleme die aufgetaucht sind](##Probleme-die-aufetaucht-sind)


## Repository Struktur
Die Struktur des M300-Services/lb02 Repositories sieht folgendermassen aus:
```
M300-Services/
  ├─ lb02/
     ├─ README.md
     ├─ db.sh
     ├─ Vagrant
     ├─ home.html
     ├─ db_php.php
```
**Die wichtigsten Dateien hier sind:**
- Vagrant
- db.sh

## Funktionen der Files:
**Vagrant** ->
Die Wohl wichtigste Datei der gesamten Arbeit. In dieser stehen die Bausteine für die automatische Erstellung der VM mit allen Programmen welche benötigt werden.

```
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "datenbank-vm" do |db|
    db.vm.box = "ubuntu/xenial64"
	db.vm.provider "virtualbox" do |vb|
	  vb.memory = "2048"  
	end
    db.vm.hostname = "datenbank-server"
    db.vm.network "private_network", ip: "192.168.2.99"
  	db.vm.provision "shell", path: "db.sh"
  end

  config.vm.define "apache-webserver" do |web|
    web.vm.box = "ubuntu/xenial64"
    web.vm.hostname = "webserver"
    web.vm.network "private_network", ip:"192.168.2.98" 
	web.vm.network "forwarded_port", guest:80, host:8080, auto_correct: true
	web.vm.provider "virtualbox" do |vb|
	  vb.memory = "2048"  
	end     

  	web.vm.synced_folder ".", "/var/www/html"  
	web.vm.provision "shell", inline: <<-SHELL
		sudo apt-get update
		sudo apt-get -y install debconf-utils apache2 nmap
		sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'
		sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'
		sudo apt-get -y install php libapache2-mod-php php-curl php-cli php-mysql php-gd mysql-client  
		# Admininer SQL UI 
		sudo mkdir /usr/share/adminer
		sudo wget "http://www.adminer.org/latest.php" -O /usr/share/adminer/latest.php
		sudo ln -s /usr/share/adminer/latest.php /usr/share/adminer/adminer.php
		echo "Alias /adminer.php /usr/share/adminer/adminer.php" | sudo tee /etc/apache2/conf-available/adminer.conf
		sudo a2enconf adminer.conf 
		sudo service apache2 restart 
	  echo '127.0.0.1 localhost webserver\192.168.2.99 datenbank-server' > /etc/hosts
SHELL
	end  
end
```
##
**db.sh** -> Steht für "Database Shell Script" und wird von der Vagrant File dazu verwendet mit dem bereits vorinstallierten MySQL eine Testtabelle zu erstellen. In dieser Tabelle wird ein Wert eingefügt welcher dann theoretich durch PHP Anfragen auf der Index.html Datei des Apache2 Server angezeigt werden sollte.

```
#!/bin/bash

# ROOT SETZUNG - DER ADMIN BENUTZER WIRD ERSTELLT ALS ROOT
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'
#-----------------------

#-----INSTALL MYSQL-----
sudo apt-get install -y mysql-server
#-----------------------

#-----CONFIG STAGE------
# PORT ÖFFNEN
sudo sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
#-----------------------

# TABELLEN ERSTELLUNG UND REMOTE ACCESS
mysql -uroot -padmin <<%EOF%
	CREATE USER 'root'@'192.168.2.98' IDENTIFIED BY 'admin';
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.2.98' IDENTIFIED BY 'admin' WITH GRANT OPTION;
	FLUSH PRIVILEGES;
	CREATE DATABASE DB-LB02;
	USE DB-LB02;
	CREATE TABLE DB-LB02(Titel VARCHAR(50), Beschreibung VARCHAR(50));
	INSERT INTO DB-LB02 VALUE ("TESTWERT","Dieser Wert sollte angezeigt werden.");
	quit
%EOF%
#-----------------------

#-----RESTART-----
# MYSQL NEUSTARTEN - AKTUALISIERUNG
sudo service mysql restart
#-----------------------
```

## Funktion der verschiedenen Code-Teile [Vagrant]
**CONFIGURE Funktion**
```
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
```
Diese Funktion initiert die grundlegene Erstellung der VMs, dieser Teil muss in jedem Vagrant angegeben werden. Darin wir so gut wie alles definiert.
##
**VM Erstellungs Block**
```
config.vm.define "datenbank-vm" do |db|
    db.vm.box = "ubuntu/xenial64"
	db.vm.provider "virtualbox" do |vb|
	  vb.memory = "2048"  
	end
    db.vm.hostname = "datenbank-server"
    db.vm.network "private_network", ip: "192.168.2.99"
  	db.vm.provision "shell", path: "db.sh"
  end
```
- *define:* Definiert die ID der VM
- *box:* OS Paket welches installiert wird
- *provider:* Welcher Hypervisor soll verwendet werden?
- *memory:* Erlaubte RAM Nutzung
- *hostname:* VM Name (Für ssh)
- *network:* Netzwerk Adapter definieren
- *provision:* Skript welches in der VM ausgeführt werden soll (Shell Skripte etc.)
##
**Eingabe in der COMMANDLINE**
```
web.vm.provision "shell", inline: <<-SHELL
		sudo apt-get update
		sudo apt-get -y install debconf-utils apache2 nmap
		sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'
		sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'
		sudo apt-get -y install php libapache2-mod-php php-curl php-cli php-mysql php-gd mysql-client  
		# Admininer SQL UI 
		sudo mkdir /usr/share/adminer
		sudo wget "http://www.adminer.org/latest.php" -O /usr/share/adminer/latest.php
		sudo ln -s /usr/share/adminer/latest.php /usr/share/adminer/adminer.php
		echo "Alias /adminer.php /usr/share/adminer/adminer.php" | sudo tee /etc/apache2/conf-available/adminer.conf
		sudo a2enconf adminer.conf 
		sudo service apache2 restart 
	  echo '127.0.0.1 localhost webserver\192.168.2.99 datenbank-server' > /etc/hosts
SHELL
```
Der Text der innerhalb der ***web.vm.provision "shell", inline: <<-SHELL*** Funktion wird in der VM Line-to-Line ausgeführt.

## Funktion der verschiedenen Code-Teile [DB.SH]
**Account Erstellung MySQL**
```
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'
```
Dieser Teil ist dafür zuständig den vorgefertigten Admin Account für die MySQL Database zu definieren.

**MySQL Installation**
```
sudo apt-get install -y mysql-server
```
Dieser Teil initiert die Installation des MySQL Services.

**Tabellen Erstellung und Root Account**
```
mysql -uroot -padmin <<%EOF%
	CREATE USER 'root'@'192.168.2.98' IDENTIFIED BY 'admin';
	GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.2.98' IDENTIFIED BY 'admin' WITH GRANT OPTION;
	FLUSH PRIVILEGES;
	CREATE DATABASE DB-LB02;
	USE DB-LB02;
	CREATE TABLE DB-LB02(Titel VARCHAR(50), Beschreibung VARCHAR(50));
	INSERT INTO DB-LB02 VALUE ("TESTWERT","Dieser Wert sollte angezeigt werden.");
	quit
%EOF%
```
Hier werden die MySQL Root Rechte an den vorgefertigten Admin Account übertragen und durch diesen eine Testtabelle erstellt.

## Probleme die aufgetaucht sind
Mein Ziel war es den Testtabellenwert der MySQL Tabelle durch PHP auf der home.html anzuzeigen. Jedoch konnte ich trotz ständiges Testen nie eine Verknüpfng aufbauen können. Das PHP und HTML Dokument wurde nie vom Apache2 korrekt ausgeführt und so konnte der Wert auch nicht abgeruft werden können.

Auf der Website hätte es folgend aussehen sollen:
|             Testtabelle              |
|--------------------------------------|
| Dieser Wert sollte angezeigt werden. |
