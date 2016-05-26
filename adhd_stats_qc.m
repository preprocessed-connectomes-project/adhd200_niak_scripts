clear
tab = niak_read_csv_cell ('qc_report_common_final.csv');
tab = strrep(tab,'Missing','Fail');

%% Extract labels for each rater PB and YB
list_subject = tab(2:end,1);
labpb = tab(2:end,[4,7]);
labyb = tab(2:end,[10 13]);

%% Mask only entries documented by both raters
maskpb = ~strcmp(labpb,'');
maskyb = ~strcmp(labyb,'');
mask = maskpb(:,1)&maskpb(:,2)&maskyb(:,1)&maskyb(:,2);

% agreement for fail cases
failp = [strcmp(labpb(mask,1),'Fail') ; strcmp(labpb(mask,2),'Fail')];
faily = [strcmp(labyb(mask,1),'Fail') ; strcmp(labyb(mask,2),'Fail')];
kappaindex(failp(:)'+1,faily(:)'+1,2)
% 0.81649

%% Failure rate
fail_athena = ismember(labpb(:,1),'Fail')|ismember(labyb(:,1),'Fail');
fail_niak = ismember(labpb(:,2),'Fail')|ismember(labyb(:,2),'Fail');
mean(fail_athena )
mean(fail_niak)
% 0.070466
% 0.051813

%% Final status 
status_niak = repmat({'Pass'},size(list_subject));
status_niak(fail_niak) = {'Fail'};
status_athena = repmat({'Pass'},size(list_subject));
status_athena(fail_athena) = {'Fail'};
for ss = 1:length(list_subject)
    list_subject{ss} = list_subject{ss}(2:end);
end
tab_final = [{'subject','status_athena','status_niak'};[list_subject status_athena status_niak]];
niak_write_csv_cell('qc_ADHD200_preprocessed.tsv',tab_final);

%% Archives

mean(failp(1:220)==1)
mean(faily(1:220)==1)
mean(failp(221:440)==1)
mean(faily(221:440)==1)


% agreement for OK vs Maybe, excluding fail cases
mask_fail = failp | faily;
okp = [strcmp(labpb(mask,1),'OK') ; strcmp(labpb(mask,2),'OK')];
oky = [strcmp(labyb(mask,1),'OK') ; strcmp(labyb(mask,2),'OK')];
kappaindex(okp(~mask_fail)'+1,oky(~mask_fail)'+1,2)
% 0.62606
mean(okp(1:220)==1)
mean(oky(1:220)==1)
mean(okp(221:440)==1)
mean(oky(221:440)==1)


% Overall agreement
ratep = double(failp);
ratep(ratep==1) = 3;
ratep(mask_fail==0) = double(okp==0)+1;
ratey = double(faily);
ratey(ratey==1) = 3;
ratey(mask_fail==0) = double(oky==0)+1;
mask0 = (ratep==0)|(ratey==0);
kappaindex(ratep(~mask0)',ratey(~mask0)',3)
% 0.67116
