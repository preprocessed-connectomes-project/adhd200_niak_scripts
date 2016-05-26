clear

path_data = '/home/pbellec/database/adhd200/';
path_fig = [path_data 'figures/fig_parcels/'];
file_template = '/home/pbellec/database/template.mnc.gz';
psom_mkdir(path_fig);
list_parcels = {'AAL','CC200','CC400','EZ','HO','TT','rois_1000','rois_3000'};
list_slices = [38,53,68,83,98,113,128];
psom_set_rand_sed(0);
el = strel('square',3);

for aa = 1:length(list_parcels)
    
    if ~ismember(list_parcels{aa},{'rois_1000','rois_3000'})
        % Read the parcellation
        path_read = [path_data 'athena/ADHD200_' list_parcels{aa} '_TCs_filtfix/templates/'];
        file_read = dir([path_read '*.nii.gz']);
        file_read = [path_read file_read(1).name];
    else 
        % Read the parcellation
        file_read = [path_data 'niak/rois/' list_parcels{aa} '_kki/rois/brain_rois.nii.gz'];
    end
    [hdr,vol] = niak_read_vol(file_read);
    
    % Remap it from 0 to N
    [tmp,tmp2,vol_r] = unique(vol(:));
    vol_r = reshape(vol_r,size(vol))-1;
    
    % Random order on parcels
    order = randperm(max(vol_r(:)));
    vol_r(vol_r>0) = order(vol_r(vol_r>0));
    
    % Save the parcellation and open mricron
    hdr.file_name = [path_fig list_parcels{aa} '.nii'];
    niak_write_vol(hdr,vol_r);

    % Convert parcellation in minc
    file_mnc = [path_fig list_parcels{aa} '.mnc'];
    system(['nii2mnc ' hdr.file_name ' ' file_mnc]);
    psom_clean(hdr.file_name);
    
    % Now resample in T1 template space
    in.source = file_mnc;
    in.target = file_template;
    out = [path_fig list_parcels{aa} '_r.mnc'];
    opt.interpolation = 'nearest_neighbour';
    niak_brick_resample_vol(in,out,opt);
    
    % Read the resampled version and add outlines
    [hdr_r,vol_r] = niak_read_vol(out);
    N = max(vol_r(:));
    
    for zz = 1:size(vol_r,3);
        slice = vol_r(:,:,zz);
        list_roi = unique(slice(:));
        list_roi = list_roi(list_roi~=0);
        for rr = 1:length(list_roi)
            mask = slice==list_roi(rr);
            mask_e = imerode(mask,el,'same');
            slice(mask&~mask_e) = N+1;
        end
        vol_r(:,:,zz) = slice;
    end
    hdr_r.file_name = [path_fig list_parcels{aa} '.nii.gz'];
    hdr_r.type = 'nii';
    hdr_r = rmfield(hdr_r,'details');
    niak_write_vol(hdr_r,vol_r);
end

% slices : 38,53,68,83,98,113,128
% z coordinates: -35 -20 -5 10 25 40 55
% mricron /home/pbellec/database/template_skull_white.nii.gz -o AAL.nii.gz -l 0.9 -h 116 -c Rainramp
% mricron /home/pbellec/database/template_skull_white.nii.gz -o EZ.nii.gz -l 0.9 -h 116 -c Rainramp
% mricron /home/pbellec/database/template_skull_white.nii.gz -o HO.nii.gz -l 0.9 -h 111 -c Rainramp
% mricron /home/pbellec/database/template_skull_white.nii.gz -o TT.nii.gz -l 0.9 -h 97 -c Rainramp
% mricron /home/pbellec/database/template_skull_white.nii.gz -o CC200.nii.gz -l 0.9 -h 190 -c Rainramp
% mricron /home/pbellec/database/template_skull_white.nii.gz -o CC400.nii.gz -l 0.9 -h 351 -c Rainramp
% mricron /home/pbellec/database/template_skull_white.nii.gz -o rois_1000.nii.gz -l 2 -h 954 -c Rainramp
% mricron /home/pbellec/database/template_skull_white.nii.gz -o rois_3000.nii.gz -l 6 -h 2843 -c Rainramp