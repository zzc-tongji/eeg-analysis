# EEG Analysis #

### Introduction ###
This repo is created in May 2016. It is a part of my graduation project (correlation between music features and EEG).  

### Environment ###

* MATLAB R2012a  
* [EEGLAB v12.0.1.0b](http://sccn.ucsd.edu/eeglab/) (Click [here](https://bitbucket.org/zzc_actual/eeg-analysis/downloads/eeglab12_0_1_0b.zip) to download)  
* [FastICA 2.5](http://research.ics.aalto.fi/ica/fastica/) (Click [here](https://bitbucket.org/zzc_actual/eeg-analysis/downloads/FastICA_2.5.zip) to download)  

### Script ###

Script 'zzc_eeg.m' can be used to analyze the correlation coefficient between music features (use [this](https://bitbucket.org/zzc_actual/music-feature-analysis) to calculate them) and EEG.  

Script 'zzc_eeg_clear.m' can be used to clear the result of running 'zzc_eeg.m'.  

Other scripts are called by 'zzc_eeg.m'. Actually, I believe that script 'zzc_rank_sort_column.m' can be used as substitute of default function 'sort' in MATLAB.  

### Other ###

* All lines end up with CRLF (Windows).  
* File '60_channels_map.ced' is used to draw topography.  