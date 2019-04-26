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
TBD

### point TNS_ADMIN env var to wallet locaton

export | grep TNS
 #declare -x TNS_ADMIN="/home/opc/ATPJava/wallet_DB/"

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
