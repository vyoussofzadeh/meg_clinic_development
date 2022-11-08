function categories = get_categories(selectedFiles, resultType)

offset = 1;
for i=1:length(selectedStudies)
    [sStudy, iStudy] = bst_get('Study', selectedStudies(i));
    
    if ~isempty(sStudy.Result)
        ResultFiles = sStudy.Result;
        % Filter results
        pat='results_decomp';
        index=strfind({ResultFiles.FileName}, pat);
        dataIndices = find(~cellfun(@isempty, index));
        if ~isempty(dataIndices)
            % Find categories
            ind = strfind({ResultFiles(dataIndices).Comment}, '(');
            for k=1:length(dataIndices)       
                comments(offset) = {ResultFiles(dataIndices(k)).Comment(1:ind{k}-2)};
                offset = offset+1;
            end
        end
    end
end

categories = unique(comments);
x=strcmp(categories, 'Low-high freq constrast');
iCateg = find(~x);
categories = categories(iCateg);