p1 = plot(RES_usaz.LNB_az_degree_vals,RES_usaz.sumscores, 'LineWidth', 2, 'Color', plotcolors{1});
if size(RES_usaz.scores,2) > 1
    hold on
    p2 = plot(RES_usaz.LNB_az_degree_vals,RES_usaz.scores(:,1), 'LineWidth', 2, 'Color', plotcolors{2}, 'LineStyle', '--');
    legend('Actual Cost', 'With One Sat. Pair', 'Location', 'best')
end
xlabel('User Orientation (degree)')
ylabel('Cost')
titlestr = sprintf('Cost Function (min at %d deg)', RES_usaz.estval);
title(titlestr)
set(gca,'FontSize',18);
grid on
xlim([min(RES_usaz.LNB_az_degree_vals) max(RES_usaz.LNB_az_degree_vals)])