function autoenc = train_selig(data_folder, chebyshev_nodes, output_length, multiplier, varargin)
    addpath(data_folder);
    afiles = dir(data_folder);
    afiles = afiles(3:end);

    ch_all = [];
    ch_xx = chebyshevs(chebyshev_nodes);

    for i = 1:length(afiles)
        try
            afile = importdata(afiles(i).name, ' ', 1);
            afiledata = afile.data;

            leadingedge = min(afiledata(:, 1));
            leadingedge_index = find(afiledata(:, 1) == leadingedge);
            ch_top = fliplr(interp1(fliplr(afiledata(1:leadingedge_index, 1)), fliplr(afiledata(1:leadingedge_index, 2)), ch_xx));
            ch_bottom = interp1(afiledata(leadingedge_index:end, 1), afiledata(leadingedge_index:end, 2), ch_xx);
        catch e
            disp(afiles(i).name + "\t" + getReport(e, 'basic'));
            continue
        end

        ch_all = [ch_all ; [ch_top ch_bottom]];
    end

    ch_transposed = multiplier*ch_all';
    autoenc = trainAutoencoder(ch_transposed, output_length, varargin{:});
end