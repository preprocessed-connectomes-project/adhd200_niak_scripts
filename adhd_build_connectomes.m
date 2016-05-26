% Extract connectomes for visualization in gephi
clear

path_data = '/home/pbellec/database/adhd200/';
path_fig = [path_data 'figures/fig_connectomes/'];
psom_mkdir(path_fig);

list_parcels = {'AAL','CC200','CC400','EZ','HO','TT','rois_1000','rois_3000'};
%list_athena = {'filtfix','TestRelease'};
list_athena = {'filtfix'};
psom_set_rand_seed(0);
opt_csv.separator = char(9);
perc = 0.1; % density parameters
thresh = 0.3; % absolute threshold
for aa = 1:length(list_parcels)
    
    if ~ismember(list_parcels{aa},{'rois_1000','rois_3000'})
        ee = 0;
        for rr = 1:length(list_athena)
            % Read the parcellation
            path_read = [path_data 'athena/ADHD200_' list_parcels{aa} '_TCs_' list_athena{rr} '/KKI/'];
            tmp = niak_grab_files(path_read);
            for ff = 1:length(tmp);
                niak_progress(ff,length(tmp));
                [path_f,name_f,ext_f] = niak_fileparts(tmp(ff).name);
                if strcmp(ext_f,'.1D')
                    data = niak_read_csv_cell (tmp(ff).name,opt_csv);
                    data = data(2:end,3:end);
                    S = sprintf('%s ', data{:});
                    y = sscanf(S, '%f');
                    y = reshape(y,size(data));
                    if ee==0
                        R = niak_build_correlation(y);
                    else
                        R = R + niak_build_correlation(y);
                    end
                    ee = ee+1;
                end
            end
        end
        R = R/ee;        
    else 
        % Read the parcellation
        path_read = [path_data 'niak/rois/' list_parcels{aa} '_kki/rois/'];
        files = dir([path_read 'tseries_roi*']);
        files = {files.name};
        ee = 0;
        for ff = 1:length(files)
            niak_progress(ff,length(files));
            data = load([path_read files{ff}]);
            if ee==0
                R = niak_build_correlation(data.tseries);
            else
                R = R + niak_build_correlation(data.tseries);
            end
            ee = ee+1;
        end
        R = R/ee;
    end
    
%    % Density based thresholding of the connectome
%    val = niak_mat2vec(R);
%    [val,order] = sort(val,'descend');
%    A = zeros(size(val));
%    A(order(1:ceil(perc*length(val))))=1;
%    A = niak_vec2mat(A);
%    
    A = R>thresh;
    
    % Now extract edges
    ind = find(A(:));
    [x,y] = ind2sub(size(A),ind);
    mask = x<y;
    x = x(mask);
    y = y(mask);
    
    % Write the connectome in csv
    G = cell(length(x),2);
    for ee = 1:length(x)
        G{ee,1} = sprintf('N%i',x(ee));
        G{ee,2} = sprintf('N%i',y(ee));
    end
    file_write = [path_fig,list_parcels{aa},'.csv'];
    niak_write_csv_cell(file_write,G);
end

