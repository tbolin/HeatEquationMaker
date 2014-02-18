function [ F, functions ] = input_boundaries(X, Y)
% input_boundaries funktion för att skriva in gränserna för
%   IN
%   x, y   kordinatmatriser
%   UT 
%   F   Logisk matris med vilkor för att en punkt ska annses
%       tillhöra området som ska beräknas 
%   functions   cell-array med str-representationer av funktionerna som matats in.
    F = []; % Matrisen där makerna ska sparas                                                     
    functions = {'x>x(1)', 'y>y(1)', 'x<x(end)', 'y<y(end)'}; % Ser till att kanterna alltid är ränder,
                                                              % det blir indexeringsfel senare annars
	prompt = 'Områdes-funktion: ';
    for i=1:length(functions)   % Lägger först in standardgränserna
        f = str2func(['@(x,y)', functions{i}]);
        F = cat(3, F ,f(X,Y) );
    end
    in = input(prompt, 's'); % Här börjar användarinmatningen
    while in
        try 
            functions = [functions, in];
            f = str2func(['@(x,y)', in]);
            F = cat(3, F, f(X,Y));
        catch err
           disp('det där var ingen funktion!')
           formatSpec = [err.identifier, '\n'];
           fprintf(2, formatSpec)
        end
        in = input(prompt, 's');
    end
	F = all(F, 3)
	functions = functions(4:end)
end

