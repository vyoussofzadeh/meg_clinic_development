    %test_auto_xfit
    unix('/neuro/bin/vue/xfit -remote & < XFITPIPE < /home/ebock/inputs.txt &');
    unix('echo "pass homunculus122" > XFITPIPE');
    unix('echo "display megneto:6" > XFITPIPE');
    settingsCommand = 'echo "loadsettings /MEG_data/test/sample_set2/110101/sss/run01_spont/xfit/run01_event1001_nosubsets(GLBL_only).cfit" > XFITPIPE';
    unix(settingsCommand);