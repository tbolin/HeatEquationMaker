function [ frames ] = solve_time(F, B, Q, T0, r_scale, t_scale, drop, k, dens, cap)
% Funktion för att ställa upp och beräkna tidsberoende temperaturer
%   IN 
%   G   3D-imensionell logisk matris med vilkor för att en punkt ska annses
%       tillhöra området som ska beräknas
%   B   Matris som innehåller de kända värdena utanför beräkningsområdet.
%   Q   Matris med tillförd värme per ytenhet
%   områdets diskretisering
%   UT
%   S   Matris med de uträknade inre värden och de kända yttre
    B = B.*(~F);  % Tar bort inre punkter från randmatrisen
    Q = Q.*(F);
    k_ind=find(F);      % Index i G sedd som vektor för alla nollskillda element i G.
                        % Härefter reffererat till som k-index
    N=length(k_ind);    % Antalet nollskillda element i G
    F=zeros(size(F)); % Gör om G till en riktigt matris
    F(k_ind)=(1:N)'; % Sätter in k-index på varje 0-skillt elements plats i G 
                 % (kolla på G för att förstå hur det ser ut)
    i=(1:N)';    % Index i G för de element som ska sättas in i koefficientmatrisen A
    A=sparse(i,i,-4);    % Skapar koefficientmatrisen A och sätter in mitt-vikterna (-4) på diagonalen.
    b = zeros(N,1); % Skapar högerledet där randvärdena ska sättas in
    % Sätter in grannarna
    n = length(B);
    for neighbour=[-n -1 +1 +n] % Grannen tv, över, under och th
        [row, foo, col] = find(F(k_ind+neighbour)); % Tar alla grannar som inte är randvärden
        % Varje punkt påverkas av de 4 grannarna
        % om en granne inte är randvärden ska det stå en 1:a på punktens rad
        % i grannens kolonn. 
        % row blir därför k-index för de punkter som har inre punkter som
        % grannar åt det aktuella hållet.
        % foo är kolonn-index i G(k), men eftersin G(k) är en vektor blir det
        % bara 1:or, finns bara för att matlab inte har en fku som ger
        % vektor-index och värde.
        % col är värdena som punkterna i G har, dvs grannens k-index
        b = b + B(k_ind+neighbour);
        A = A + sparse(row, col, 1, N, N);
    end
    %%% Här börjar tidsberoende 
    
    dx = r_scale(2)-r_scale(1);
    dt = t_scale(2)-t_scale(1);
    %nt = ceil((stop-start)/dt);
    
    % Initialvärden
    T = T0(k_ind);

    % Systemmatris
    A = ((k/(2*cap*dens))*(dt/dx^2))*A; 
    I = sparse(eye(size(A)));
    [Lower, Uper] = lu(I-A);
    
    % Randvilkor
    b = b*(dt*k/(dens*cap*dx^2)); 
    if Q
        b = b + Q(k_ind)*(dt/(dens*cap)); % Tillförd värme
    end
    
    % Allokera minne för att spara temperaturdata
    frames = zeros(length(r_scale), length(r_scale), floor(length(t_scale)/drop)+2);
    count = 1;
    S = B;
    S(k_ind) = T;
    frames(:,:,1) = S;
    
    % lösare
    for t=t_scale
        % beräkningar
        Ty = Lower\(T+(A*T)+b);
        T = Uper\(Ty);
        if mod(count,drop)==0
            S(k_ind) = T;
            frames(:,:,floor(count/drop)+1) = S;
        end
        count = count + 1;
    end
    S(k_ind) = T;
    frames(:,:,end) = S;
end


















