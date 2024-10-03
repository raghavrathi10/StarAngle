legendstr = [];
for checksatpairidx=1:length(phasediffres)
    plot(phasediffres{checksatpairidx}.vsidx,unwrap(phasediffres{checksatpairidx}.vsavg)*180/pi,'Marker', plotmarkers{checksatpairidx}, 'LineWidth', 3, 'Color', plotcolors{checksatpairidx});
    hold on;
    if isfile(thisfilename_tle)
        plottry = RES_usaz.opdiff(phasediffres{checksatpairidx}.vsidx,checksatpairidx);
        plotadd = [-2:2]*2*pi; plotscore = zeros(1,length(plotadd));
        for h=1:length(plotscore)
            tempp = plottry + plotadd(h);
            tempp1 = tempp' - unwrap(phasediffres{checksatpairidx}.vsavg);
            plotscore(h) = sum(tempp1.*tempp1);
        end
        [a,b] = min(plotscore);
        plot((RES_usaz.opdiff(:,checksatpairidx) + plotadd(b))*180/pi, 'LineStyle', '--', 'LineWidth', 1, 'Color',plotcolors{checksatpairidx});
        tempp = sprintf('(%s, %s)', SAT{phasediffres{checksatpairidx}.satid(1)}.nameid, SAT{phasediffres{checksatpairidx}.satid(2)}.nameid);
        legendstr{length(legendstr)+1} = tempp;
        legendstr{length(legendstr)+1} = sprintf('%s cal', tempp);
    else
        legendstr{length(legendstr)+1} = sprintf('Sat (%d, %d)', alltocheckclutsers(checksatpairidx,1),alltocheckclutsers(checksatpairidx,2));
    end
end
hold off
legend(legendstr, 'Location', 'northeastoutside')
xlabel('Time (sec)')
ylabel('Phase (degree)')
title('Phase Difference Measurement')
set(gca,'FontSize',18);
grid on
xlim([1 checkmergesegnum])