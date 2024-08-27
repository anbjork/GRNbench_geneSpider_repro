% Runs predictions needed for GRNbenchmark prediction submission
% Can be run by ./run_methods.sh -> ./run_methods.py to run all methods
% with a timeout for methods that are slow.
% Can be run independently for a single method by setting the 
% method variable below.


%%%%%%% Setup %%%%%%%%%%%%%%%%%%%

% % To run this script independently, set method here.
% % If running all methods with timeout for slow ones, comment out
% % method assignment, and clear command here
% clear
% method = "lsco";

% Adjust as necessary
addpath(genpath('/home/anbjork/tools/genespider/genespider'));

%%%%%%% Setup end %%%%%%%%%%%%%%%%%%%



script_dir = pwd; % Will fail if script is run from other directory

% Settings
paths = struct(...
    'in', './data/BenchmarkingData/');
reps = 5; % repetitions, in GRN benchmark it is 5

% select between GeneSPIDER and GeneNetWeaver
data_sources = ["GeneNetWeaver", "GeneSPIDER"];
% select between LowNoise, MediumNoise, HighNoise
noiseLevels = ["LowNoise", "MediumNoise", "HighNoise"];
directions = ["forward", "backward"];

for direction = directions

    % If not running this independently, for method assignment, see
    % run_methods.py in this directory.
    % Matlabs interface for being called programatically is less than great.
    paths.out = './outputs/network_predictions/' + ...
        method + '/' + direction + '/networks/';
    mkdir(paths.out)

    try
        for data_source = data_sources
            for noiseLevel = noiseLevels
                for j = 1:reps
                    predictGrnsUsingGeneSpider(...
                        data_source, noiseLevel, j, ...
                        paths, method, direction)
                end
            end
        end
        cd(paths.out)
        zip("../networks.zip", "*_grn.csv")
        cd(script_dir)
    catch err
        fileID = fopen(paths.out + '/prediction_error.txt','a+');
        fprintf(fileID, '\n\n\n');
        fprintf(fileID, "data source: " + data_source);
        fprintf(fileID, '%s', err.getReport('extended', 'hyperlinks','off'));
        fclose(fileID);
    end
end


function predictGrnsUsingGeneSpider(...
    tool, noiseLevel, iiRepeat, paths, method, ...
    direction)

    % Internal name conversions. Unnecessary
    j = iiRepeat;
    nlev = noiseLevel;
    pathin = paths.in;
    pathout = paths.out;

    s = pathin+tool+"_"+nlev+"_Network"+j+"_GeneExpression.csv";
    Y = readtable(s, "ReadRowNames", true);
    gnsnms = string(cell2mat(Y.Row));
    s = pathin+tool+"_"+nlev+"_Network"+j+"_Perturbations.csv";
    P = readtable(s, "ReadRowNames", true);
    Y = table2array(Y);
    P = table2array(P);

    N = size(Y,1);
    A = zeros(N);
    Net = datastruct.Network(A, 'myNetwork');
    D(1).network = [];
    % define zero noise
    D(1).E = [zeros(N) zeros(N) zeros(N)];
    D(1).F = zeros(N);
    D(1).Y = Y; % here is where your data is assigned
    D(1).P = P;
    D(1).lambda = [std(Y(:))^2,0];
    D(1).cvY = D.lambda(1)*eye(N);
    D(1).cvP = zeros(N);
    D(1).sdY = std(Y(:))*ones(size(D.P));
    D(1).sdP = zeros(size(D.P));

    % create data object with data "D" and scale-free network "Net"
    Data = datastruct.Dataset(D, Net);

    % now we can run inference
    zeta = 0; % return full network as GRN benchmark do cutoff internally
    infMethod = method;
    [Aest, ~] = Methods.(infMethod)(Data,zeta);

    if direction == "forward"
    elseif direction == "backward"
        Aest = Aest';
    else
        error("direction must be either forward or backward")
    end

    inet = Aest; % network to save
    wedges = compose("%9.5f",round(inet(:),5)); % keep weights

    inet(inet<0) = -1; % convert to signed edges without weights
    inet(inet>0) = 1;

    edges = inet(:); % from left to right, columns are merged to one vector

    s = size(inet,1);
    nams_edges = [repmat(1:s, 1, s); repelem(1:s, s)]';

    edges_from = gnsnms(nams_edges(:,2));
    edges_to = gnsnms(nams_edges(:,1));
    nrid = string((1:length(edges_from))');
    edge_list = table(nrid, edges_from, edges_to, wedges, string(edges));

    allVars = 1:width(edge_list);
    % define names in the file
    newNames = ["ID","Regulator","Target","Weight","Sign"]; 
    edge_list = renamevars(edge_list,allVars,newNames);
    Var1 = "";
    Var2 = "Regulator";
    Var3 = "Target";
    Var4 = "Weight";
    Var5 = "Sign";
    newNamesTab = table(Var1,Var2,Var3,Var4,Var5);
    newNamesTab = renamevars(newNamesTab,allVars,newNames);

    edge_list(edges==0,:) = [];
    edge_list2 = [newNamesTab; edge_list];
    writetable(...
        edge_list2,pathout+tool+"_"+nlev+"_Network"+j+"_grn.csv", ...
        'QuoteStrings',true,"WriteVariableNames",false) % save as csv
    
end


