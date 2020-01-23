FROM mthenw/frontail:latest

ADD https://github.com/Llibyddap/openHAB-Rancher/blob/master/openhab.css  /frontail/web/assets/styles/openhab.css
ADD https://github.com/Llibyddap/openHAB-Rancher/blob/master/preset.json /frontail/preset/openhab.json