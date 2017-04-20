function controlVariables= MinimiseColDifference(Labstd,Labsample,N)

Lstd = Labstd(:,1)';
astd = Labstd(:,2)';
bstd = Labstd(:,3)';
Cabstd = sqrt(astd.^2+bstd.^2);

% Control Variables: Lightness, Chroma, Hue
L = sdpvar(1);
a = sdpvar(1);
b = sdpvar(1);

for i=1:N
    
Lsample = Labsample(i,1)';
asample = Labsample(i,2)';
bsample = Labsample(i,3)';
Cabsample = sqrt(asample.^2+bsample.^2);
 
Cabarithmean = (Cabstd + Cabsample)/2;

G = 0.5* ( 1 - sqrt( (Cabarithmean.^7)./(Cabarithmean.^7 + 25^7)));

apstd = (1+G).*astd; % aprime in paper
apsample = (1+G).*asample; % aprime in paper

% Candidate values
L_candidate = Lsample + L;
a_candidate = apsample + a;
b_candidate = bsample + b;

% Contraints
constraints = [0 <= L_candidate <= 100,...
               abs(a_candidate) <= 100,...
               abs(b_candidate) <= 100,...
               iff(L_candidate >= 101, L_candidate == 100),...
               iff(L_candidate <= -1, L_candidate == 0),...
               iff(a_candidate >= 128, a_candidate == 127),...
               iff(a_candidate <= -127, a_candidate == -126),...
               iff(b_candidate >= 128, b_candidate ==  127),...
               iff(b_candidate <= -127, b_candidate == -126)];
obj = (Lstd-L_candidate)^2 + (apstd-a_candidate)^2 + (bstd-b_candidate)^2;
end

% Minimise the objective function
solution = solvesdp(constraints,(obj))
controlVariables = double([L,a,b])

