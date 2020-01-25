# WORK IN PROGRESS #

##  SECURITY WARNING ##

This docker-compose stack has exposed passwords and users, it is not secure.  If you are going to use outside a firewall you'll need to make appropriate modifications to ensure that everyone doens't have your creditials.



This repository is designed to run the [OpenHAB2][2] home automation environment within a [RancherOS][1] environment.  Although untested it can likely be modified slightly to run wihtout the `rancher-compose.yml` file and small modifications to the `docker-compose.yml` file to enable this to run on another host system using Docker.

The stack is being built on a [RancherOS v1.6][3] install (baremetal).  This means that in addition to the restrictions associated with limited docker EXEC support due to the thin OS within the Docker, that there is no base OS.  RancherOS is the actual underlying host OS and any services at that host level actually run as seperate Docker containers.

This build also anticipates that you'll be using a seperate NFS store for configuration and data files.  For RancherOS configuration purposes the [Rancher Community nfs-driver][4] is used for defining how volumes are installed.  Once the driver is installed and connected to the NFS the addition, deletion and executing within the NFS is handled by RancherOS and the NFS OS.

Tested:

For purposes of understanding the platform that this stack is being devleoped for, the NFS is a stand alone FreeNAS-11.2-U6.  The RancherOS is running on a stand along Rizen 9 with RancherOS as the host operating system (this is not a VM or host with another OS).

Packaged:

openhab:2.5.1

The OpenHAB setup runs the normal OpenHAB Docker distribution which doesn't include Frontail.  It runs both ports 8080 and 8443, however, for conflict management these two ports are forwarded to porst 8081 and 8443.  Port 8080 is the defual RancherOS UI interface.  These ports can be changed in both the Environment Variables of the docker-compose file or in port assignments of the docker-compose.

The user and user_group environmental variables are set to 2000:2000.  These variables should be changed to conform to your NFS user and group configuration.  The tested configuration uses user name `openhab` and user_id/group_id `2000`.   On FreeNAS the first auto assigned user id is 1000 and depending on what user ids you've setup on the NFS you'll likely want to ensure there isn't a conflict (learned the hard way). Later you'll see that permissions is still an open issue on RancherOS 1.6 and you'll need to use `chmod` and `chown` from the NFS CLI to migrate certain files.

nodered:latest

influxdb:latest

(influx environment variables are not passed by the docker-compose file - still have to manual input from cli.  To be fixed.)

grafana:latest

frontail:4.8

Frontail has to be installed in steps as described below.  When initially launched the container will not show formatted logging or presets (see below).  The `docker-compose` uses the standard frontail container, but remapps the port from 9001 to 9002.  If you are using an MQTT Broker (such as MosquittoMQTT) the default port assignment is 9001.  The frontail port is remapped to avoid the conflict.

Todo:
add load balancing (java performance)
add documentation
develop secrets for environment variabls/passwords
develop rancher catalog items
add install directions from rancher catalog
add vm to manage bash scripting (RancherVM?)


Install Instructions (Mannual):

From the Rancher select `STACKS`, `ALL` from the top dropdown menu.

Selected the `Add Stack` from the top button bar.

Either upload or cut-and-paste both the `docker-compose.yml` and teh `rancher-compose.yml` files into the user dialog.  Name the stack and, optionally, provide a description.  Note that the stack name is used with the Rancher `nfs-driver` for namespace purposes when installing the volumes.  The formate will be `NAMEOFYOURSTACK_userdata_xxxxx` as an example for the OpenHAB userdata volumn.

The select `Create`.

Once the stack comes on line, the `frontail` container will not run correctly and the `grafana` will cycle but not start.  Both relate to missing files and missing NFS permissions.  

Fixing Grafana

Open an SSH session with the NFS server.  There you'll find that the store named `NAMEOFYOURSTACK_grafanadata_xxxxx` has something other than user_id/group_id of `472`.  Grafana is looking for RW permission.  (Hack...  On FreeNAS there is a system user named `NOMAD` with user_id/group_id of 472.  This is a pre-existing user.  I left this as is - if you don't have this user_id/group_id you'll need to set it up.  If using `NOMAD` is a problme - I'll let you know when it crashes.) Navigate to the parent directory (likely the nfs-driver store setup in RancherOS) and execute the following:

chown -R 472:472 SNAMEOFYOURSTACK_grafanadata_xxxxx

For the FreeNAS NFS it changes the owner to `NOMAD` who has both user_id/group_id of `472` which is what Grafana is looking for.  Immediately after the ownership change is made the Grafana container should become active.

Fixing Frontail

Next you'll have to install the presets json and css files for frontail.  After extensive research I think there is a missing cross reference to the `git` libraries when trying to use `ADD` in a `Dockerfile` through the `docker-compose` build process.  The end result is that you cannot build upon a prior layer by simply adding files on the last layer.  This process works fine with Docker on a Windows, MAC and Ubuntu (all tested) system, but not on RancherOS.  Because the intial container construction cannot include dependency files that are not part of the official Frontail image (without some substantial Dockerfile rework), the docker-compose.yml command line for the frontail container is 

`--disable-usage-stats -l 2000 -n 200 /logs/logs/openhab.log /logs/logs/events.log` 

which omits all formatting for the log files.  

Therefore, the work around.

Navigate to the `NAMEOFYOURSTACK_frontailweb_xxxxx` and execute the following:

`wget https://raw.githubusercontent.com/Llibyddap/openHAB-Rancher/master/openhab.css`
`wget https://raw.githubusercontent.com/Llibyddap/openHAB-Rancher/master/bootstrap.min.css`

This will download the base bootstrap css file for basic html formating and then the the openhap specific html formating to give it the official branding.

Then navigate to the `NAMEOFYOURSTACK_frontailpresets_xxxxx` and execute the following:

`wget https://raw.githubusercontent.com/Llibyddap/openHAB-Rancher/master/openhab.json`

Once both frontail dependency files are isntalled you'll be able to upgrade the frontail container.  (You can upgrade the container by selection the far right burger from teh 

`--disable-usage-stats --ui-highlight --ui-highlight-preset /frontail/preset/openhab.json -t openhab -l 2000 -n 200 /logs/logs/openhab.log /logs/logs/events.log`

This new command line will provide the html highlighting (the css files) and the formating criteria fromt eh openhab.json files.  Once the upgrade container is active, navidate to the RancherOS_IP_address:8081 where you should be able to confirm that the logging looks very familiar.

If acceptable, you can finish the upgrade process.

Install Instructions (Rancher Catalog):




[1]:https://rancher.com/rancher-os/
[2]:https://www.openhab.org/
[3]:https://github.com/rancher/os
[4]:https://rancher.com/docs/rancher/v1.6/en/rancher-services/storage-service/rancher-nfs/