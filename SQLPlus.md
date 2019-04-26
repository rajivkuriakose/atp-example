# How to connect to ATP using SQL Plus

I have created ATP instance using terraform from OCI compute instance. 
Here are the steps to connect to ATP instance using sqlplus, from OCI compute instance.

## Install Oracle Instant Client RPM

I have provisioned compute instance using Oracle Linux 7.6 image. From OCI compute instance, run below steps to install instant client.

to pull the correct yum repo, need to figure out the OCI Region. My account is in Ashburn region(Home Region).
Use below steps to figure out the region code. 
```
cd /etc/yum.repos.d
 
# specific to OCI compute instances, get the yum mirror for the region
export REGION=`curl http://169.254.169.254/opc/v1/instance/ -s | jq -r '.region'| cut -d '-' -f 2`

# use below commands to verify that the region is set
export | grep REGION
or
echo $REGION

I am in Ashburn region. So above commanded returned iad

#  below command will download the yum repo file your your region
sudo -E wget http://yum-$REGION.oracle.com/yum-$REGION-ol7.repo

# Since I am in Ashburn region, it downloaded yum-iad-ol7.repo
# open yum-iad-ol7.repo
less yum-iad-ol7.repo

TBD # List available packages before enabling the repo - include image
# list all packages with name 
yum list oracle-instantclient*   

# There is and entry with name "ol7_oci_included" in yum-iad-ol7.repo
# enable repository wih name "ol7_oci_included" using yum-config-manager 
sudo yum-config-manager --enable ol7_oci_included

```

# list all packages after enabling the repo
```
yum list oracle-instantclient*    

```

We can seet that oracle-instantclient* packages are available now.

# install required pkgs
```
sudo yum install -y  oracle-instantclient18.3-basic.x86_64 oracle-instantclient18.3-devel.x86_64 oracle-instantclient18.3-jdbc.x86_64 oracle-instantclient18.3-sqlplus.x86_64 oracle-instantclient18.3-precomp.x86_64 oracle-instantclient18.3-tools.x86_64
```


Now sqlplus binary is available under /usr/lib/oracle/18.3/client64/bin

### Download and unzip wallet zip file

Since I have created ATP instance using terraform, from this OCI compute instance, the wallet zip file is already available under "/home/opc/atp-example/autonomous_database_wallet.zip"

cd /home/opc/atp-example/

 jar -tvf /home/opc/atp-example/autonomous_database_wallet.zip
  6661 Fri Apr 12 13:53:16 GMT 2019 cwallet.sso
  3422 Fri Apr 12 13:53:16 GMT 2019 tnsnames.ora
  3336 Fri Apr 12 13:53:16 GMT 2019 truststore.jks
    87 Fri Apr 12 13:53:16 GMT 2019 ojdbc.properties
   114 Fri Apr 12 13:53:16 GMT 2019 sqlnet.ora
  6616 Fri Apr 12 13:53:16 GMT 2019 ewallet.p12
  3243 Fri Apr 12 13:53:16 GMT 2019 keystore.jks
  
  ### Download Wallet zip from Service Console
Otherwise you need to login to ATP Instance's Service Console. Default user name is "admin". 
After login, go to Administration link on left side. And click "Download Client Credentials (Wallet)"

Provide a wallet password to download the wallet zip file.  Now this client credentials (wallet) can used to login from SQL Developer and other sql clients liek SQL Plus. If you have downloaded the zip from windows, you would need to scp the file to OCI compute host.

Once the wallet zip is present on oci compute host, continue with below steps.

## Unzip wallet archive
unzip autonomous_database_wallet.zip
cd autonomous_database_wallet

### Modify sqlnet.ora 
Modify sqlnet.oraand give path to walet folder as "/home/opc/atp-example/autonomous_database_wallet"

Here is 
```cat /home/opc/atp-example/autonomous_database_wallet/sqlnet.ora```
WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="/home/opc/atp-example/autonomous_database_wallet")))
SSL_SERVER_DN_MATCH=yes

OR set TNS_ADMIN variable to point to wallet folder. And Modify sqlnet.ora
And give DIRECTORU=$TNS_ADMIN

cat /etc/ORACLE/WALLETS/ATPDB2/sqlnet.ora
WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="$TNS_ADMIN")))
SSL_SERVER_DN_MATCH=yes

#Now export TND_ADMIN variable to point to wallet folder
export TNS_ADMIN=/home/opc/atp-example/autonomous_database_wallet


#wallet zip is extracted and TNS_ADMIN env var pointing to the wallet folder.
Refer https://docs.oracle.com/en/cloud/paas/atp-cloud/atpug/connect-sqlplus.html#GUID-A3005A6E-9ECF-40CB-8EFC-D1CFF664EC5A


### Connect to ATP instane using SQL Plus

```
/usr/lib/oracle/18.3/client64/bin/sqlplus admin/Welcome#1234@atpdb2_low
```

### create schema in ATP instance using SQL Plus
```
/usr/lib/oracle/18.3/client64/bin/sqlplus admin/Welcome#1234@atpdb2_low @/home/opc/schema/create_tables.sql
```
