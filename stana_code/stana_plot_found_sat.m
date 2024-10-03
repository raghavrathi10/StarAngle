legendstr = [];
for satidx=1:length(SAT)
    plot(SAT{satidx}.info(:,1),SAT{satidx}.info(:,3)/1000, 'LineWidth', 3, 'LineWidth', 3, 'Color', plotcolors{satidx});
    hold on;
    if isfile(thisfilename_tle)
        legendstr{length(legendstr)+1} = sprintf('%s', SAT{satidx}.name);
        plot(SAT{satidx}.cal_dechirp/1000, 'LineStyle', '--', 'Color', plotcolors{satidx});
        legendstr{length(legendstr)+1} = sprintf('%s cal', SAT{satidx}.name);
    else
        legendstr{length(legendstr)+1} = sprintf('SAT %d', satidx);
    end
end
hold off
legend(legendstr, 'Location', 'northeastoutside')
xlabel('Time (sec)')
ylabel('Doppler Rate (kHz/sec)')
titlestr = sprintf('Detected Satellites');
title(titlestr)
set(gca,'FontSize',18);
grid on
xlim([1 checkmergesegnum])
