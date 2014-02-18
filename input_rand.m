function [ B, functions ] = input_rand(X, Y)
% input_rand funktion för att mata in de kända värdena
%   IN
%   X, Y    kordinatmatriser
%   UT 
%   B       Matris med kända temperaturväden
%   functions   cell-array med str-representationer av funktinerna som matats in
    
	B = []; % Matrisen där värdena ska sparas
    functions = {};
	prompt = 'Temp-funktion: ';
    in = input(prompt, 's'); % Här börjar användarinmatningen
    while in
        try 
            functions = [functions, in];
            f = str2func(['@(x,y)', in]);
            B = cat(3, B, f(X,Y));
        catch err
           disp('det där var ingen funktion!')
           formatSpec = [err.identifier, '\n'];
           fprintf(2, formatSpec)
        end
        in = input(prompt, 's');
    end
    B = sum(B, 3);
end

