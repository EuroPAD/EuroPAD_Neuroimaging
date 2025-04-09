function mat_to_csv(inputFile)
    % Load .mat file
    data = load(inputFile);

    % Access the struct
    structName = fieldnames(data);
    structData = data.(structName{1});
    fields = fieldnames(structData);

    % save input filename
    [~, baseName, ~] = fileparts(inputFile);

    % Loop through the fields
    for i = 1:numel(fields)
       fieldName = fields{i};
       fieldData = structData.(fieldName);

       % Check if field data
      if isnumeric(fieldData) || islogical(fieldData)
          csvFileName = strcat(baseName, '_', fieldName, '.csv');
          writematrix(fieldData, csvFileName);
          fprintf('Saved %s\n', csvFileName);
      else
          warning('Oops something went wrong');
      end
    end
end