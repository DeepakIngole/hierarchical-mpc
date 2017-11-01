function [xData,yData]=fig2dat(figName)

if ~isempty(findobj('type','figure','Name',figName))

    h=findobj('type','figure','Name',figName);
    axesObjs=get(h,'Children');
    dataObjs=get(axesObjs,'Children');
    objTypes=get(dataObjs,'Type');

    xData=get(dataObjs,'XData');
    yData=get(dataObjs,'YData');

else
    xData=[];
    yData=[];
end