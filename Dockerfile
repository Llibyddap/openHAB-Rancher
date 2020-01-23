#  The use of a dockerfile to load files doesn't work in rancheros.  It will work within docker standalone
#  see:  https://github.com/rancher/rancher/issues/2118

FROM mthenw/frontail:latest

ADD https://github.com/Llibyddap/openHAB-Rancher/blob/master/openhab.css  /frontail/web/assets/styles/openhab.css
ADD https://github.com/Llibyddap/openHAB-Rancher/blob/master/preset.json /frontail/preset/openhab.json