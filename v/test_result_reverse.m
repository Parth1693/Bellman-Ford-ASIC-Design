%we use to test
input_data = 'Input_secret1.dat';                                    %Input.dat file name
standard_answer = 'Output_secret1.dat';                     %file name of standard answer
your_answer = 'Output.dat';                                      %file name of your own result
load('edge_matrix_secret1.mat');                                                                   %edge matrix we use to test

output_standard = textread(standard_answer, '%s', 'delimiter', '\n');
%solution of your own
solution_own = textread(your_answer, '%s', 'delimiter', '\n');
%input file
inputFile = textread(input_data, '%s', 'delimiter', '\n');
count = 0;
numOfResults = 1;
lengthPath_standard_temp = {};
numOfSolutionResults = 1;
path_standard = {};       %standard path
path_own = {};               %your own path
input_standard = {};     %standard source and destination
input_own = {};             %your source and destination
ct = 0;
lengthPath_own_temp = {};

%% find your own length of each paths
for i = 1 : length(solution_own)

    %if not the end of each path
    if ~isempty(str2num(solution_own{i}))
        % store path length
        ct = ct + 1;
        %save length of each path in your own solution
        if ct == 1
            lengthPath_own_temp{numOfSolutionResults} = str2num(solution_own{i});
            %remove 0 at the end of the file and save each path in your own
            %solution
         else if str2num(solution_own{i}) ~= 0
                    path_own{numOfSolutionResults, ct - 1} =  str2num(solution_own{i});
                 end
        end 
        
    %if it's the end ('FFFF')
    else
        numOfSolutionResults = numOfSolutionResults + 1;
        ct = 0;
    end
end

%lengthPath_own: your own length of each paths
lengthPath_own =  cell2mat(lengthPath_own_temp);
lengthPath_own = transpose(reshape(lengthPath_own, [1, length(lengthPath_own)]));


%% find the standard answer of length paths
for i = 1 : length(output_standard)
    
    %if not the end
    if ~isempty(str2num(output_standard{i}))
        % store path length
        count = count + 1;
        if count == 1
            lengthPath_standard_temp{numOfResults} = str2num(output_standard{i});
        %remove final 0 in Output file
        else if str2num(output_standard{i}) ~= 0
                    path_standard{numOfResults, count - 1} =  str2num(output_standard{i});
                end
        end
    %if it's the end
    else
        numOfResults = numOfResults + 1;
        count = 0;
    end
end
%lengthPath_standard:  length of each paths in standard solution
lengthPath_standard =  cell2mat(lengthPath_standard_temp);
lengthPath_standard = transpose(reshape(lengthPath_standard, [1, length(lengthPath_standard)]));

%% find the standard inputin Input.dat
ct = 1;
numOfInput = 1;
for i = 1 : length(inputFile)
    if ~isempty(str2num(inputFile{i}))
        %remember the source
        if ct == 1
            input_standard{numOfInput, 1} =  str2num(inputFile{i});
            ct = ct + 1;
        %remember the destination
        else if ct == 2
            input_standard{numOfInput, 2} = str2num(inputFile{i});
            ct = ct + 1;
            end
        end
    else
        numOfInput = numOfInput + 1;
        ct = 1;
    end
end

%% find source and destination of your own file
[size_path_own, length_path_own] = size(path_own);
for i = 1 : size_path_own
    %save source of each path
    input_own{i, 2} = path_own{i, 1};%%%
    %save destination of each path
    for j = 1 : (length_path_own - 1)
        %if the row is not full
        if isempty(path_own{i,size(path_own, 2)})
            if isempty(path_own{i,j + 1})
                input_own{i, 1} = path_own{i, j};%%%
                break;
            end
        %if the row is full
        else
            input_own{i, 1} = path_own{i,size(path_own, 2)}; %%%
            break;
        end
    end
    
end

%% Judge whether your source and destination match the original one
check = 0;
input_own_print = cell2mat(input_own);
input_standard_print = cell2mat(input_standard);
for i = 1: length(input_standard)
    if input_own{i, 1} == input_standard{i, 1} && input_own{i, 2} == input_standard{i, 2}   %%%
        continue;
    else
        check = 1;
        
        fprintf('The source or destination of path ');
        fprintf(int2str(i));
        fprintf( ' is not right.\n');
        fprintf(int2str(input_own_print(i,2)));   
        fprintf(' -> '); 
        fprintf(int2str(input_own_print(i,1)));   
        fprintf(' should be ');
        fprintf(int2str(input_standard_print(i, 1)));
        fprintf(' -> ');  
        fprintf(int2str(input_standard_print(i, 2)));
        fprintf('\n');
    end
end

%% judge whether every path of your own matches edge_matrix or not
%test = fopen('result_judge.txt','w');
for i = 1: size_path_own
    path_test = 0;
    for j = (length_path_own - 1): -1 : 1
            %judge whether this row has how many values
            if ~isempty(path_own{i,j + 1})
                path_test = path_test + edge_matrix(path_own{i,j+1}, path_own{i,j});
            else continue;
            end
    end
    
    %judge whether your own input match edge_matrix or not
    if path_test ~= lengthPath_standard(i)
        check = 1;
        fprintf('The length of path ');
        fprintf(int2str(i));
        fprintf(' does not match edge_matrix.\n');
        fprintf(int2str(path_test));
        fprintf(' should be ');
        fprintf(int2str(lengthPath_standard(i)));
        fprintf('\n');
    end
end

%% Judge whether your length match the shortest length of each paths
for i = 1 : length(lengthPath_own)
    if lengthPath_own(i) == lengthPath_standard(i)
        continue;
    else
        check = 1;
        fprintf('The shortest length of path ');
        fprintf(int2str(i));
        fprintf(' is not right.\n');
        fprintf(int2str(lengthPath_own(i)));
        fprintf(' should be ');
        fprintf(int2str(lengthPath_standard(i)));
        fprintf('\n');
    end
end


%fclose(test);
if check == 0
    fprintf('Correct!\n');
else
    fprintf('Error! Please see above.\n');
end
