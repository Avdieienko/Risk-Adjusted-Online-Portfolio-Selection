function [R, dates, P] = prepareDataset(dataDir, assets, startDate, endDate)
    load_files(dataDir, assets);
    files = flipFile(dataDir, assets);
    files = trimFilesByDate(files, startDate, endDate);
    [R, dates, P] = aggregate_price_relatives(files);
end