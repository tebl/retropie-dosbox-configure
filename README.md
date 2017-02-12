RetroPie DOSBox Configurator
============================

# Introduction
Collection of simple bash scripts that was thrown together in order to simplify dealing with MS DOS games run via DOSBox inside of RetroPie. Replaces the stock script used to start _MS DOS roms_, "+Start DOSBox.sh".

# Installation
Scripts are installed by placing files (and directories) within your roms-folder, overwriting the stock "+Start DOSBox.sh" scripts as well as add a few new ones.

```
cd /tmp
wget https://github.com/tebl/retropie-dosbox-configure/archive/master.zip
mv retropie-dosbox-configure-master/roms/pc/* /home/pi/RetroPie/roms/pc/
mv retropie-dosbox-configure-master/roms/pc.system /home/pi/RetroPie/roms/
mv retropie-dosbox-configure-master/roms/pc.games /home/pi/RetroPie/roms/
```


# Configuring EmulationStation
EmulationStation by default will not recognize the __.init__-files created by the configurator, so we'll need to customize it in order to recognize these files (and mainly ignore everything else). If you haven't already customized the es_systems.cfg you'll probably only find the default one in _/etc/emulationstation/es_systems.cfg_, this is usually customized by copying it to _/home/pi/.emulationstation/es_systems.cfg_.

```
cp -i /etc/emulationstation/es_systems.cfg /home/pi/.emulationstation/es_systems.cfg
```

Customize it by changing the system configuration section for the PC to the following:
```xml
<system>
    <name>pc</name>
    <fullname>PC</fullname>
    <path>/home/pi/RetroPie/roms/pc</path>
    <extension>.init</extension>
    <command>/opt/retropie/supplementary/runcommand/runcommand.sh 0 _SYS_ pc %ROM%</command>
    <platform>pc</platform>
    <theme>pc</theme>
  </system>
```

__N.B. 1__ As with most things EmulationStation, no changes will take effect until you restart it.
__N.B. 2__ Any emulators installed will only the change the default es_systems.cfg, but since we've overridden it those won't take effect with a customized file in place like we're doing here - to get the added features, either recopy the stock file and then change it or add the corresponding changes to the _/home/pi/.emulationstation/es_settings.cfg_.

# Adding games
Games are installed by unzipping them into the _pc.games_-folder so that each of them get their own folder, an already extracted copy of the game Doom II (TM) would have it's files placed within the folder _/home/pi/RetroPie/roms/pc.games/Doom2_.

In order to configure the game for use within RetroPie you'll need to set up how to start the game, this is done by running the "+Start DOSBox Configurator.sh" script either via SSH or by running it from emulationstation. Select the game as you want to configure from the list, then use __SelectExe__ to select the corresponding executable to start, this will create an init-file within _/home/pi/RetroPie/roms/pc_ so that we can run it from EmulationStation. Starting it via SSH would be done as follows (logged in as user _pi_):
```
cd ~/RetroPie/roms/pc
./+Start\ DOSBox\ Configurator.sh
```

Note that EmulationStation only seems to generate the "roms"-list once on startup, so any newly added games will not show up until after you restart it.
