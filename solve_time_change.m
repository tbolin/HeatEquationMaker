function [ time ] = solve_time_change(F, B, Q, T0, r_scale, t_scale, drop, k, dens, cap)
% Funktion för att ställa upp och beräkna tidsberoende temperaturer
%   IN 
%   G   3D-imensionell logisk matris med vilkor för att en punkt ska annses
%       tillhöra området som ska beräknas
%   B   Matris som innehåller de kända värdena utanför beräkningsområdet.
%   Q   Matris med tillförd värme per ytenhet
%   områdets diskretisering
%   UT
%   time   Tiden d� temp �r inom 99% av steady state.
    steady = solve_temp_Q(F, B, Q, r_scale, k); % Ber�kna stedy state
    B = B.*(~F);  % Tar bort inre punkter från randmatrisen
    k_ind=find(F);      % Index i F sedd som vektor för alla nollskillda element i F.
                        % Härefter reffererat till som k-index
    steady = steady(k_ind); % G�r om steady till T-vektor 
    N=length(k_ind);    % Antalet nollskillda element i F
    F=zeros(size(F)); % Gör om F till en riktigt matris
    F(k_ind)=(1:N)'; % Sätter in k-index på varje 0-skillt elements plats i F 
                 % (kolla på F för att förstå hur det ser ut)
    i=(1:N)';    % Index i F för de element som ska sättas in i koefficientmatrisen A
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
        % foo är kolonn-index i F(k), men efter sin F(k) är en vektor blir det
        % bara 1:or, finns bara för att matlab inte har en fku som ger
        % vektor-index och värde.
        % col är värdena som punkterna i F har, dvs grannens k-index
        b = b + B(k_ind+neighbour);
        A = A + sparse(row, col, 1, N, N);
    end
    %%% Här börjar tidsberoende
    
    dx = r_scale(2)-r_scale(1);
    dt = t_scale(2)-t_scale(1);
    
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
    
    T_prev = zeros(1,length(T));
    % lös
    time = 0;
    prec = 0.01;
    n_steady = norm(steady);
    while norm(T-steady)/n_steady > prec
        % beräkningar
        T_prev = T;
        Ty = Lower\(T+(A*T)+b);
        T = Uper\(Ty);
        time = time+dt;
    end
    % Interpolation
    time = time -dt + (prec*n_steady-norm(T_prev-steady))/(norm(T-steady)-norm(T_prev-steady))*dt;
end



















