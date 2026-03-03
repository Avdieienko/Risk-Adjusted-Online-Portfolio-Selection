function [R, dates, P] = prepareDataset(dataDir, assets)
    load_files(dataDir, assets);
    files = flipFile(dataDir, assets);
    files = trimFiles(files, 100);
    [R, dates, P] = aggregate_price_relatives(files);
end