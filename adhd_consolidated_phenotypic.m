clear

list_file = { 'KKI_phenotypic.tsv' , ...
              'NeuroIMAGE_phenotypic.tsv' , ...
              'NYU_phenotypic.tsv' , ...
              'OHSU_phenotypic.tsv' , ...
              'Peking_1_phenotypic.tsv' , ...
              'Peking_2_phenotypic.tsv' , ...
              'Peking_3_phenotypic.tsv' , ...
              'Pittsburgh_phenotypic.tsv' , ...
              'WashU_phenotypic.tsv' , ...
              'allSubs_testSet_phenotypic_dx.tsv' ...
            };

for ff = 1:length(list_file)
  file = list_file{ff};
  tab = niak_read_csv_cell(file);
  if ff~=length(list_file)
      tab = tab(:,1:17);
  el
      tab = tab(:,[2:12 14:18 13]); % The test set has different header, one extra "disclaimer" column at the beginning. Also, the "Med Status" is in a different spot, because why not. 
  end
  if ff == 1
      header = tab(1,:);
      tab_all = tab;
  else
      if any(~strcmp(header,tab(1,:)));
          error('headers do not match for file %s',file);
      end
      tab_all = [tab_all ; tab(2:end,:)];
  end
end

%% Add in the visual QC
tab_qc = niak_read_csv_cell('qc_ADHD200_preprocessed.csv');
list_subject = tab_all(2:end,1);
tab_final = [tab_all repmat({'N/A'},[size(tab_all,1),2])];
tab_final{1,18} = 'QC_Athena';
tab_final{1,19} = 'QC_NIAK';

for ss = 1:length(list_subject)
    subject = list_subject{ss};
    if length(subject)==7
        subject = subject(2:end);
    elseif length(subject)==5
        subject = ['0' subject];
    end
    ind = find(strcmp (tab_qc(:,1),subject));
    if isempty(ind)
        warning('No QC for subject %s',subject)
        continue
    end
    if length(ind)>1
        error('Alert! subject IDs have been compromised by removing first digit')
    end
    tab_final(ss+1,18) = {num2str(strcmp(tab_qc(ind,2),'Pass'))};
    tab_final(ss+1,19) = {num2str(strcmp(tab_qc(ind,3),'Pass'))}; 
end

%% Write consolidated phenotypics
file_final = 'adhd200_preprocessed_phenotypics.tsv';
niak_write_csv_cell(file_final,tab_final);