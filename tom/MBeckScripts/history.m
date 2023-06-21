% create converter
edit convert2mrc.m
tom_mrc2em
edit convert2mrc.m
tom_mrcread('high_001.mrc')
ans.Header
convert2mrc
tom_emread('high_1.em');tom_dspcub(ans.Value)
tom_mrcread('high_001.mrc');tom_dspcub(ans.Value)
tom_emread('high_1.em');par1=ans.Value;
tom_dev(par1)
help tom_mrcread
tom_mrcread('high_001.mrc',short);tom_dspcub(ans.Value)
tom_mrcread('high_001.mrc','short');tom_dspcub(ans.Value)
tom_mrcread('high_001.mrc','int');tom_dspcub(ans.Value)
tom_mrcread('high_001.mrc','le');tom_dspcub(ans.Value)
tom_mrcread('high_001.mrc','be');tom_dspcub(ans.Value)
tom_mrcreadclassic('high_001.mrc');tom_dspcub(ans.Value)
tom_mrcreadclassic('high_001.mrc','le');tom_dspcub(ans.Value)
tom_mrcreadclassic('high_001.mrc','be');tom_dspcub(ans.Value)
convert2mrc
tom_mrcread('high_001.mrc');tom_dspcub(ans.Value)
tom_mrcread('highf_001.mrc');tom_dspcub(ans.Value)
tom_mrcread('highf_001.mrc');tom_dspcub(ans.Value,1)
tom_mrcread('highf_001.mrc');tom_dspcub(ans.Value,2)
convert2mrc
help tom_dev
convert2mrc
ls
tom_mrcread('unMaskedalphabeta01_output_Ref4.mrc');tom_dspcub(ans.Value)
tom_mrcread('unMaskedalphabeta01_output_Ref4.mrc');tom_emwrite('ref_1.em',ans.Value)
% create wedge list, edit in workspace window
wedge=zeros(3,1)
tom_emwrite('wedge.em',wedge)
wedge
% convert reference
ref = tom_emread('ref_1.em');
tom_dspcub(tom_bandpass(ref.Value,5,20))
tom_dev(ref.Value)
tom_mrcread('ref.mrc');tom_dspcub(ans.Value)
tom_mrcread('ref.mrc');tom_dev(ans.Value)
ref=tom_mrcread('ref.mrc');tom_dev(ref.Value)
ref=tom_mrcread('ref.mrc');[mean max min std]=tom_dev(ref.Value)
ref=(ref.Value-mean)./std;
tom_dev(ref)
tom_emwrite('ref_1.em',ref)
tom_dspcub(tom_bandpass(ref,3,20))
whos ref
tom_dspcub(tom_bandpass(ref,3,30))
ls ../Lepto/Motor/ref*
tom_emread('./Lepto/Motor/ref_1.em');tom_dspcub(ans.Value)
tom_emread('../Lepto/Motor/ref_1.em');tom_dspcub(ans.Value)
tom_emread('../Lepto/Motor/ref_1.em');tom_dspcub(ans.Value,1)
vol=zeros(128,128,128);
vol(13:116,13:116,13:116)=ref;tom_dspcub(voö)
vol(13:116,13:116,13:116)=ref;tom_dspcub(vol)
ref=vol;
% check mask and bandpass visually
tom_dspcub(tom_spheremask(ref,49,3))
tom_dspcub(tom_bandpass(tom_spheremask(ref,49,3),3,20))
tom_dspcub(tom_bandpass(tom_spheremask(ref,49,3),3,20),2)
tom_dspcub(tom_bandpass(tom_spheremask(ref,49,3),3,10),2)
tom_dspcub(tom_bandpass(tom_spheremask(ref,49,3),3,10),0)
tom_dspcub(tom_bandpass(tom_spheremask(ref,49,3),3,10),1)
tom_dspcub(tom_bandpass(tom_spheremask(ref,49,3),3,20),1)
tom_dspcub(tom_bandpass(tom_spheremask(ref,49,3),3,15),1)
tom_dspcub(tom_bandpass(tom_spheremask(ref,49,3),3,12),1)
tom_dspcub(tom_bandpass(tom_spheremask(ref,25,3),3,12),1)
tom_dspcub(tom_bandpass(tom_spheremask(ref,35,3),3,12),1)
tom_emwrite('ref_1.em',ref)
% create spherical mask
mask=tom_spheremask(ones(128,128,128),35,3);tom_dspcub(mask)
tom_emwrite('mask.em',mask)
% create motl, type 'help tom_picker' to get help on format
motl=zeros(20,40);
% tomo No
motl(5,:)=1
% particle No
motl(4,:)=1:40
% CCC for thresholding
motl(1,:)=1
% class
motl(20,:)=1
tom_emwrite('motl_1.em',motl)
help av3_scan_fast_martin
% launch global scan with inc 30deg, 12 steps
av3_scan_fast_martin ('ref', 'motl', 'high', 1, 1,30,12,mask,3,12,1,0,wedge,1, 2);
