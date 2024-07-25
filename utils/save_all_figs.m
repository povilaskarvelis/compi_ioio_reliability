function save_all_figs(destination)

FolderName = destination;   % Your destination folder
mkdir(FolderName);
addpath(FolderName)

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    
    FigHandle = FigList(iFig);
    FigName   = get(FigHandle, 'Name');
    if isempty(FigName)
        FigName = string(get(FigHandle, 'Number'));
    end
    
    savefig(FigHandle, sprintf('%s/%s.fig',FolderName, FigName));
    saveas(FigHandle, sprintf('%s/%s.png',FolderName, FigName) );
end