clear all, close all, clc

n = 99; 		% Upplösningen på området
v = -1:1/n:1;	% Områdets omfattning
[X, Y] = meshgrid(v); % Skapar nxn X- och Y-matriser (så mycket snyggare än den gamla)


% Ett par exempel på olika sätt att använda programmet

% Med användarinmatade funktioner
% F = input_boundaries(X, Y); % "Lista" med kurvor
% B = input_rand(X, Y)

% Med hårdkodade funktioner
% F = (X>X(1))&(Y>Y(1))&(X<X(end))&(Y<Y(end))&(X.^2+Y.^2<0.3);
% B = (5*X*(X>0.25))+((-2*(X<0.25)))+(5*(Y>0.25))+((-4*(Y<0.25))); % Funktionen för randpunkter

% Med funktioner från strängar
area = {'x.^2+y.^2<0.3'};
temp = {'5*x*(x>0.25)', '-2*(x<0.25)', '5*(y>0.25)', '-4*(y<0.25)'};
F = str2bond(area, X, Y);
B = str2rand(temp, X, Y);

% Lös systemet
solution = solve_temp(F, B);

% Plotta
hold on
contourf(solution, 50, 'LineStyle', 'none')
contour(all(F,3), [1 1], 'LineWidth',2, 'LineColor', 'k')
contour(solution, 5, 'LineColor', 'k', 'ShowText', 'on')
