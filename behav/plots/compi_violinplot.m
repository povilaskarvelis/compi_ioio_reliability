function [vs] = COMPI_violinplot(current_var,condition,group)
IA_variable = table(current_var,condition,group);
IA_variable.group = nominal(IA_variable.group);
IA_variable.condition = nominal(IA_variable.condition);

sortbyframe = sortrows(IA_variable,2);
sortbygroupFrameA = sortrows(sortbyframe([1:77],:),3);
FrameAHigh = sortbygroupFrameA([1:37],1);
FrameALow = sortbygroupFrameA([38:end],1);

sortbygroupFrameB = sortrows(sortbyframe([78:end],:),3);
FrameBHigh = sortbygroupFrameB([1:37],1);
FrameBLow = sortbygroupFrameB([38:end],1);

figure; 
subplot(2,2,1); violinplot(FrameALow);
subplot(2,2,2); violinplot(FrameBLow);
subplot(2,2,3); violinplot(FrameAHigh);
subplot(2,2,4); violinplot(FrameBHigh);

x = cell2mat(table2cell(FrameALow));
y = cell2mat(table2cell(FrameBLow));
z = cell2mat(table2cell(FrameAHigh));
t = cell2mat(table2cell(FrameBHigh));

Variables = [x; y; z; t];
Groups    = [ones(length(x), 1); 2*ones(length(y), 1); 3*ones(length(z), 1);4*ones(length(t), 1)];
p = anovan(current_var,{IA_variable.group IA_variable.condition},...
    'model','interaction','varnames',{'Group','Frame'});
figure; vs = violinplot(Variables, Groups);
end