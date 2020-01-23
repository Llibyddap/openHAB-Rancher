WORK IN PROGRESS

This stack is designed to deploy on RancherOS v1.6 (tested).  

Done:

openhab 2.5
nodered
influxdb
grafana
frontail
dfs storage

Todo:
load balancing (java performance)
frontail header to stabalize
documentation
develope secrets for environment variabls/passwords


short docs:

pre-requisites - must have rancher-nfs isntalled and mounted to nfs for volumn mapping.

launch stack...

chmod grafana on nfs store.  This is an issue with how mouts the directory - the nfs picks up the mount as rancher:rancher.  Within the nfs you'll have to:

chown -R 472:472 StackName_grafanadata_xxxxx

once the ownership and group are changed the permission errors on the Grafana container will clear.

Next you'll have to install the presets json and css files for frontail.

navigate to the StackName_frontailweb_xxxxx and 

wget https://raw.githubusercontent.com/Llibyddap/openHAB-Rancher/master/openhab.css

then navigate to teh StackName_frontailpresets_xxxxx and

wget https://raw.githubusercontent.com/Llibyddap/openHAB-Rancher/master/openhab.json

Once both frontail dependency files are isntalled you'll be able to upgrade the frontail contain.  Change the command line to:

--disable-usage-stats --ui-highlight --ui-highlight-preset /frontail/preset/openhab.json -t openhab -l 2000 -n 200 /logs/logs/openhab.log /logs/logs/events.log

