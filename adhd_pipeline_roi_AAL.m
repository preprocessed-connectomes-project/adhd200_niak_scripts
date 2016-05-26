% This is a script to run a region growing procedure on the OHSU-test database.
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008-2010.
%               Centre de recherche de l'institut de Gériatrie de Montréal
%               Département d'informatique et de recherche opérationnelle
%               Université de Montréal, 2011.
% Maintainer : pierre.bellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : fMRI, resting-state, ADHD, region growing

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

clear
list_sites = {'ohsu','pittsburgh','kki','nyu','neuroimage','beijing','washu'};

for num_s = 1:length(list_sites)
    site = list_sites{num_s};
    fprintf('Site %s ... ',site);
    %% Setting input/output files 
    path_data = ['/media/database2/adhd_niak/' site '_output/'];
    opt_g.min_xcorr_func = -Inf;
    opt_g.max_translation = Inf;
    opt_g.max_rotation = Inf;
    files_in = niak_grab_fmri_preprocess(path_data,opt_g);

    %% Options
    files_in.atoms = '/media/database2/adhd_niak/rois_1000_kki/roi_aal_3mm.mnc.gz'; 
    path_results   = ['/media/database2/adhd_niak/rois_aal_training/rois_aal_' site '/'];
    opt.folder_out = path_results; % Where to store the results
    opt.flag_roi   = true; % Only generate the ROI parcelation

    %% Run the pipeline
    opt.flag_test = true;
    [pipeline_tmp,opt] = niak_pipeline_stability_rest(files_in,opt); 
    if num_s == 1
        pipeline = psom_merge_pipeline(struct(),pipeline_tmp,[site '_']);
    else
        pipeline = psom_merge_pipeline(pipeline,pipeline_tmp,[site '_']);
    end
    fprintf('%i jobs added to the pipeline\n',length(fieldnames(pipeline_tmp)));
end
