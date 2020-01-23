FROM mthenw/frontail:latest

COPY https://github.com/Llibyddap/openHAB-Rancher/blob/master/openhab.css  /frontail/web/assets/styles/openhab.css
COPY https://github.com/Llibyddap/openHAB-Rancher/blob/master/preset.json /frontail/preset/openhab.json