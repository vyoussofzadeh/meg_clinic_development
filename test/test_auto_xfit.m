%settingsCommand = ['echo "loadsettings ' sXfit.commandFile '" > XFITPIPE'];
settingsCommand = ['echo "loadsettings /home/ebock/temp.cfit " > XFITPIPE']
unix('/neuro/bin/vue/xfit -remote & < XFITPIPE &')
unix('echo -e "pass homunculus122\n" > XFITPIPE &')
unix('echo -e "display megneto:6\n" > XFITPIPE &')
unix('echo -e "loadsettings temp.cfit\n" > XFITPIPE')