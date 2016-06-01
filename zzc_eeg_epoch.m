%   This script is used to epoch raw eeg data
%
%   Running Environment :  MATLAB R2012a, EEGLAB v12.0.1.0b

% 1. input
path = [getenv('USERPROFILE'), '\Desktop\EEG\20160428-zzc-music'];
vhdr_name = '20160428-zzc-music.vhdr';
name = 'zzc';
trigger = {'-adios', '-A4_piano-fe', '-FE', '-A4-se', '-SE', '-A4-sh', '-A4_piano-sh', '-A4_violin', '-FC1', '-FC2'; ...
    513.5, 21.5, 21.5, 21.5, 21.5, 21.5, 21.5, 21.5, 21.5, 21.5};

% 2. epoch & save
eeg = pop_loadbv(path, vhdr_name);
eeg.setname = name;
eeg = eeg_checkset(eeg);
for index = 1 : 1 : size(trigger, 2)
    set_name = strcat(name, trigger(1, index));
    set_name = set_name{1};
    eeg_epoch = pop_epoch(eeg, { eeg.event(index + 1).type }, [0, cell2mat(trigger(2, index))], ...
        'newname', set_name, 'epochinfo', 'yes');
    eeg_epoch = pop_rmbase(eeg_epoch, [0, cell2mat(trigger(2, index)) * 1000]);
    eeg_epoch = eeg_checkset(eeg_epoch);
    [~] = pop_saveset(eeg_epoch, 'filename', eeg_epoch.setname, 'filepath', path);
end
clear index set_name eeg_epoch

% 3. clear
clear path vhdr_name name trigger eeg
