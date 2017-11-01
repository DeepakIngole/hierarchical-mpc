function custom_plot(varArray,varargin)
% Customized plot
% Syntax: custom_plot(varArray,figName,figureTitle,yMode,xRange,yRange,xLabel,yLabel,animationFlag,holdFlag,tpause)

    % Options
    numvarargs=length(varargin);
    if numvarargs>10
        error('custom_plot:TooManyInputs','requires at most 8 optional inputs');
    end
    optargs = {'' '' 'lin' [-Inf Inf] [-Inf Inf] '' '' '' 2e-2};
    optargs(1:numvarargs) = varargin;
    [figName,figureTitle,yMode,xRange,yRange,xLabel,yLabel,animationFlag,holdFlag,tpause]=optargs{:};

    try 
        custom_visual(varArray,figName,figureTitle,yMode,xRange,yRange,xLabel,yLabel,holdFlag);
    catch
        gen_visual(figName);
        custom_visual(varArray,figName,figureTitle,yMode,xRange,yRange,xLabel,yLabel,holdFlag);
    end
    
    % Figure arrangement
    autoArrangeFigures();
    
    % Animation
    if animationFlag
        frame=getframe(gcf);
        [imind,cm]=rgb2ind(frame2im(frame),256);
        if ~exist([figName '.gif'],'file')
            imwrite(imind,cm,[figName '.gif'],'gif','Loopcount',Inf);
        else
            imwrite(imind,cm,[figName '.gif'],'gif','Writemode','append');
        end
    end

    % Pause
    pause(tpause);

end

% Local functions
function custom_visual(varArray,figName,figureTitle,yMode,xRange,yRange,xLabel,yLabel,holdFlag)
    % Visualization
    figure(findobj('type','figure','Name',figName));
    if ~holdFlag
        clf;
    end
    switch yMode
        case 'lin'
            plot(varArray,'.-');
        case 'log'
            semilogy(varArray,'.-');
    end
    xlim(xRange);
    ylim(yRange);
    xlabel(xLabel,'interpreter','latex');
    ylabel(yLabel,'interpreter','latex');
    set(gca,'TickLabelInterpreter','latex');
    title(figureTitle,'interpreter','latex');
    grid on;
    if holdFlag
        hold on;
    end
end
function gen_visual(figName)
    % Generate figure
    if isempty(findobj('type','figure','Name',figName))
        figure('Name',figName,'numbertitle','off');
        clf;set(gcf,'color','white');
    end
end