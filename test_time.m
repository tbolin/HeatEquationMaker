%clear all, close all, clc

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
dt = 0.005;
t_scale = start:dt:stop;
drop = 1;
% fysik
k = 0.8;
dens = 1; % densitet
cap = 2.5; % Värmekapacitet

% S�tt plottstorlek
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
pause(3)
% Plotta
for i=1:size(timed, 3)
	cla(time_plot)
    view(3);
    S = timed(:,:,i);
    surf(time_plot, r_scale, r_scale, S, 'LineStyle', 'none')
    axis([-1 1 -1 1 -6 30])
    pause(10*dt*drop)
end









