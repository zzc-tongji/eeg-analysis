%   This script is used to analyze the correlation coefficient
%       between EEG and music features.
%
%   Before running it, load data of EEG and music features at first.
%
%   Running Environment: MATLAB R2012a, EEGLAB v12.0.1.0b, FastICA 2.5

% 1. input
% EEG structure
eeg = EEG;
% EEG name (displayed in topograph)
eeg_name = eeg.setname;
% new sampling rate
sample = 250;
% filter (Hz)
filter = [4, 50];
% frame length (s)
frame_length = 4;
% non-overlap of a frame (s)
non_overlap_length = 1;
% selected band
band = [8, 13];
% music name (displayed in topograph)
music_name = 'A4';
% music feature matrix
music = eval(music_name);
% use ICA
enable_ica = 1;
% output path of topograph (create new folder)
output_path = [getenv('USERPROFILE'), '\Desktop\'];

% 2. preprocess: resample & filter
eeg = pop_resample(eeg, sample);
eeg = pop_eegfiltnew(eeg, filter);

% 3. get amplitude of selected band
time = eeg.xmax;
frame_number = floor((time - (frame_length - non_overlap_length)) / non_overlap_length);
spectrum_mean = zeros(60, frame_number);
for index_1 = 1 : 1 : frame_number
    time_begin = (index_1 - 1) * non_overlap_length;
    time_end = time_begin + frame_length;
    eeg_fragment = zzc_eeg_cut(eeg.data, [time_begin, time_end], eeg.srate);
    for index_2 = 1 : 1 : 60
        [amplitude, ~] = zzc_eeg_spectrum(eeg_fragment, eeg.srate, frame_length, index_2, band);
        spectrum_mean(index_2, index_1) = mean(amplitude);
    end
end
clear time frame_number time_begin time_end eeg_fragment amplitude

% 4. independent component analysis (ICA)
if enable_ica == 1
    [ica_sig, ica_A, ~] = fastica(spectrum_mean);
else
    ica_A = eye(60);
    ica_sig = spectrum_mean;
end

% 5. caculate correlation coefficient
ica_frame_number = size(ica_sig, 2);
music_frame_number = size(music, 1);
if ica_frame_number ~= music_frame_number
    caculate_number = min(ica_frame_number, music_frame_number);
    warning('zzc_eeg:incongruous_frame_number', 'EEG / ICA frame number is %d. Music frame number is %d. They are unequal.', ...
        ica_frame_number, music_frame_number);
    fprintf('Caculate correlation coefficient of the first %d frames of EEG / ICA and music.\n', caculate_number);
    if input('Input ''1'' to continue, otherwise to abort.\n') ~= 1
        disp('Abort.');
        return;
    end
    ica_sig = ica_sig(:, 1 : caculate_number);
    music = music(1 : caculate_number, :);
end
ica_number = size(ica_sig, 1);
music_feature_number = size(music, 2);
corr = zeros(ica_number, music_feature_number);
corr_p = zeros(ica_number, music_feature_number);
for index_1 = 1 : 1 : ica_number
    for index_2 = 1 : 1 : music_feature_number
        [r, p] = corrcoef(ica_sig(index_1, :), music(:, index_2));
        corr(index_1, index_2) = r(1, 2);
        corr_p(index_1, index_2) = p(1, 2);
    end
end
clear r p
clear ica_frame_number music_frame_number caculate_number

% 6. rank correlation coefficient
[~, ~, rank_corr_in_feat] = zzc_rank_sort_column(corr, 'max', 'abs');
[~, rank_ica_in_feat, rank_corr_p_in_feat] = zzc_rank_sort_column(corr_p, 'min', 'not');
[~, ~, rank_corr_in_ica] = zzc_rank_sort_column(corr', 'max', 'abs');
[~, rank_feat_in_ica, rank_corr_p_in_ica] = zzc_rank_sort_column(corr_p', 'min', 'not');

% 7. draw topograph & save
m_file_path = mfilename('fullpath');
ced_file_path = [m_file_path(1 : strfind(m_file_path, mfilename()) - 1), '60_channels_map.ced'];
if enable_ica == 1
    object_folder = [output_path, '[', eeg_name, '][', music_name, '][ICA]\'];
else
    object_folder = [output_path, '[', eeg_name, '][', music_name, ']\'];
end
mkdir(object_folder);
for index_1 = 1 : 1 : ica_number
    % graph
    topoplot(ica_A(:, index_1), ced_file_path, 'electrodes','labels');
    % setting
    set(gcf, 'Position', [0, 0, 1200, 900]);
    set(gcf, 'PaperPositionMode', 'auto');
    % text: initial & allocate space
    text_all = zeros(1, 1024);
    text_index_begin = 1;
    if enable_ica == 1
        % text: EEG
        text_line = ['EEG:   ', eeg_name];
        text_index_end = text_index_begin + size(text_line, 2);
        text_all(text_index_begin : text_index_end) = [text_line, sprintf('\n')];
        text_index_begin = text_index_end + 1;
        % text: music
        text_line = ['music: ', music_name];
        text_index_end = text_index_begin + size(text_line, 2);
        text_all(text_index_begin : text_index_end) = [text_line, sprintf('\n')];
        text_index_begin = text_index_end + 1;
        % text: ICA
        text_line = sprintf('ICA:   %02d / %02d', index_1, ica_number);
        text_index_end = text_index_begin + size(text_line, 2) + 1;
        text_all(text_index_begin : text_index_end) = [text_line, sprintf('\n'), sprintf('\n')];
        text_index_begin = text_index_end + 1;
    else
        % text: EEG
        text_line = ['EEG:     ', eeg_name];
        text_index_end = text_index_begin + size(text_line, 2);
        text_all(text_index_begin : text_index_end) = [text_line, sprintf('\n')];
        text_index_begin = text_index_end + 1;
        % text: music
        text_line = ['music:   ', music_name];
        text_index_end = text_index_begin + size(text_line, 2);
        text_all(text_index_begin : text_index_end) = [text_line, sprintf('\n')];
        text_index_begin = text_index_end + 1;
        % text: channel
        text_line = sprintf('channel: %02d / %02d', index_1, ica_number);
        text_index_end = text_index_begin + size(text_line, 2) + 1;
        text_all(text_index_begin : text_index_end) = [text_line, sprintf('\n'), sprintf('\n')];
        text_index_begin = text_index_end + 1;
    end
    % text: title
    text_line = '    p   corr_coef';
    text_index_end = text_index_begin + size(text_line, 2) + 1;
    text_all(text_index_begin : text_index_end) = [text_line, sprintf('\n'), sprintf('\n')];
    text_index_begin = text_index_end + 1;
    % text: data
    for index_2 = 1 : 1 : music_feature_number
        table_rank = index_2;
        table_corr_p = rank_corr_p_in_ica(index_2, index_1);
        table_corr = rank_corr_in_ica(index_2, index_1);
        table_feat_id = rank_feat_in_ica(index_2, index_1);
        table_feat = title{1, table_feat_id};
        text_line = sprintf('%02d %+1.4f %+1.4f %02d %s', ...
            table_rank, table_corr_p, table_corr, table_feat_id, table_feat);
        text_index_end = text_index_begin + size(text_line, 2) + 1;
        text_all(text_index_begin : text_index_end) = [text_line, sprintf('\n'), sprintf('\n')];
        text_index_begin = text_index_end + 1;
    end
    % text: cast
    text_all = char(text_all);
    % text: write
    textbox = uicontrol('style', 'text');
    set(textbox, 'Position', [10, 10, 250, 830]);
    set(textbox, 'HorizontalAlignment', 'left');
    set(textbox, 'FontName', 'FixedWidth');
    set(textbox, 'FontSize', 14);
    set(textbox, 'String', text_all);
    % save
    saveas(gcf, [object_folder, sprintf('ica_%03d.png', index_1)], 'png');
    clf;
end
close;
clear table_rank table_corr_p table_corr table_feat_id table_feat text_index_begin text_line text_index_end;
clear m_file_path ced_file_path object_folder text_all textbox

% 8. clear & finish
if enable_ica == 0
    clear ica_A ica_sig
end
clear eeg eeg_name sample filter frame_length non_overlap_length band ...
    music music_name output_path enable_ica
clear ica_number music_feature_number index_1 index_2
disp('Finish.');
