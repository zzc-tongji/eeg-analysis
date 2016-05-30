function [result_1, result_2, result_3] = zzc_rank_sort_column(source_data, max_or_min, abs_or_not)
%RANK and SORT EACH COLUMN by MAX or MIN in ABS or NOT
%
%   [result_1, result_2, result_3]
%       = zzc_rank_sort_column(source_data, max_or_min, abs_or_not)
%
%   ----------
%
%   Parameter 'source_data' is the source data. It must be a two-dimensional matrix.
%
%   Parameter 'max_or_min' and 'abs_or_not' indicate principle of ranking and sorting.
%       Parameter 'max_or_min' must be ''max'' or ''min''.
%       Parameter 'abs_or_not' must be ''abs'' or ''not''.
%
%   ----------
%
%   Return value 'result_1' has the same size as parameter 'source_data'.
%       Its row and column indicates the location of data in parameter 'source_data'.
%       Its value indicates the rank of data in parameter 'source_data'.
%
%   Return value 'result_2' has the same size as parameter 'source_data'.
%       Its value and column indicates the location of data in parameter 'source_data'.
%       Its row indicates the rank of data in parameter 'source_data'.
%
%   Return value 'result_3' has the same size as parameter 'source_data'.
%       It is sort result of data in parameter 'source_data'.
%       Its row indicates the rank of data in parameter 'source_data'.
%
%   ----------
%
%   Transpose the data at first if you want to rank each row.

% check parameter
if length(size(source_data)) ~= 2
    error('Parameter 1 must be a two-dimensional matrix.');
end
if ~ischar(max_or_min) || (~ strcmp(max_or_min, 'max') && ~ strcmp(max_or_min, 'min'))
    error('Parameter 2 must be ''max'' or ''min''.');
end
if ~ischar(abs_or_not) || (~ strcmp(abs_or_not, 'abs') && ~ strcmp(abs_or_not, 'not'))
    error('Parameter 3 must be ''abs'' or ''not''.');
end

% get size
row = size(source_data, 1);
column = size(source_data, 2);
result_1 = zeros(row, column);
result_2 = zeros(row, column);
result_3 = zeros(row, column);

% caculate abs or not
if strcmp(abs_or_not, 'abs')
    data_mid = abs(source_data);
else
    data_mid = source_data;
end

% rank by max or min
if strcmp(max_or_min, 'max')
    for index_column = 1 : 1 : column
        for index = 1 : 1 : row
            [~, location] = max(data_mid(:, index_column));
            result_1(location, index_column) = index;
            result_3(index, index_column) = source_data(location, index_column);
            data_mid(location, index_column) = - inf;
        end
    end
else
    for index_column = 1 : 1 : column
        for index = 1 : 1 : row
            [~, location] = min(data_mid(:, index_column));
            result_1(location, index_column) = index;
            result_3(index, index_column) = source_data(location, index_column);
            data_mid(location, index_column) = inf;
        end
    end
end

% sort
for index_column = 1 : 1 : column
    for index = 1 : 1 : row
        [result_2(index, index_column), ~, ~] = find(result_1(:, index_column) == index);
    end
end

end
