clear all, close all, clc

% område
format long
n = 100; 		% Upplösningen på området
from = -1;
to = 1;
r_scale = linspace(from, to, n); % Områdets omfattning
r_scale2 = linspace(from, to, floor(n/2)); % Halva upplösningen
[X, Y] = meshgrid(r_scale); % Skapar nxn X- och Y-matriser (så mycket snyggare än den gamla)
[X2, Y2] = meshgrid(r_scale2);
area = {'x.^2+y.^2<0.3'};
temp = {'5*x*(x>0.25)', '-2*(x<0.25)', '5*(y>0.25)', '-4*(y<0.25)'};
F = str2bond(area, X, Y);
B = str2rand(temp, X, Y);
F2 = str2bond(area, X2, Y2);
B2 = str2rand(temp, X2, Y2);

Q = @(x, y)200*exp(-(x-y).^2)+2000*exp(-1000*(x).^2); % Värmetillskott
q = bsxfun(Q, r_scale, r_scale'); 
q2 = bsxfun(Q, r_scale2, r_scale2');
% tidssteg
dt = 0.01;
drop = 1;

% fysik
k = 0.4;
dens = 1; % densitet
cap = 2.5; % Värmekapacitet

% Lös steady-state för att hitta utgångsläget
solution = solve_temp_Q(F, B, q, r_scale, k);
solution2 = solve_temp_Q(F2, B2, q2, r_scale2, k);
% lös
timed = solve_time_change(F, B, 0, solution, r_scale, dt, drop, k, dens, cap);
timed2 = solve_time_change(F2, B2, 0, solution2, r_scale2, dt, drop, k, dens, cap);

% beräknar lösningar från t=0 till ~jämvikt
t_scale = 0:dt:timed+dt;
t_scale2 = 0:dt:timed2+dt;
conv = solve_time(F, B, 0, solution, r_scale, t_scale, drop, k, dens, cap);
conv2 = solve_time(F2, B2, 0, solution2, r_scale2, t_scale2, drop, k, dens, cap);

% Sätt plottstorlek
figure('units','normalized', 'position',[0.1 0.2 0.7 0.5])
% Plotobjekt
conv_plot = subplot(1,2,1);
conv_plot2 = subplot(1,2,2);
text_ax = axes('position',[0,0,1,1],'visible','off');
% Plotinställningar
timer = text(0.5, 0.3, num2str(0));
set(timer,'FontSize',22,'fontweight','bold');
view(text_ax, 2);
view(conv_plot, 3);
view(conv_plot2, 3);

% Plotta
for i=1:max([size(conv, 3), size(conv2, 3)])
    if i <= size(conv, 3)
        S = conv(:,:,i);
        cla(conv_plot)
        surf(conv_plot, r_scale, r_scale, S, 'LineStyle', 'none')
        axis(conv_plot, [-1 1 -1 1 -6 30])
    end
    if i <= size(conv2, 3) 
        S2 = conv2(:,:,i);
        cla(conv_plot2)
        surf(conv_plot2, r_scale2, r_scale2, S2, 'LineStyle', 'none')
        axis(conv_plot2, [-1 1 -1 1 -6 30])
    end
    set(timer,'String', num2str(i*dt,'%3.2f'));
    pause(3*dt*drop)
end
%% Beräkna ordningen
s1 = solve_time_change(F, B, 0, solution, r_scale, 2*dt, drop, k, dens, cap);
s2 = solve_time_change(F, B, 0, solution, r_scale, 4*dt, drop, k, dens, cap);
order = abs((s2-s1)/(s1-timed))

%% Från-Till
clear all, close all, clc

% område
n = 49; 		% Upplösningen på området
r_scale = -1:1/n:1;	% Områdets omfattning
[X, Y] = meshgrid(r_scale); % Skapar nxn X- och Y-matriser (så mycket snyggare än den gamla)

area = {'x.^2+y.^2<0.3'};
temp = {'5*x*(x>0.25)', '-2*(x<0.25)', '5*(y>0.25)', '-4*(y<0.25)'};
F = str2bond(area, X, Y);
B = str2rand(temp, X, Y);

Q = @(x, y)200*exp(-(x-y).^2)+2000*exp(-1000*(x).^2);
q = bsxfun(Q, r_scale, r_scale');
% tidssteg
start = 0;
stop = 1;
dt = 0.01;
t_scale = start:dt:stop;
drop = 1;
% fysik
k = 0.8;
dens = 1; % densitet
cap = 2.5; % Värmekapacitet

% Sätt plottstorlek
figure('units','normalized', 'position',[0.1 0.2 0.85 0.5])

% Lös steady-state för att hitta utgångslöget
T0 = solve_temp_Q(F, B, q, r_scale, k);
start_plot = subplot(1,3,1);
surf(r_scale, r_scale, T0, 'LineStyle', 'none')
axis([-1 1 -1 1 -6 30])
% lös och plotta steady-state
steady = subplot(1,3,3);
solution = solve_temp(F, B);
surf(r_scale, r_scale, solution, 'LineStyle', 'none')
axis([-1 1 -1 1 -6 30])
% lös
time_plot = subplot(1,3,2);
timed = solve_time(F, B, 0, T0, r_scale, t_scale, drop, k, dens, cap);
S = timed(:,:,1);
surf(time_plot,r_scale, r_scale, S, 'LineStyle', 'none')
axis([-1 1 -1 1 -6 30])
%% Plotta
for i=1:size(timed, 3)
	cla(time_plot)
    view(3);
    S = timed(:,:,i);
    surf(time_plot, r_scale, r_scale, S, 'LineStyle', 'none')
    axis([-1 1 -1 1 -6 30])
    pause(10*dt*drop)
end
%% vad som händer med konstiga starttemperaturer
figure('units','normalized', 'position',[0.1 0.2 0.3 0.5])
T0 = ones(size(q))*20;
k = 0.8;
wonky = solve_time(F, B, 0, T0, r_scale, t_scale, drop, k, dens, cap);
for i=1:size(wonky, 3)
	cla
    view(3);
    S = wonky(:,:,i);
    surf(r_scale, r_scale, S, 'LineStyle', 'none')
    axis([-1 1 -1 1 -6 30])
    pause(10*dt*drop)
end



