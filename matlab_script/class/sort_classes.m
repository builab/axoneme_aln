function [sorted_class_indx, class_length] = sort_classes(class_indx)
% Function to sort classes according to number of member
% 	[sorted_class_indx, class_length] = sort_classes(class_indx)
% HB 2009/10/03

for i = 1:max(class_indx)
	clen(i) = length(find(class_indx==i));
end

[class_length, indx] = sort(clen, 'descend');

for i = 1:size(class_indx)
	sorted_class_indx(i) = find(indx==class_indx(i));
end

sorted_class_indx = sorted_class_indx';
