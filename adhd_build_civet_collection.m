
path_data = ['/database/fcon_1000/adhd/converted/' site '/'];
path_dp = ['/database/cbrainDP/civet_' site '/'];
psom_mkdir(path_dp)
files = niak_grab_adhd200(path_data);
list_subject = fieldnames(files);
for num_s  = 1:length(list_subject)
	instr_cp = ['cp ' files.(list_subject{num_s}).anat ' ' path_dp site '_' list_subject{num_s} '_t1.mnc.gz'];
	system(instr_cp);
end
