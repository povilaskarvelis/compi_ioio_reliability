cfunction [manovatbl1,manovatbl2,manovatbl3,manova_table] = COMPI_manova(states_all,condition,group)


IA_variable = table(states_all(:,1),states_all(:,2),states_all(:,3),...
    condition,group);
IA_variable.group = nominal(IA_variable.group);
IA_variable.condition = nominal(IA_variable.condition);

sortbyframe = sortrows(IA_variable,4);
sortbygroupFrameA = sortrows(sortbyframe([1:77],:),5);
FrameAHigh = sortbygroupFrameA([1:37],[1:3]);
FrameALow = sortbygroupFrameA([38:end],[1:3]);

sortbygroupFrameB = sortrows(sortbyframe([78:end],:),5);
FrameBHigh = sortbygroupFrameB([1:37],[1:3]);
FrameBLow = sortbygroupFrameB([38:end],[1:3]);

x1 = cell2mat(table2cell(FrameALow(:,1)));
x2 = cell2mat(table2cell(FrameALow(:,2)));
x3 = cell2mat(table2cell(FrameALow(:,3)));
y1 = cell2mat(table2cell(FrameBLow(:,1)));
y2 = cell2mat(table2cell(FrameBLow(:,2)));
y3 = cell2mat(table2cell(FrameBLow(:,3)));
z1 = cell2mat(table2cell(FrameAHigh(:,1)));
z2= cell2mat(table2cell(FrameAHigh(:,2)));
z3 = cell2mat(table2cell(FrameAHigh(:,3)));
t1 = cell2mat(table2cell(FrameBHigh(:,1)));
t2 = cell2mat(table2cell(FrameBHigh(:,2)));
t3 = cell2mat(table2cell(FrameBHigh(:,3)));

% Compare stable phases only
% StablePhases_variable = table(states_all(:,1),states_all(:,3),...
%     condition,group);
% StablePhases_variable.group = nominal(StablePhases_variable.group);
% StablePhases_variable.condition = nominal(StablePhases_variable.condition);
% Meas = table([1:2]','VariableNames',{'Phases'});
% 
% rm = fitrm(StablePhases_variable,'Var1-Var2~condition*group','WithinDesign',Meas);
% [manova_table,A,C,D] = manova(rm);
% 
% DependentVariable = [mean([x1;  x3; y1;  y3],2); mean([z1;  z3; t1;  t3],2)];
% Groups    = [ones(length([x1;  x3; y1;  y3]), 1); 2*ones(length([z1; z3; t1;  t3]), 1)];
% figure; vs = violinplot(DependentVariable, Groups);


% Test 3-way interaction using a within-subject design - phase
DependentVariable = [x1; x2; x3; y1; y2; y3; z1; z2; z3; t1; t2; t3];
groupingVariabile    = [ones(length([x1; x2; x3; y1; y2; y3]), 1); 2*ones(length([z1; z2; z3; t1; t2; t3]), 1)];
condition    = [ones(length([x1; x2; x3]), 1); 2*ones(length([y1; y2; y3]), 1);ones(length([z1; z2; z3]), 1);...
    2*ones(length([t1; t2; t3]), 1)];
phase    = [ones(length([x1]), 1); 2*ones(length([x2]), 1); 3*ones(length([x3]), 1);...
    ones(length([y1]), 1); 2*ones(length([y2]), 1); 3*ones(length([y3]), 1);...
    ones(length([z1]), 1); 2*ones(length([z2]), 1); 3*ones(length([z3]), 1);...
    ones(length([t1]), 1); 2*ones(length([t2]), 1); 3*ones(length([t3]), 1)];
variable = table(DependentVariable,...
    condition,groupingVariabile,phase);
variable.groupingVariabile = nominal(variable.groupingVariabile);
variable.condition = nominal(variable.condition);
variable.phase = nominal(variable.phase);
varnames          = {'Group';'Frame';'Phase'};
p = anovan(DependentVariable,{variable.groupingVariabile variable.condition variable.phase},...
    3,3,varnames);

figure; vs = violinplot(DependentVariable, groupingVariabile);

Groups    = [ones(length(x1), 1); 2*ones(length(x2), 1); 3*ones(length(x3), 1);4*ones(length(y1), 1);...
    5*ones(length(y2), 1); 6*ones(length(y3), 1); 7*ones(length(z1), 1); 8*ones(length(z2), 1); 9*ones(length(z3), 1);...
    10*ones(length(t1), 1); 11*ones(length(t2), 1); 12*ones(length(t3), 1)];
figure; vs = violinplot(DependentVariable, Groups);

Meas = table([1:3]','VariableNames',{'Phases'});

rm = fitrm(IA_variable,'Var1-Var3~condition*group','WithinDesign',Meas);
[manovatbl1,A,C,D] = manova(rm);

% Examine within-subject variables only
[manovatbl2,A,C,D] = manova(rm,'By','group');
[manovatbl3,A,C,D] = manova(rm,'By','condition');


end

