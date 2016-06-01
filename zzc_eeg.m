%   This script is used to analyze the correlation coefficient
%       between EEG and music features.
%
%   Before running it, use 'eeglab' to callout the window of EEGLAB and then close it,
%       otherwise an error will occur in preprocessing. And also, don't forget to
%       load data of music features.
%
%   Running Environment: MATLAB R2012a, EEGLAB v12.0.1.0b, FastICA 2.5

% 1. input
% EEG structure
eeg = pop_loadset('filename', 'zzc-A4-se.set', 'filepath', [getenv('USERPROFILE'), '\Desktop\EEG\20160428-zzc-music\']);
% EEG name (displayed in topograph)
eeg_name = eeg.setname;
% new sampling rate
sample_rate = 250;
% filter (Hz)
filter = [4, 50];
% use ICA
enable_ica = 1;
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
% output path of topograph (create new folder)
output_path = [getenv('USERPROFILE'), '\Desktop\Result\20160428-zzc-music\'];
% upper limit value of p
corr_p_max = 0.01;
% enable draw
enable_draw = 1;
% information
information = '';

% 2. preprocess: resample & filter
eeg = eeg_checkset(eeg);
eeg = pop_resample(eeg, sample_rate);
eeg = eeg_checkset(eeg);
eeg = pop_eegfiltnew(eeg, filter);
eeg = eeg_checkset(eeg);

clear filter;

% 3. independent component analysis (ICA)
if enable_ica == 1
    [ica_sig, ica_A, ~] = fastica(eeg.data(1 : 60, :));
else
    ica_A = eye(60);
    ica_sig = eeg.data(1 : 60, :);
end
ica_number = size(ica_sig, 1);

% 4. get amplitude of selected band
time = size(ica_sig, 2) / sample_rate;
frame_number = floor((time - (frame_length - non_overlap_length)) / non_overlap_length);
spectrum_mean = zeros(ica_number, frame_number);
for index_1 = 1 : 1 : frame_number
    time_begin = (index_1 - 1) * non_overlap_length;
    time_end = time_begin + frame_length;
    eeg_fragment = zzc_eeg_cut(eeg.data, [time_begin, time_end], sample_rate);
    for index_2 = 1 : 1 : ica_number
        [amplitude, ~] = zzc_eeg_spectrum(eeg_fragment, sample_rate, frame_length, index_2, band);
        spectrum_mean(index_2, index_1) = mean(amplitude);
    end
end

clear eeg sample_rate frame_length non_overlap_length band ica_sig time ...
    frame_number time_begin time_end eeg_fragment amplitude;

% 5. caculate correlation coefficient
spectrum_mean_frame_number = size(spectrum_mean, 2);
music_frame_number = size(music, 1);
if spectrum_mean_frame_number ~= music_frame_number
    caculate_number = min(spectrum_mean_frame_number, music_frame_number);
    warning('zzc_eeg:incongruous_frame_number', 'Spectrum mean frame number is %d. Music frame number is %d. They are unequal.', ...
        spectrum_mean_frame_number, music_frame_number);
    fprintf('Caculate correlation coefficient of the first %d frames of EEG / ICA and music.\n', caculate_number);
    if input('Input ''1'' to continue, otherwise to abort.\n') ~= 1
        disp('Abort.');
        return;
    end
    spectrum_mean = spectrum_mean(:, 1 : caculate_number);
    music = music(1 : caculate_number, :);
end
music_feature_number = size(music, 2);
corr_p = zeros(ica_number, music_feature_number);
for index_1 = 1 : 1 : ica_number
    for index_2 = 1 : 1 : music_feature_number
        [~, p] = corrcoef(spectrum_mean(index_1, :), music(:, index_2));
        corr_p(index_1, index_2) = p(1, 2);
    end
end

clear music spectrum_mean_frame_number music_frame_number caculate_number p;

% 6. rank correlation coefficient
[~, rank_in_music_feature_no.ica_no, rank_in_music_feature_no.corr_p] = zzc_rank_sort_column(corr_p, 'min', 'not');
[~, rank_in_ica_no.music_feature_no, rank_in_ica_no.corr_p] = zzc_rank_sort_column(corr_p', 'min', 'not');

% 7. select by p
[r, c, ~] = find(rank_in_music_feature_no.corr_p < corr_p_max);
s = size(r, 1);
result = cell(s + 1, 4);
result{1, 1} = 'feature_no';
result{1, 2} = 'feature_name';
if enable_ica == 1
    result{1, 3} = 'ica_no';
else
    result{1, 3} = 'channel_no';
end
result{1, 4} = 'corr_p';
for index_1 = 1 : 1 : s
    result{index_1 + 1, 1} = c(index_1);
    result{index_1 + 1, 2} = title{1, c(index_1)};
    result{index_1 + 1, 3} = r(index_1);
    result{index_1 + 1, 4} = rank_in_music_feature_no.corr_p(r(index_1), c(index_1));
end
result_tip = cell(2, 2);
if enable_ica == 1
    result_tip{1, 1} = 'ica_number';
else
    result_tip{1, 1} = 'channel_no';
end
result_tip{1, 2} = ica_number;
result_tip{2, 1} = 'corr_p_max';
result_tip{2, 2} = corr_p_max;

clear result_index r c s;

% 8. draw topograph & save
if (enable_draw)
    m_file_path = mfilename('fullpath');
    ced_file_path = [m_file_path(1 : strfind(m_file_path, mfilename()) - 1), '60_channels_map.ced'];
    object_folder = [output_path, '[', eeg_name, '][', music_name, ']', information, '\'];
    mkdir(object_folder);
    for index_1 = 1 : 1 : ica_number
        % graph
        topoplot(ica_A(:, index_1), ced_file_path, 'electrodes','labels');
        % setting
        set(gcf, 'Position', [0, 0, 1300, 900]);
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
        % text: data
        for index_2 = 1 : 1 : music_feature_number
            table_rank = index_2;
            table_corr_p = rank_in_ica_no.corr_p(index_2, index_1);
            table_music_feature_no = rank_in_ica_no.music_feature_no(index_2, index_1);
            table_music_feature = title{1, table_music_feature_no};
            text_line = sprintf('%02d %+1.4f\n   %s %02d', ...
                table_rank, table_corr_p, table_music_feature, table_music_feature_no);
            text_index_end = text_index_begin + size(text_line, 2) + 1;
            text_all(text_index_begin : text_index_end) = [text_line, sprintf('\n'), sprintf('\n')];
            text_index_begin = text_index_end + 1;
        end
        % text: cast
        text_all = char(text_all);
        % text: write
        textbox = uicontrol('style', 'text');
        set(textbox, 'Position', [10, 10, 300, 830]);
        set(textbox, 'HorizontalAlignment', 'left');
        set(textbox, 'FontName', 'FixedWidth');
        set(textbox, 'FontSize', 14);
        set(textbox, 'String', text_all);
        % save
        saveas(gcf, [object_folder, sprintf('ica_%03d.png', index_1)], 'png');
        clf;
    end
    close;
end
save([object_folder, 'result.mat'], 'spectrum_mean', 'corr_p', ...
    'rank_in_music_feature_no', 'rank_in_ica_no', 'result', 'result_tip');

clear eeg_name enable_ica music_name output_path ica_A ica_number ...
    index_1 index_2 music_feature_number enable_draw corr_p_max m_file_path ced_file_path ...
    object_folder information text_all text_index_begin text_line text_index_end text_all ...
    table_rank table_corr_p table_music_feature_no table_music_feature textbox;

disp('Finish.');
